From: Patrick McHardy <kaber@trash.net>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Thu, 26 Oct 2006 04:04:28 +0200
Message-ID: <454017AC.7010009@trash.net>
References: <C86180A8C204554D8A3323D8F6B0A29F018B54D4@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090606080207060806000102"
Cc: David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:65012 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S965261AbWJZCEy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 22:04:54 -0400
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B54D4@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090606080207060806000102
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Simon Barber wrote:
> Pfifo_fast does not make sense because the 802.11 qdisc already
> categorizes the frames based on DSCP. The better thing would be to
> extract the pfifo qdisc so that it does not require NET_SCHED, but this
> is more work.

This patch should be enough to use it without NET_SCHED. You could of
course also allow modular build.


--------------090606080207060806000102
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

diff --git a/net/d80211/Kconfig b/net/d80211/Kconfig
index 0f07d41..2cb79c1 100644
--- a/net/d80211/Kconfig
+++ b/net/d80211/Kconfig
@@ -3,6 +3,7 @@ config D80211
 	select CRYPTO
 	select CRYPTO_ARC4
 	select CRYPTO_AES
+	select NET_SCH_FIFO
 	---help---
 	This option enables the hardware independent IEEE 802.11
 	networking stack.
diff --git a/net/sched/Kconfig b/net/sched/Kconfig
index 8298ea9..1d8b0dc 100644
--- a/net/sched/Kconfig
+++ b/net/sched/Kconfig
@@ -40,6 +40,10 @@ config NET_SCHED
 	  The available schedulers are listed in the following questions; you
 	  can say Y to as many as you like. If unsure, say N now.
 
+config NET_SCH_FIFO
+	bool
+	default y if NET_SCHED=y
+
 if NET_SCHED
 
 choice
diff --git a/net/sched/Makefile b/net/sched/Makefile
index 0f06aec..ff2d6e5 100644
--- a/net/sched/Makefile
+++ b/net/sched/Makefile
@@ -4,7 +4,7 @@ #
 
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

--------------090606080207060806000102--
