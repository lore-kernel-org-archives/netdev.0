From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v17 0/9] Compile-time stack metadata validation
Date: Thu, 25 Feb 2016 09:02:04 +0100
Message-ID: <20160225080203.GC2354@gmail.com>
References: <cover.1456331595.git.jpoimboe@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	Arnaldo Carvalho de Melo <acme@kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Alexei Starovoitov <ast@k
To: Josh Poimboeuf <jpoimboe@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33661 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759458AbcBYICJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:02:09 -0500
Content-Disposition: inline
In-Reply-To: <cover.1456331595.git.jpoimboe@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Josh Poimboeuf <jpoimboe@redhat.com> wrote:

> This is v17 of the compile-time stack metadata validation patch set.
> 
> It's based on tip:x86/debug.  However, note that when run against that
> branch it will give a lot of warnings:
> 
>   objtool: arch/x86/ia32/sys_ia32.o: __ex_table size not a multiple of 12
>   objtool: arch/x86/ia32/ia32_signal.o: __ex_table size not a multiple of 12
>   objtool: arch/x86/entry/common.o: __ex_table size not a multiple of 12
>   ...
> 
> These warnings means that objtool is expecting the new exception table
> format which was introduced with:
> 
>   548acf19234d ("x86/mm: Expand the exception table logic to allow new handling options")
> 
> So that commit is needed for those warnings to go away.

Ok. I have created a new topic branch for the objtool commits: tip:core/objtool, 
and merged tip:ras/core into it (which hosts 548acf19234d).

So please use tip:core/objtool as a base from now on.

Two more minor observations:

Please re-order the patches slightly so that the annotations are added first, and 
objtool is added and Kconfig-enabled in the final patches.

>   x86/objtool: Compile-time stack metadata validation
>   x86/objtool: Add CONFIG_STACK_VALIDATION option
>   x86/objtool: Enable objtool on x86_64
>   x86/objtool: Add STACK_FRAME_NON_STANDARD macro
>   x86/objtool: Add directory and file whitelists

btw., please use the more generic 'objtool: ' prefix, the concept is not 
fundamentally x86 specific - especially once dwarf debuginfo is interpreted it 
will be useful beyond x86 as well I suspect.

>   x86/xen: Add xen_cpuid() to objtool whitelist
>   bpf: Add __bpf_prog_run() to objtool whitelist
>   sched: Add __schedule() to objtool whitelist
>   x86/kprobes: Add kretprobe_trampoline() to objtool whitelist

Thanks,

	Ingo
