From: Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>
Subject: Re: [PATCH 1/2] posix clocks: introduce a syscall for clock
 tuning.
Date: Thu, 9 Sep 2010 12:49:27 +0200 (CEST)
Message-ID: <alpine.LFD.2.00.1009091159260.2477@localhost6.localdomain6>
References: <cover.1283504065.git.richard.cochran@omicron.at> <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, John Stultz <johnstul-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
To: Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <7f4815cdfcf5bc49df4bdd09d59a4f56ca2598f5.1283504065.git.richard.cochran-3mrvs1K0uXizZXS1Dc/lvw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 3 Sep 2010, Richard Cochran wrote:

This patch needs to be split in pieces. The syscall change is totally
unrelated to the dynamic clock id creation. Though I do not like
either of them. :)

> A new syscall is introduced that allows tuning of a POSIX clock. The
> syscall is implemented for four architectures: arm, blackfin, powerpc,
> and x86.
> 
> The new syscall, clock_adjtime, takes two parameters, the clock ID,
> and a pointer to a struct timex. The semantics of the timex struct
> have been expanded by one additional mode flag, which allows an
> absolute offset correction. When specificied, the clock offset is
> immediately corrected by skipping to the new time value.

And why do we need a separate syscall for this?

> In addition, the POSIX clock code has been augmented to offer a
> dynamic clock creation method. Instead of registering a hard
> coded clock ID, modules may call create_posix_clock(), which
> returns a new clock ID.

This has been discussed for years and I still fail to see the
requirement for this. The only result is that it allows folks to
create their special purpose clock stuff and keep it out of tree
instead of fixing the problems they have with the existing clock
infrastructure in the kernel.

As far as I understood from the previous discussions, the final goal
is to provide PTP support, right?

But what I see is an approach which tries to implement disconnected
special purpose clocks which have the ability to be adjusted
independently. What's the purpose of this ? Why can't we just use the
existing clocks and make PTP work on them ?

I know that lots of embedded folks think that they need their special
timers and extra magic to make stuff work, but that's the wrong
approach.

What's wrong with the existing clocks? Nothing, except that we have no
way to sync CLOCK_MONOTONIC across several machines. And that's what
you really want if you try to do distributed control and data
acquisition stuff.

That's a single CLOCK_MONOTONIC_GLOBAL and not a bunch of completely
disconnected clock implementations with random clock ids and random
feature sets.

Thoughts ?


	 tglx
