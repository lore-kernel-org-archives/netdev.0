From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Sat, 19 Mar 2005 14:19:47 -0800
Message-ID: <200503192219.j2JMJmDD014063@guinness.s2io.com>
References: <m17jk35r5l.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>
To: "'Andi Kleen'" <ak@muc.de>
In-Reply-To: <m17jk35r5l.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> First you wont like it, but Linux kernel maintainers usually dont give
> firm promises to merge anything.  They just say "with that i wont merge
> it"
> and even that is flexible sometimes. It is not like a company who
> gives commitments or signs contracts, it is really the final patch that
> counts.
> 
> The best way to get code merged is to write it like the maintainers
> wants it, but of course that does not happen always.
> 
> However when the code is clean and the biggest issues are fixed
> and only some relatively small ones are left I think you have a good
> chance to see your code merged.

Sure. I was not asking for a promise to merge the code, only for a rough
consensus that a HAL-based approach by itself is not a showstopper. 
Without such a consensus, it doesn't matter if we address other issues,
right?
 
> 
> >
> > Arguably, a hacker will be much more interested in changing the non-HAL
> part
> > of a driver. This part of the code has to look and feel the same as any
> > other Linux net driver. If it doesn't, then we've done a poor job and
> need
> > to go back.
> 
> There are currently some issues, mostly the "LAL" in it (Linux Adaption
> Layer that wraps everything) and all the ugly function parameters (IN and
> __STATIC_* and the wrapped list functions ). That is what just poked in my
> eyes at the first look.
> 
> I personally dont care that much about the later stuff which
> is more cosmetic, but a lot of other people strongly object to
> code that does not look like other Linux code so I would recommend to
> fix it.

Agreed; we are fixing this for the new submission.

> 
> 
> What I also did not like was that you had high level logic in these
> HAL parts - like handling packet queues etc. Normally IMHO high level
> logic should be directly in the functions that are directly called
> from the kernel. This way it is easy to follow the main logic
> of the driver if someone is familiar with linux network drivers
> in general

In general, I agree that low level logic (AKA HAL code) needs to be as small
as possible, and should not include a code that is typically common in Linux
(or any other) network driver. 
Unfortunately MAC driver models for different Operating Systems diverged so
much, the interface for the low level logic ends up higher than anyone would
like...
This is a valid comment though, we will see if there is room for
improvement.

Skip...


> The problem is usually that when there is some bug in your driver
> and someone not in your company wants to debug it because the bug
> is causing them problems (that is one of the great advantages of free
> software that they can do it themselves), then they want relatively
> clean code. The same happens for the maintainer who is hunting some
> issue and needs to change your driver slightly for some infrastructure
> change.
> 
> So even though most changes come likely from you there is a need
> for other people to understand and change your code.

I agree, to a point - if for a hacker or a maintainer this driver is way
hard to understand (comparing to it's "s2io" sibling), then is not a good
thing and has to be addressed as much as practical.

Hopefully follow-up submissions will get to the point when HAL code still
has some non-Linux "accent" but it's sufficiently clean for people to
understand it.
This will be a tradeoff for some, but hopefully a good one - I still think
the majority of low-level code fixes will come from our team (sometimes by
virtue of fixing a problem in different OS).

Thanks for the detailed feedback!
Leonid


> 
> -Andi
