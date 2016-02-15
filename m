From: Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Mon, 15 Feb 2016 21:02:01 +0100
Message-ID: <20160215200201.GN3696@two.firstfloor.org>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <56BDB5A8.9030006@suse.cz>
 <20160212144543.GA29004@treble.redhat.com>
 <20160212171037.GV6357@twins.programming.kicks-ass.net>
 <20160212183206.GB29004@treble.redhat.com>
 <20160212201011.GW6357@twins.programming.kicks-ass.net>
 <20160215163134.GA20585@treble.redhat.com>
 <CA+55aFzoPCd_LcSx1FUuEhSBYk2KrfzXGj-Vcn39W5bz=KuZhA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Alok Kataria <akataria-pghWNbHTmq7QT0dZR+AlfA@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Guenter Roeck <linux-0h96xk9xTtrk1uMJSBkQmQ@public.gmane.org>,
	Anil S Keshavamurthy <anil.s.keshavamurthy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
	Bernd Petrovitsch <bernd-JY8rjfDgnXcb9sJ47jD7nuTv7YV0F9Eg@public.gmane.org>,
	linux-watchdog-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Pavel Machek <pavel-+ZI9xUNit7I@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>,
	Waiman Long <Waiman.Long-ZPxbGqLxI0U@public.gmane.org>,
	"Rafael J. Wysocki" <rafael.j.wysocki-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>, kvm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Paolo Bonzini <pbonzini@redh
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFzoPCd_LcSx1FUuEhSBYk2KrfzXGj-Vcn39W5bz=KuZhA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> > There are two ways to fix the warnings:
> >
> > 1. get rid of the thunks and call the C functions directly; or
> 
> No. Not until gcc learns about per-function callibg conventions (so that it can
> be marked as not clobbering registers).

It does already for static functions in 5.x (with -fipa-ra).
And with LTO it can be used even somewhat globally.

Even older version supported it, for only for x86->SSE on 32bit, which
is useless for the kernel. But the new IPA-RA propagates which registers
are clobbered.

That said it will probably be a long time until we can drop support for
older compilers.  So for now the manual method is still needed.

-Andi

--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
