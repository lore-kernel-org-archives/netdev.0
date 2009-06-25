From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH -tip 3/3] synchronize_sched_expedited() rcutorture doc + updates
Date: Thu, 25 Jun 2009 09:08:18 -0700
Message-ID: <2313.19670933789$1245946724@news.gmane.org>
References: <20090625160706.GA9467@linux.vnet.ibm.com>
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:48882 "EHLO e4.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751514AbZFYQRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 12:17:25 -0400
In-Reply-To: <20090625160706.GA9467@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

This patch updates the rcutorture documentation to include updated
output format.  It also brings the RCU documentation up to date.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 Documentation/RCU/RTFP.txt       |   77 ++++++++++++++++++++++++++++++++++++++
 Documentation/RCU/UP.txt         |   34 ++++++++++++----
 Documentation/RCU/checklist.txt  |   20 +++++++--
 Documentation/RCU/rcubarrier.txt |    7 +++
 Documentation/RCU/torture.txt    |   23 ++++++++++-
 Documentation/RCU/whatisRCU.txt  |   14 +++++-
 6 files changed, 156 insertions(+), 19 deletions(-)

diff --git a/Documentation/RCU/RTFP.txt b/Documentation/RCU/RTFP.txt
index 9f711d2..d2b8523 100644
--- a/Documentation/RCU/RTFP.txt
+++ b/Documentation/RCU/RTFP.txt
@@ -743,3 +743,80 @@ Revised:
 	RCU, realtime RCU, sleepable RCU, performance.
 "
 }
+
+@article{PaulEMcKenney2008RCUOSR
+,author="Paul E. McKenney and Jonathan Walpole"
+,title="Introducing technology into the {Linux} kernel: a case study"
+,Year="2008"
+,journal="SIGOPS Oper. Syst. Rev."
+,volume="42"
+,number="5"
+,pages="4--17"
+,issn="0163-5980"
+,doi={http://doi.acm.org/10.1145/1400097.1400099}
+,publisher="ACM"
+,address="New York, NY, USA"
+,annotation={
+	Linux changed RCU to a far greater degree than RCU has changed Linux.
+}
+}
+
+@unpublished{PaulEMcKenney2008HierarchicalRCU
+,Author="Paul E. McKenney"
+,Title="Hierarchical {RCU}"
+,month="November"
+,day="3"
+,year="2008"
+,note="Available:
+\url{http://lwn.net/Articles/305782/}
+[Viewed November 6, 2008]"
+,annotation="
+	RCU with combining-tree-based grace-period detection,
+	permitting it to handle thousands of CPUs.
+"
+}
+
+@conference{PaulEMcKenney2009MaliciousURCU
+,Author="Paul E. McKenney"
+,Title="Using a Malicious User-Level {RCU} to Torture {RCU}-Based Algorithms"
+,Booktitle="linux.conf.au 2009"
+,month="January"
+,year="2009"
+,address="Hobart, Australia"
+,note="Available:
+\url{http://www.rdrop.com/users/paulmck/RCU/urcutorture.2009.01.22a.pdf}
+[Viewed February 2, 2009]"
+,annotation="
+	Realtime RCU and torture-testing RCU uses.
+"
+}
+
+@unpublished{MathieuDesnoyers2009URCU
+,Author="Mathieu Desnoyers"
+,Title="[{RFC} git tree] Userspace {RCU} (urcu) for {Linux}"
+,month="February"
+,day="5"
+,year="2009"
+,note="Available:
+\url{http://lkml.org/lkml/2009/2/5/572}
+\url{git://lttng.org/userspace-rcu.git}
+[Viewed February 20, 2009]"
+,annotation="
+	Mathieu Desnoyers's user-space RCU implementation.
+	git://lttng.org/userspace-rcu.git
+"
+}
+
+@unpublished{PaulEMcKenney2009BloatWatchRCU
+,Author="Paul E. McKenney"
+,Title="{RCU}: The {Bloatwatch} Edition"
+,month="March"
+,day="17"
+,year="2009"
+,note="Available:
+\url{http://lwn.net/Articles/323929/}
+[Viewed March 20, 2009]"
+,annotation="
+	Uniprocessor assumptions allow simplified RCU implementation.
+"
+}
diff --git a/Documentation/RCU/UP.txt b/Documentation/RCU/UP.txt
index aab4a9e..90ec534 100644
--- a/Documentation/RCU/UP.txt
+++ b/Documentation/RCU/UP.txt
@@ -2,14 +2,13 @@ RCU on Uniprocessor Systems
 
 
 A common misconception is that, on UP systems, the call_rcu() primitive
-may immediately invoke its function, and that the synchronize_rcu()
-primitive may return immediately.  The basis of this misconception
+may immediately invoke its function.  The basis of this misconception
 is that since there is only one CPU, it should not be necessary to
 wait for anything else to get done, since there are no other CPUs for
 anything else to be happening on.  Although this approach will -sort- -of-
 work a surprising amount of the time, it is a very bad idea in general.
-This document presents three examples that demonstrate exactly how bad an
-idea this is.
+This document presents three examples that demonstrate exactly how bad
+an idea this is.
 
 
 Example 1: softirq Suicide
@@ -82,11 +81,18 @@ Quick Quiz #2: What locking restriction must RCU callbacks respect?
 
 Summary
 
-Permitting call_rcu() to immediately invoke its arguments or permitting
-synchronize_rcu() to immediately return breaks RCU, even on a UP system.
-So do not do it!  Even on a UP system, the RCU infrastructure -must-
-respect grace periods, and -must- invoke callbacks from a known environment
-in which no locks are held.
+Permitting call_rcu() to immediately invoke its arguments breaks RCU,
+even on a UP system.  So do not do it!  Even on a UP system, the RCU
+infrastructure -must- respect grace periods, and -must- invoke callbacks
+from a known environment in which no locks are held.
+
+It -is- safe for synchronize_sched() and synchronize_rcu_bh() to return
+immediately on an UP system.  It is also safe for synchronize_rcu()
+to return immediately on UP systems, except when running preemptable
+RCU.
+
+Quick Quiz #3: Why can't synchronize_rcu() return immediately on
+	UP systems running preemptable RCU?
 
 
 Answer to Quick Quiz #1:
@@ -117,3 +123,13 @@ Answer to Quick Quiz #2:
 	callbacks acquire locks directly.  However, a great many RCU
 	callbacks do acquire locks -indirectly-, for example, via
 	the kfree() primitive.
+
+Answer to Quick Quiz #3:
+	Why can't synchronize_rcu() return immediately on UP systems
+	running preemptable RCU?
+
+	Because some other task might have been preempted in the middle
+	of an RCU read-side critical section.  If synchronize_rcu()
+	simply immediately returned, it would prematurely signal the
+	end of the grace period, which would come as a nasty shock to
+	that other thread when it started running again.
diff --git a/Documentation/RCU/checklist.txt b/Documentation/RCU/checklist.txt
index accfe2f..51525a3 100644
--- a/Documentation/RCU/checklist.txt
+++ b/Documentation/RCU/checklist.txt
@@ -11,7 +11,10 @@ over a rather long period of time, but improvements are always welcome!
 	structure is updated more than about 10% of the time, then
 	you should strongly consider some other approach, unless
 	detailed performance measurements show that RCU is nonetheless
-	the right tool for the job.
+	the right tool for the job.  Yes, you might think of RCU
+	as simply cutting overhead off of the readers and imposing it
+	on the writers.  That is exactly why normal uses of RCU will
+	do much more reading than updating.
 
 	Another exception is where performance is not an issue, and RCU
 	provides a simpler implementation.  An example of this situation
@@ -240,10 +243,11 @@ over a rather long period of time, but improvements are always welcome!
 	instead need to use synchronize_irq() or synchronize_sched().
 
 12.	Any lock acquired by an RCU callback must be acquired elsewhere
-	with irq disabled, e.g., via spin_lock_irqsave().  Failing to
-	disable irq on a given acquisition of that lock will result in
-	deadlock as soon as the RCU callback happens to interrupt that
-	acquisition's critical section.
+	with softirq disabled, e.g., via spin_lock_irqsave(),
+	spin_lock_bh(), etc.  Failing to disable irq on a given
+	acquisition of that lock will result in deadlock as soon as the
+	RCU callback happens to interrupt that acquisition's critical
+	section.
 
 13.	RCU callbacks can be and are executed in parallel.  In many cases,
 	the callback code simply wrappers around kfree(), so that this
@@ -310,3 +314,9 @@ over a rather long period of time, but improvements are always welcome!
 	Because these primitives only wait for pre-existing readers,
 	it is the caller's responsibility to guarantee safety to
 	any subsequent readers.
+
+16.	The various RCU read-side primitives do -not- contain memory
+	barriers.  The CPU (and in some cases, the compiler) is free
+	to reorder code into and out of RCU read-side critical sections.
+	It is the responsibility of the RCU update-side primitives to
+	deal with this.
diff --git a/Documentation/RCU/rcubarrier.txt b/Documentation/RCU/rcubarrier.txt
index 909602d..e439a0e 100644
--- a/Documentation/RCU/rcubarrier.txt
+++ b/Documentation/RCU/rcubarrier.txt
@@ -170,6 +170,13 @@ module invokes call_rcu() from timers, you will need to first cancel all
 the timers, and only then invoke rcu_barrier() to wait for any remaining
 RCU callbacks to complete.
 
+Of course, if you module uses call_rcu_bh(), you will need to invoke
+rcu_barrier_bh() before unloading.  Similarly, if your module uses
+call_rcu_sched(), you will need to invoke rcu_barrier_sched() before
+unloading.  If your module uses call_rcu(), call_rcu_bh(), -and-
+call_rcu_sched(), then you will need to invoke each of rcu_barrier(),
+rcu_barrier_bh(), and rcu_barrier_sched().
+
 
 Implementing rcu_barrier()
 
diff --git a/Documentation/RCU/torture.txt b/Documentation/RCU/torture.txt
index a342b6e..9dba3bb 100644
--- a/Documentation/RCU/torture.txt
+++ b/Documentation/RCU/torture.txt
@@ -76,8 +76,10 @@ torture_type	The type of RCU to test: "rcu" for the rcu_read_lock() API,
 		"rcu_sync" for rcu_read_lock() with synchronous reclamation,
 		"rcu_bh" for the rcu_read_lock_bh() API, "rcu_bh_sync" for
 		rcu_read_lock_bh() with synchronous reclamation, "srcu" for
-		the "srcu_read_lock()" API, and "sched" for the use of
-		preempt_disable() together with synchronize_sched().
+		the "srcu_read_lock()" API, "sched" for the use of
+		preempt_disable() together with synchronize_sched(),
+		and "sched_expedited" for the use of preempt_disable()
+		with synchronize_sched_expedited().
 
 verbose		Enable debug printk()s.  Default is disabled.
 
@@ -162,6 +164,23 @@ of the "old" and "current" counters for the corresponding CPU.  The
 "idx" value maps the "old" and "current" values to the underlying array,
 and is useful for debugging.
 
+Similarly, sched_expedited RCU provides the following:
+
+	sched_expedited-torture: rtc: d0000000016c1880 ver: 1090796 tfle: 0 rta: 1090796 rtaf: 0 rtf: 1090787 rtmbe: 0 nt: 27713319
+	sched_expedited-torture: Reader Pipe:  12660320201 95875 0 0 0 0 0 0 0 0 0
+	sched_expedited-torture: Reader Batch:  12660424885 0 0 0 0 0 0 0 0 0 0
+	sched_expedited-torture: Free-Block Circulation:  1090795 1090795 1090794 1090793 1090792 1090791 1090790 1090789 1090788 1090787 0
+	state: -1 / 0:0 3:0 4:0
+
+As before, the first four lines are similar to those for RCU.
+The last line shows the task-migration state.  The first number is
+-1 if synchronize_sched_expedited() is idle, -2 if in the process of
+posting wakeups to the migration kthreads, and N when waiting on CPU N.
+Each of the colon-separated fields following the "/" is a CPU:state pair.
+Valid states are "0" for idle, "1" for waiting for quiescent state,
+"2" for passed through quiescent state, and "3" when a race with a
+CPU-hotplug event forces use of the synchronize_sched() primitive.
+
 
 USAGE
 
diff --git a/Documentation/RCU/whatisRCU.txt b/Documentation/RCU/whatisRCU.txt
index 9617082..97ded24 100644
--- a/Documentation/RCU/whatisRCU.txt
+++ b/Documentation/RCU/whatisRCU.txt
@@ -785,6 +785,7 @@ RCU pointer/list traversal:
 	rcu_dereference
 	list_for_each_entry_rcu
 	hlist_for_each_entry_rcu
+	hlist_nulls_for_each_entry_rcu
 
 	list_for_each_continue_rcu	(to be deprecated in favor of new
 					 list_for_each_entry_continue_rcu)
@@ -807,19 +808,23 @@ RCU:	Critical sections	Grace period		Barrier
 
 	rcu_read_lock		synchronize_net		rcu_barrier
 	rcu_read_unlock		synchronize_rcu
+				synchronize_rcu_expedited
 				call_rcu
 
 
 bh:	Critical sections	Grace period		Barrier
 
 	rcu_read_lock_bh	call_rcu_bh		rcu_barrier_bh
-	rcu_read_unlock_bh
+	rcu_read_unlock_bh	synchronize_rcu_bh
+				synchronize_rcu_bh_expedited
 
 
 sched:	Critical sections	Grace period		Barrier
 
-	[preempt_disable]	synchronize_sched	rcu_barrier_sched
-	[and friends]		call_rcu_sched
+	rcu_read_lock_sched	synchronize_sched	rcu_barrier_sched
+	rcu_read_unlock_sched	call_rcu_sched
+	[preempt_disable]	synchronize_sched_expedited
+	[and friends]
 
 
 SRCU:	Critical sections	Grace period		Barrier
@@ -827,6 +832,9 @@ SRCU:	Critical sections	Grace period		Barrier
 	srcu_read_lock		synchronize_srcu	N/A
 	srcu_read_unlock
 
+SRCU:	Initialization/cleanup
+	init_srcu_struct
+	cleanup_srcu_struct
 
 See the comment headers in the source code (or the docbook generated
 from them) for more information.
-- 
1.5.2.5

