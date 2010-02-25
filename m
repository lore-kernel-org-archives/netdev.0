From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to entering networked mode
Date: Thu, 25 Feb 2010 10:23:28 -0500
Message-ID: <20100225152328.GA2990@shamino.rdu.redhat.com>
References: <20100224185340.GB15380@hmsreliant.think-freely.org>
 <29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com>
 <20100224211507.GC15380@hmsreliant.think-freely.org>
 <20100224.173811.264809559.davem@davemloft.net>
 <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, tipc-discussion@lists.sourceforge.net
To: "Stephens, Allan" <allan.stephens@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:58289 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759274Ab0BYPXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2010 10:23:12 -0500
Content-Disposition: inline
In-Reply-To: <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 25, 2010 at 06:24:15AM -0800, Stephens, Allan wrote:
> > From: David Miller [mailto:davem@davemloft.net] 
> > Sent: Wednesday, February 24, 2010 8:38 PM
> 
> > > Looking at the 1.7.6 tarball on sourceforge, its dated 
> > 10/10/2008, so 
> > > you've basically got a 1.5 year lag between the development version 
> > > and the commited version that distributions are using (and 
> > counting).  
> > > I'm sorry, I'm not trying to be crass about this, but its rather 
> > > disconcerting to see that kind of discrepancy between the code 
> > > development point and whats in net-next.  It implies that 
> > the only fix 
> > > for a tipc problem is a wholesale upgrade of the tipc 
> > directory in the 
> > > kernel (since it would seem the sourceforge tipc cvs tree has gone 
> > > unused for a few years).
> > 
> > I'm extremely upset about this.
> > 
> > Especially given the fact that EVERY DAMN TIME there were 
> > TIPC patches posted I applied EVERY DAMN ONE of them, and I 
> > did so in an expediant manner.
> > 
> > So there is zero reason for the TIPC protocol development to 
> > not have occured upstream.  I, in fact, facilitated things to 
> > work that way in the smoothest way possible, if only the TIPC 
> > developers had obliged.
> 
> I think it is important to understand how things got to be the way they
> are with TIPC before any finger pointing starts.
> 
> When TIPC 1.6 was first integrated into Linux (back in 2.6.16) there was
> some considerable flak generated because it was done as a bulk patch,
> rather than being trickled in as a series of smaller, logically distinct
> patches.  Since then, I have carefully ensured that all subsequent
> patches were submitted in the conventional Linux manner to avoid giving
> anyone cause for complaint.  (And there can be no argument about the
> fact that David has been very good about applying the patches as soon as
> they were made available.)
> 
> Later, the company that employs me found it necessary to enhance TIPC
> with new capabilities which would be included in a couple of our
> operating systems (one of which is Linux-based).  To meet our schedule,
> it was necessary to make a large number of major changes to TIPC, and it
> was felt that submitting these relatively untested changes to mainstream
> Linux would be potentially destabilzing and therefore undesirable.
> Thus, development was done downstream under the "TIPC 1.7" banner, with
> the intent that the changes would be pushed back upstream once we knew
> they wouldn't negatively impact existing functionality.  And so it went
> at first -- about 65 patches from TIPC 1.7 were in fact incorporated
> into Linux in 2008.  However, because TIPC 1.7 was not developed using
> git (remember that Linux was only one of the operating systems
> involved), there was no existing set of small, logically distinct
> patches that could be applied to mainstream Linux, and each of the
> patches that was submitted had to be carefully drafted from the finished
> code base in a time-consuming manual process.
> 
> Then came an economic downturn, and our company was forced to divert
> development resources away from TIPC and the remainder of the TIPC 1.7
> code remained downstream-only (although freely available, and supported,
> on SourceForge).  And while the status quo is admittedly
> less-than-optimal, it has apparently served the needs of the TIPC user
> community for the last couple of years and shouldn't give anyone cause
> to get upset.
> 
> So much for past history.  I'm more interested in understanding how we
> can best move forward on completing the job of integrating TIPC 1.7 into
> Linux.  As far as I can tell there seem to be two routes forward.  One
> is to continue following the previous method of extracting small patches
> from TIPC 1.7 and submitting them one by one; the other is to integrate
> the remaining code using a small number of bulk patches (i.e. the kind
> of ones that people complained about when TIPC 1.6 was integrated).  The
> problem with insisting on the first approach is that it is simply too
> time consuming.  So, would it be acceptable to David (and everyone else)
> if we took the latter approach as a one-time-only exception to the
> normal process?  Or is there a third option available that could be done
> to integrate the rest of TIPC 1.7 quickly?
> 
> Regards,
> Al
> 
> PS. I'm holding back on replying to other previous emails from David and
> Neil in this thread since deciding how to fix the oops that triggered
> this whole discussion depends on whether or not we're going to integrate
> the rest of TIPC 1.7 or not.
> 
> 
> 
> 

While I sympathize with your history, this really stick out of your explination
for me:
"""
>To meet our schedule,
> it was necessary to make a large number of major changes to TIPC, and it
> was felt that submitting these relatively untested changes to mainstream
> Linux would be potentially destabilzing and therefore undesirable.
> Thus, development was done downstream under the "TIPC 1.7" banner, with
> the intent that the changes would be pushed back upstream once we knew
> they wouldn't negatively impact existing functionality.
"""

To me I see that and read it as:
"We didn't have time to do things the way the Linux maintainers like to have
them done, so we went off and did it on our own, figuring we'd get back to doing
it the right way later"

Well, flash forward 1.5 years, and getting back to it never happened.  While I
understand that can happen, it puts users in the lurch if they expect upstream
to be the latest bits.  As such, have you considered just dropping TIPC from
upstream entirely?  I know that sounds a bit angry, I don't intend it to, I mean
it in all seriousness.  Companies have constraints that sometimes conflict with
upstream practices though, thats just a fact of life, and theres nothing we can
really do about that.  But if the review/accptance criteria of upstream
development doesn't fit into a companies budget or schedule, not doing kernel community
development might be the best solution.  Doing so tells the distros that they
have extra work to do if they want to incorporate/support tipc in their kernels,
and frees your company to develop on its own schedule, and according to its own
resources, while still being accessable to end users.  Of course, in so doing
you don't get the maintenence changes that come with an ever evolving ABI/etc,
but thats the price you would have to pay, and a decision you could make.

I'm not trying to tell you its the best solution, just an alternate option.
Honestly, what I'd like to see is all the remaining changes in TIPC 1.7 go in as
individual commits, so that we have a good change history, and a resonable
review on all the changes.  I know that takes longer but I think its the right
solution.  I'll even volunteer to help, if that lightens your load any.  If you
can provide me access to whatever scm you used (or even some modicum of
changelog in a text file, so that we could try to match up changes with
documentation), I'll happily start pulling stuff apart to get it upstream.

But if thats a one shot deal, and you believe that the next schedule crunch you
have will result in your company making another out-of-tree update, then perhaps
switching to that mode of out-of-tree development might be worth consideration.

Regards
Neil

