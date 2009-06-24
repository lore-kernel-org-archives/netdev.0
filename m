From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH -tip 3/3] synchronize_sched_expedited() rcutorture doc
Date: Wed, 24 Jun 2009 09:48:19 -0700
Message-ID: <20090624164819.GC13796@linux.vnet.ibm.com>
References: <20090624164535.GA13334@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090624164535.GA13334@linux.vnet.ibm.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch updates the rcutorture documentation to include updated
output format.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 torture.txt |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/Documentation/RCU/torture.txt b/Documentation/RCU/torture.txt
index a342b6e..f39a3fc 100644
--- a/Documentation/RCU/torture.txt
+++ b/Documentation/RCU/torture.txt
@@ -162,6 +162,23 @@ of the "old" and "current" counters for the corresponding CPU.  The
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
 
