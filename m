From: Michal Soltys <soltys@ziu.info>
Subject: Bug#631945: [Bugme-new] [Bug 39372] New: Problems with HFSC Scheduler
Date: Fri, 29 Jul 2011 14:29:10 +0200
Message-ID: <4E32A796.8060104@ziu.info>
References: <bug-39372-10286@https.bugzilla.kernel.org/> <20110714151425.844b7738.akpm@linux-foundation.org>
Reply-To: Michal Soltys <soltys@ziu.info>, 631945@bugs.debian.org
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>, lucas.bocchi@gmail.com,
	Patrick McHardy <kaber@trash.net>, 631945@bugs.debian.org,
	00bormoj@gmail.com, fdelawarde@wirelessmundi.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.631945.B631945.13119425677710@bugs.debian.org>
In-Reply-To: <20110714151425.844b7738.akpm@linux-foundation.org>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

On 11-07-15 00:14, Andrew Morton wrote:
> 
> (switched to email.  Please respond via emailed reply-to-all, not via
> the bugzilla web interface).
> 
> 
> Here: WARN_ON(next_time == 0);
> 

>From the other thread on netfilter-devel:

> On 11-07-22 11:58, Michal Pokrywka wrote: After bisecting 2.6.39.1 it
> turned out that the bug is caused independently by two patches:
> 
> commit b262a5da755cc6ed0cb4fba230cd9bf4037e1096 sch_sfq: fix peek()
> implementation
> 
> and
> 
> commit 9df49f2bfe862573911a080c75a6d81113c5c81d sch_sfq: avoid giving
> spurious NET_XMIT_CN signals
> 
> Reverting these patches makes HFSC work again.
> 

This one (upstream 8efa885406359af300d46910642b50ca82c0fe47) seems to be
the culprit (does reverting only that one cures the problem ?)

It allows SFQ to return success on enqueuing, when the packet really
replaced some other packet in some other flow. This confuses outer qdisc
(in this particular case HFSC) which thinks new packet was actually
added each time such situation happes.

This in turn causes additional dequeues and ends with attempt
to schedule non-existent packets, and triggers the warning.


ps.

removed netfilter from cc, as it's not really netfilter issue.
