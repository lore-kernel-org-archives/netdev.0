From: "Stephens, Allan" <allan.stephens@windriver.com>
Subject: Re: [PATCH]: tipc: Fix oops on send prior to
	entering networked mode
Date: Thu, 25 Feb 2010 06:24:15 -0800
Message-ID: <29C1DC0826876849BDD9F1C67ABA2943070F1849@ala-mail09.corp.ad.wrs.com>
References: <20100224185340.GB15380@hmsreliant.think-freely.org><29C1DC0826876849BDD9F1C67ABA2943070F1534@ala-mail09.corp.ad.wrs.com><20100224211507.GC15380@hmsreliant.think-freely.org>
	<20100224.173811.264809559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: "David Miller" <davem@davemloft.net>, <nhorman@tuxdriver.com>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
Content-class: urn:content-classes:message
In-Reply-To: <20100224.173811.264809559.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, February 24, 2010 8:38 PM

> > Looking at the 1.7.6 tarball on sourceforge, its dated 
> 10/10/2008, so 
> > you've basically got a 1.5 year lag between the development version 
> > and the commited version that distributions are using (and 
> counting).  
> > I'm sorry, I'm not trying to be crass about this, but its rather 
> > disconcerting to see that kind of discrepancy between the code 
> > development point and whats in net-next.  It implies that 
> the only fix 
> > for a tipc problem is a wholesale upgrade of the tipc 
> directory in the 
> > kernel (since it would seem the sourceforge tipc cvs tree has gone 
> > unused for a few years).
> 
> I'm extremely upset about this.
> 
> Especially given the fact that EVERY DAMN TIME there were 
> TIPC patches posted I applied EVERY DAMN ONE of them, and I 
> did so in an expediant manner.
> 
> So there is zero reason for the TIPC protocol development to 
> not have occured upstream.  I, in fact, facilitated things to 
> work that way in the smoothest way possible, if only the TIPC 
> developers had obliged.

I think it is important to understand how things got to be the way they
are with TIPC before any finger pointing starts.

When TIPC 1.6 was first integrated into Linux (back in 2.6.16) there was
some considerable flak generated because it was done as a bulk patch,
rather than being trickled in as a series of smaller, logically distinct
patches.  Since then, I have carefully ensured that all subsequent
patches were submitted in the conventional Linux manner to avoid giving
anyone cause for complaint.  (And there can be no argument about the
fact that David has been very good about applying the patches as soon as
they were made available.)

Later, the company that employs me found it necessary to enhance TIPC
with new capabilities which would be included in a couple of our
operating systems (one of which is Linux-based).  To meet our schedule,
it was necessary to make a large number of major changes to TIPC, and it
was felt that submitting these relatively untested changes to mainstream
Linux would be potentially destabilzing and therefore undesirable.
Thus, development was done downstream under the "TIPC 1.7" banner, with
the intent that the changes would be pushed back upstream once we knew
they wouldn't negatively impact existing functionality.  And so it went
at first -- about 65 patches from TIPC 1.7 were in fact incorporated
into Linux in 2008.  However, because TIPC 1.7 was not developed using
git (remember that Linux was only one of the operating systems
involved), there was no existing set of small, logically distinct
patches that could be applied to mainstream Linux, and each of the
patches that was submitted had to be carefully drafted from the finished
code base in a time-consuming manual process.

Then came an economic downturn, and our company was forced to divert
development resources away from TIPC and the remainder of the TIPC 1.7
code remained downstream-only (although freely available, and supported,
on SourceForge).  And while the status quo is admittedly
less-than-optimal, it has apparently served the needs of the TIPC user
community for the last couple of years and shouldn't give anyone cause
to get upset.

So much for past history.  I'm more interested in understanding how we
can best move forward on completing the job of integrating TIPC 1.7 into
Linux.  As far as I can tell there seem to be two routes forward.  One
is to continue following the previous method of extracting small patches
from TIPC 1.7 and submitting them one by one; the other is to integrate
the remaining code using a small number of bulk patches (i.e. the kind
of ones that people complained about when TIPC 1.6 was integrated).  The
problem with insisting on the first approach is that it is simply too
time consuming.  So, would it be acceptable to David (and everyone else)
if we took the latter approach as a one-time-only exception to the
normal process?  Or is there a third option available that could be done
to integrate the rest of TIPC 1.7 quickly?

Regards,
Al

PS. I'm holding back on replying to other previous emails from David and
Neil in this thread since deciding how to fix the oops that triggered
this whole discussion depends on whether or not we're going to integrate
the rest of TIPC 1.7 or not.




------------------------------------------------------------------------------
Download Intel&#174; Parallel Studio Eval
Try the new software tools for yourself. Speed compiling, find bugs
proactively, and fine-tune applications for parallel performance.
See why Intel Parallel Studio got high marks during beta.
http://p.sf.net/sfu/intel-sw-dev
