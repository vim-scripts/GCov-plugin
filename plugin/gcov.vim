"==========================================================
"Plugin by Martin Schreder, [volk], 2008
"==========================================================
"


" This function toggles between the gcov information and current source file
function! GCovToggle()
	let cur_line = line('.')
	let cur_file = expand('%')
	let ftype = &filetype

	" if we are in a gcov file, then go back to the source
	if match(cur_file, '.*\.gcov$') != -1
		" extract line number for the _source_ file
		let src_line_no = matchlist(getline("."), '\s*.\{-}:\s*\(\d*\):')[1]
		let src_file = matchlist(cur_file, '\(.\{-}\)\.gcov')[1]
		
		let src_line = substitute(getline(line(".")), '\s*.\{-}:\s*\d*:', '', '')

		if !filereadable(src_file)
			echo "Source file not found!"
		else	
			exec ":e +".src_line_no." ".src_file
			" if line does not match then go to the first one that does
			if !(src_line is getline(src_line_no))
				call cursor(0,0)
				let line = search(src_line)
				call cursor(line,0)
			" otherwise we are on the exact line
			else
				call cursor(src_line_no, 0)
			end
			exec ":setlocal modifiable"
		endif
	" if we are in the source file
	else
		" open the gcov file and find the right line
		let gcov_file = cur_file.".gcov"
		let src_line = getline(cur_line)

		if !filereadable(gcov_file)
			silent exec "!gcov %"
			redraw!
		endif
		if filereadable(gcov_file)
			exec ":w"
			exec ":e ".gcov_file
			call cursor(0,0)
			" try to find a complete line (with line number)
			let found = search('\s*.\{-}:.*'.string(cur_line).':'.src_line)
			" attempt to find just the code
			if found == 0
				call cursor(0,0)
				let found = search('\s*.\{-}:.*\d\{-}:'.src_line)
			end
			" still not found, go to the line of the source file
			if found == 0
				call cursor(cur_line)
			" we found the exact line
			else
				call cursor(found, 0)
			end
			" make sure the syntax highlighting is on 
			" and that buffer is not writable
			exec ':set filetype='.ftype
			exec ':setlocal nomodifiable'
		else
			echo "No .gcov information available"
		endif
	endif
endfunction

map <F11> :call GCovToggle()<cr>
