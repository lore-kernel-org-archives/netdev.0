From: David Witbrodt <dawitbro@sbcglobal.net>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- why Yinghai's revert may have failed
Date: Fri, 15 Aug 2008 05:33:22 -0700 (PDT)
Message-ID: <69468.18828.qm@web82105.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web82105.mail.mud.yahoo.com ([209.191.84.218]:42883 "HELO
	web82105.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753399AbYHOMdX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 08:33:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> > Considering these 3 consecutive commits (according to 'git log')from late
> > Feb. 2008, between kernel versions 2.6.25 and 2.6.26-rc1:
> > ---------------------------------------------------------
> > 
> > 700efc1b...:  the last kernel I can build and run just fine.
> > 
> > 3def3d6d...:  this one builds, but locks up in inet_init() once the sequence
> > of function calls reaches synchronize_rcu().  Reverting here works, but is
> > trivial and silly, just reproducing 700efc1b...
> > 
> > 1e934dda...:  attempting to revert the changes from 3def3d6d... (just one
> > commit before!) already fails.
> > ---------------------------------------------------------
> > 
> > This last commit has an effect on my machine that prevents attempts to
> > revert 3def3d6d... from working as intended.  This may explain why
> > Yinghai's patch providing the revert for 2.6.27-rc3 did not work.
> > (Hopefully none of the other changes between Feb. and Aug. would also keep
> > the revert from working, but I wouldn't bet my life on it....)
> > 
> > The 3d... and 1e... commits are quite small, touching only 4 files total,
> > and both commits involve calls to insert_resource().  Something on my 2
> > problem machines is behaving badly in this area.
> 
> I wonder if it would help to revert both the 3def3d6d... and 1e934dda...
> commits.  If there are 2 (or more) problematic commits, then of course
> it wouldn't help to revert just one of the two commits.  This is one of
> the nastiest type of debugging scenario, when there is more than one
> cause of the observed problem, although in such case the multiple
> causes are often related in some way.

Thanks for this Bill.  I got home pretty late last night, so I only tried a
few things before hitting the sack.

Your suggestion is something I was planning, but didn't get to yet.  It
seems like any change after 3def3d6d that touches insert_resource() causes
kernels to lock up on 2 of my 3 machines.

Mike Galbraith sent an offlist reply with a very good idea for finding out
whether a commit _before_ 3def3d6d is the actual cause of my troubles.  I
am more intrigued by this possibility than the idea you and I had about
reverting both 3def3d6d and 1e934dda and moving forward from there.

If Mike's idea doesn't seem to go anywhere -- if I cannot find a kernel
that works by applying the 3def3d6d changes to _previous_ kernel revisions,
then I plan to create a branch at 700efc1b and try moving forward toward
2.6.26 (skipping the 3def3d6d and 1e934dda commits, of course) until the
kernel freezes again.

Now I have plenty of things to try!


Thx,
Dave W.
