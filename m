From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2.6] (2/4) netem - comment update
Date: Wed, 25 Aug 2004 10:57:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040825105726.5742246e@dell_ss3.pdx.osdl.net>
References: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040825105339.30210e84@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Update comments in netem.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/net/sched/sch_netem.c b/net/sched/sch_netem.c
--- a/net/sched/sch_netem.c	2004-08-24 14:43:05 -07:00
+++ b/net/sched/sch_netem.c	2004-08-24 14:43:05 -07:00
@@ -6,6 +6,9 @@
  * 		as published by the Free Software Foundation; either version
  * 		2 of the License, or (at your option) any later version.
  *
+ *  		Many of the algorithms and ideas for this came from
+ *		NIST Net which is not copyrighted. 
+ *
  * Authors:	Stephen Hemminger <shemminger@osdl.org>
  *		Catalin(ux aka Dino) BOIE <catab at umbrella dot ro>
  */
@@ -22,11 +25,31 @@
 
 #include <net/pkt_sched.h>
 
-/*	Network emulator
- *
- *	This scheduler can alters spacing and order
- *	Similar to NISTnet and BSD Dummynet.
- */
+/*	Network Emulation Queuing algorithm.
+	====================================
+
+	Sources: [1] Mark Carson, Darrin Santay, "NIST Net - A Linux-based
+		 Network Emulation Tool
+		 [2] Luigi Rizzo, DummyNet for FreeBSD
+
+	 ----------------------------------------------------------------
+
+	 This started out as a simple way to delay outgoing packets to
+	 test TCP but has grown to include most of the functionality
+	 of a full blown network emulator like NISTnet. It can delay
+	 packets and add random jitter (and correlation). The random
+	 distribution can be loaded from a table as well to provide
+	 normal, Pareto, or experimental curves. Packet loss,
+	 duplication, and reordering can also be emulated.
+
+	 This qdisc does not do classification that can be handled in
+	 layering other disciplines.  It does not need to do bandwidth
+	 control either since that can be handled by using token
+	 bucket or other rate control.
+
+	 The simulator is limited by the Linux timer resolution
+	 and will create packet bursts on the HZ boundary (1ms).
+*/
 
 struct netem_sched_data {
 	struct Qdisc	*qdisc;
