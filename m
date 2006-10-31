From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] make sch_fifo.o available when CONFIG_NET_SCHED is not set
Date: Tue, 31 Oct 2006 08:53:24 -0800
Message-ID: <20061031165324.GA20271@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:40137 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1423565AbWJaQx0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Oct 2006 11:53:26 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="config_net_sch_fifo.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You may see this discussion for more info:
http://marc.theaimsgroup.com/?t=116181395100002&r=1&w=2

----
Based on a patch by Patrick McHardy.

Add a new option, NET_SCH_FIFO, which provides a simple fifo qdisc
without requiring CONFIG_NET_SCHED.

The d80211 stack needs a generic fifo qdisc for WME.  At present it
uses net/d80211/fifo_qdisc.c which is functionally equivalent to
sch_fifo.c.  This patch will allow the d80211 stack to remove
net/d80211/fifo_qdisc.c and use sch_fifo.c instead. 

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/sched/Kconfig
===================================================================
--- wireless-dev.orig/net/sched/Kconfig
+++ wireless-dev/net/sched/Kconfig
@@ -6,6 +6,7 @@ menu "QoS and/or fair queueing"
 
 config NET_SCHED
 	bool "QoS and/or fair queueing"
+	select NET_SCH_FIFO
 	---help---
 	  When the kernel has several packets to send out over a network
 	  device, it has to decide which ones to send first, which ones to
@@ -40,6 +41,15 @@ config NET_SCHED
 	  The available schedulers are listed in the following questions; you
 	  can say Y to as many as you like. If unsure, say N now.
 
+config NET_SCH_FIFO
+	tristate "Simple Fifo Qdisc (PFIFO, BFIFO)"
+	---help---
+	  Say Y here if you want to use the simple pfifo or bfifo
+	  packet scheduling algorithms.
+
+	  To compile this code as a module, choose M here: the
+	  module will be called sch_fifo.
+
 if NET_SCHED
 
 choice
Index: wireless-dev/net/sched/Makefile
===================================================================
--- wireless-dev.orig/net/sched/Makefile
+++ wireless-dev/net/sched/Makefile
@@ -4,7 +4,7 @@
 
 obj-y	:= sch_generic.o
 
-obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_fifo.o sch_blackhole.o
+obj-$(CONFIG_NET_SCHED)		+= sch_api.o sch_blackhole.o
 obj-$(CONFIG_NET_CLS)		+= cls_api.o
 obj-$(CONFIG_NET_CLS_ACT)	+= act_api.o
 obj-$(CONFIG_NET_ACT_POLICE)	+= act_police.o
@@ -14,6 +14,7 @@ obj-$(CONFIG_NET_ACT_MIRRED)	+= act_mirr
 obj-$(CONFIG_NET_ACT_IPT)	+= act_ipt.o
 obj-$(CONFIG_NET_ACT_PEDIT)	+= act_pedit.o
 obj-$(CONFIG_NET_ACT_SIMP)	+= act_simple.o
+obj-$(CONFIG_NET_SCH_FIFO)	+= sch_fifo.o
 obj-$(CONFIG_NET_SCH_CBQ)	+= sch_cbq.o
 obj-$(CONFIG_NET_SCH_HTB)	+= sch_htb.o
 obj-$(CONFIG_NET_SCH_HPFQ)	+= sch_hpfq.o

--
