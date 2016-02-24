From: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Wed, 24 Feb 2016 10:32:40 -0600
Message-ID: <20160224163240.GB16390@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <20160223081406.GA606@gmail.com>
 <20160223150155.GB15858@treble.redhat.com>
 <20160224074054.GA13199@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, live-patching-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bernd Petrovitsch <bernd-JY8rjfDgnXcb9sJ47jD7nuTv7YV0F9Eg@public.gmane.org>,
	Chris J Arges <chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Borislav Petkov <bp-l3A5Bk7waGM@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jeremy Fitzhardinge <jeremy-fhVVxSuDe2w@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160224074054.GA13199-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 24, 2016 at 08:40:54AM +0100, Ingo Molnar wrote:
> 
> * Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> 
> > Hi Ingo,
> > 
> > On Tue, Feb 23, 2016 at 09:14:06AM +0100, Ingo Molnar wrote:
> > > So I tried out this latest stacktool series and it looks mostly good for an 
> > > upstream merge.
> > > 
> > > To help this effort move forward I've applied the preparatory/fix patches that are 
> > > part of this series to tip:x86/debug - that's 26 out of 31 patches. (I've 
> > > propagated all the acks that the latest submission got into the changelogs.)
> > 
> > Thanks very much for your review and for applying the fixes!
> > 
> > A few issues relating to the merge:
> > 
> > - The tip:x86/debug branch fails to build because it depends on
> >   ec5186557abb ("x86/asm: Add C versions of frame pointer macros") which
> >   is in tip:x86/asm.
> 
> Indeed...

FYI, v17 will be based on tip:x86/debug.  But note that, when run
against that branch, it'll spit out a lot of these warnings:

  objtool: arch/x86/ia32/sys_ia32.o: __ex_table size not a multiple of 12
  objtool: arch/x86/ia32/ia32_signal.o: __ex_table size not a multiple of 12
  objtool: arch/x86/entry/common.o: __ex_table size not a multiple of 12

Those warnings mean it's expecting the new exception table format which
was added in:

  548acf19234d ("x86/mm: Expand the exception table logic to allow new handling options")

So that commit is needed to avoid the warnings.

Thanks!

-- 
Josh
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
