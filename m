From: Bill Fink <billfink@mindspring.com>
Subject: Re: HPET regression in 2.6.26 versus 2.6.25 -- why Yinghai's revert
 may have failed
Date: Fri, 15 Aug 2008 04:10:50 -0400
Message-ID: <20080815041050.37479646.billfink@mindspring.com>
References: <990549.89300.qm@web82101.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yinghai Lu <yhlu.kernel@gmail.com>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev <netdev@vger.kernel.org>
To: David Witbrodt <dawitbro@sbcglobal.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-spurfowl.atl.sa.earthlink.net ([209.86.89.66]:58427
	"EHLO elasmtp-spurfowl.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691AbYHOIKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 04:10:54 -0400
In-Reply-To: <990549.89300.qm@web82101.mail.mud.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, 14 Aug 2008, David Witbrodt wrote:

> > > I used 'git apply --check ' first, and got no errors, so
> > > I applied it, built, installed, and rebooted.
> > 
> > that patch revert to use request_resource, so there is some other problem
> > 
> > YH
> 
> I finished experimenting last night with trying to find the last commit
> in the gittree that would let me revert the problem successfully...
> and I got completely raped.
> 
> The bisecting took me all the way back to the first commit introducing
> the problem on these motherboards:  3def3d6d...
> 
> Considering these 3 consecutive commits (according to 'git log')from late
> Feb. 2008, between kernel versions 2.6.25 and 2.6.26-rc1:
> ---------------------------------------------------------
> 
> 700efc1b...:  the last kernel I can build and run just fine.
> 
> 3def3d6d...:  this one builds, but locks up in inet_init() once the sequence
> of function calls reaches synchronize_rcu().  Reverting here works, but is
> trivial and silly, just reproducing 700efc1b...
> 
> 1e934dda...:  attempting to revert the changes from 3def3d6d... (just one
> commit before!) already fails.
> ---------------------------------------------------------
> 
> This last commit has an effect on my machine that prevents attempts to
> revert 3def3d6d... from working as intended.  This may explain why
> Yinghai's patch providing the revert for 2.6.27-rc3 did not work.
> (Hopefully none of the other changes between Feb. and Aug. would also keep
> the revert from working, but I wouldn't bet my life on it....)
> 
> The 3d... and 1e... commits are quite small, touching only 4 files total,
> and both commits involve calls to insert_resource().  Something on my 2
> problem machines is behaving badly in this area.

I wonder if it would help to revert both the 3def3d6d... and 1e934dda...
commits.  If there are 2 (or more) problematic commits, then of course
it wouldn't help to revert just one of the two commits.  This is one of
the nastiest type of debugging scenario, when there is more than one
cause of the observed problem, although in such case the multiple
causes are often related in some way.

						-Bill
