From: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
Subject: Re: 2.6.35-rc4-git3: Reported regressions from 2.6.34
Date: Fri, 9 Jul 2010 09:11:31 +0200
Message-ID: <20100709071131.GB10743@elte.hu>
References: <-IGZ64uxA6G.A.P0H.bLmNMB@chimera>
 <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Maciej Rutecki <maciej.rutecki-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux ACPI <linux-acpi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux PM List <linux-pm-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>,
	Linux SCSI List <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	DRI <dri-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
	Shawn Starr <shawn.starr-bJEeYj9oJeDQT0dZR+AlfA@public.gmane.org>,
	Jesse Barnes <jbarnes-Y1mF5jBUw70BENJcbMCuUQ@public.gmane.org>,
	Dave Airlie <airlied-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>, Jens Axboe <axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org>
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Paul E. McKenney" <paulmck-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <AANLkTiknnzWyVpqnPCpyiEVHLgkewd0zaGzLInABRe2G-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:

> > Bug-Entry ? ? ? : http://bugzilla.kernel.org/show_bug.cgi?id=16346
> > Subject ? ? ? ? : 2.6.35-rc3-git8 - include/linux/fdtable.h:88 invoked rcu_dereference_check() without protection!
> > Submitter ? ? ? : Miles Lane <miles.lane-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > Date ? ? ? ? ? ?: 2010-07-04 22:04 (5 days old)
> > Message-ID ? ? ?: <AANLkTinof0k28rk4rMr66aubxcRL2rFa5ZEArj1lqD3o-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
> > References ? ? ?: http://marc.info/?l=linux-kernel&m=127828107815930&w=2
> 
> I'm not entirely sure if these RCU proving things should count as 
> regressions.

Generally not - and we've delayed at least one more complex (cgroups) fix to 
v2.6.36 because the patch itself was riskier than the warning.

Still most of the warning fixes turned out to be simple, so we merged the 
very-low-risk ones and right now we seem to be on top of them.

But in general the default rule is that we delay these fixes to v2.6.36.

> Sure, the option to enable RCU proving is new, but the things it reports 
> about generally are not new - and they are usually not even bugs in the 
> sense that they necessarily cause any real problems.
> 
> That particular one is in the single-thread optimizated case for fget_light, ie
> 
>         if (likely((atomic_read(&files->count) == 1))) {
>                 file = fcheck_files(files, fd);
> 
> where I think it should be entirely safe in all ways without any locking. So 
> I think it's a false positive too.

Yeah, it's a bit like with lockdep (and it's a bit like with compiler warning 
fixes): we had to punch through a large stack of false positives that 
accumulated in the past 10 years.

( Because real bugs eventually get fixed, while false positives always just
  accumulate. So almost by definition we always start with a very assymetric
  collection of warnings and a large stack of false positives. )

Having said that, it appears we got most of the false positives and are 
beginning to be in a more representative equilibrium now. If v2.6.35 isnt 
going to be warning-free then v2.6.36 certainly will be and new warnings will 
have a much higher likelyhood of being real (and new) bugs (not just 
accumulated false-positives).

	Ingo
