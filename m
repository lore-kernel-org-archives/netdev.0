From: Pavel Machek <pavel@ucw.cz>
Subject: Re: RFC: A reduced Linux network stack for small systems
Date: Fri, 9 May 2014 09:39:09 +0200
Message-ID: <20140509073909.GE4965@xo-6d-61-c0.localdomain>
References: <1399328773-6531-1-git-send-email-andi@firstfloor.org>
 <CAFLxGvww8t-PpuS3B=dFvn8k3xBydk3CgA=qoLyEbkKJZJ0xhQ@mail.gmail.com>
 <1399383246.8767.99.camel@empanada>
 <CAADnVQLYiNfXRrXc=VZkGEFDbNhF63AzPg6Gyu6P1SF=6AiO7g@mail.gmail.com>
 <1399390490.8767.122.camel@empanada>
 <CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Zanussi <tom.zanussi@linux.intel.com>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAADnVQ+nCtshedoDWN+QgiKzsCzBcojZOzrhkfzsqyXTpi4L=w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >> that is likely working only for the given very limited set of applications.
> >> Kernel function profiling can potentially achieve the same thing.
> >> Profile the kernel with the set of apps and then prune all cold
> >> functions out of kernel.
> >
> > Right, and are Profile-Guided-Optimization results now reproduceable?
> > Better change it to Trace-Guided-Optimization.  But yeah, for a
> 
> not quite. I'm saying: no extra optimizations, no GCC changes.
> Compile kernel as-is. Most functions have a stub for mcount() already.
> Use it to track whether kernel function was called or not.
> Collect this data in userspace (as perf already does), add few
> more functions that had 'notrace' attribute on them, and feed this into
> special linker that unpacks existing vmlinux, throws away cold functions,
> relocates the rest and here you have tiny vmlinux without recompilation.

It sounds like unstripped kernel will not even fit on the target machine.
If it+application would fit there, you'd have no reason to strip it down...

									Pavel

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
