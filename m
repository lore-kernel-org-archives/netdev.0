From: David Kimdon <david.kimdon@devicescape.com>
Subject: Re: [patch] make sch_fifo.o available when CONFIG_NET_SCHED is not set
Date: Wed, 8 Nov 2006 06:06:18 -0800
Message-ID: <20061108140618.GA17925@devicescape.com>
References: <20061031165324.GA20271@devicescape.com> <20061031232400.GE12964@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:40637 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S965767AbWKHOGV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 09:06:21 -0500
To: Thomas Graf <tgraf@suug.ch>
Content-Disposition: inline
In-Reply-To: <20061031232400.GE12964@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 01, 2006 at 12:24:01AM +0100, Thomas Graf wrote:
> I think NET_SCH_FIFO doesn't need a help text, should be invisible
> to the user. Just select it from NET_SCHED and d80211.

sure, here is a new one:

----
Based on patch by Patrick McHardy.

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
@@ -40,6 +41,9 @@ config NET_SCHED
 	  The available schedulers are listed in the following questions; you
 	  can say Y to as many as you like. If unsure, say N now.
 
+config NET_SCH_FIFO
+	bool
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
