From: carbonated beverage <ramune@net-ronin.org>
Subject: compile fix net/core/dev.c
Date: Mon, 21 Jun 2004 05:06:43 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040621120643.GA8827__9852.52221948958$1087821006@net-ronin.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
Resent-Message-Id: <20040621.211617.499265868.yoshfuji@linux-ipv6.org>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Tiny patch to make gcc 2.95.4 happy.  Declare a variable before code
preceeds it.

-- DN
Daniel

===== net/core/dev.c 1.147 vs edited =====
--- 1.147/net/core/dev.c	2004-06-20 17:35:52 -07:00
+++ edited/net/core/dev.c	2004-06-21 04:36:04 -07:00
@@ -1406,8 +1406,10 @@
 	   Either shot noqueue qdisc, it is even simpler 8)
 	 */
 	if (dev->flags & IFF_UP) {
+		int cpu;
+
 		preempt_disable();
-		int cpu = smp_processor_id();
+		cpu = smp_processor_id();
 
 		if (dev->xmit_lock_owner != cpu) {
 
