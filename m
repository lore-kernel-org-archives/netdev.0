From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/15] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Mon, 21 Jan 2013 20:46:10 -0500
Message-ID: <1358819182-28032-4-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Alan Cox <alan@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45328 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab3AVBqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:37 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was amusing that linux was able to make use of this 1980's
technology on machines long past its intended lifespan, but
it probably should go now.

To set some context, the 3c501 was designed in the 1980's to be
used on 8088 PC-XT 8bit ISA machines.  It was built using a large
number of discrete TTL components and truly looks like a relic
of the ancient past before large scale integration was common.

But from a functional point of view, the real issue, as stated
in the (also obsolete) Ethernet-HowTo, is that "...the 3c501 can
only do one thing at a time -- while you are removing one packet
from the single-packet buffer it cannot receive another packet,
nor can it receive a packet while loading a transmit packet."

You know things are not good when the Kconfig help text suggests
you make a cron job doing a ping every minute.

Hardware that old and crippled is simply not going to be used by
anyone in a time where 10 year old 100Mbit PCI cards (that are
still functional) are largely give-away items.

Cc: Alan Cox <alan@linux.intel.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                |   4 -
 drivers/net/ethernet/3com/3c501.c  | 897 -------------------------------------
 drivers/net/ethernet/3com/3c501.h  |  91 ----
 drivers/net/ethernet/3com/Kconfig  |  14 -
 drivers/net/ethernet/3com/Makefile |   1 -
 5 files changed, 1007 deletions(-)
 delete mode 100644 drivers/net/ethernet/3com/3c501.c
 delete mode 100644 drivers/net/ethernet/3com/3c501.h

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index c6e5194..64cd86e 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -51,7 +51,6 @@ extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
-extern struct net_device *el1_probe(int unit);
 extern struct net_device *el16_probe(int unit);
 extern struct net_device *elplus_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
@@ -168,9 +167,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_EL1		/* 3c501 */
-	{el1_probe, 0},
-#endif
 #ifdef CONFIG_EL16		/* 3c507 */
 	{el16_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/3com/3c501.c b/drivers/net/ethernet/3com/3c501.c
deleted file mode 100644
index 9abd9a7..0000000
diff --git a/drivers/net/ethernet/3com/3c501.h b/drivers/net/ethernet/3com/3c501.h
deleted file mode 100644
index 183fd55..0000000
diff --git a/drivers/net/ethernet/3com/Kconfig b/drivers/net/ethernet/3com/Kconfig
index 8c417ed..1c71c76 100644
--- a/drivers/net/ethernet/3com/Kconfig
+++ b/drivers/net/ethernet/3com/Kconfig
@@ -18,20 +18,6 @@ config NET_VENDOR_3COM
 
 if NET_VENDOR_3COM
 
-config EL1
-	tristate "3c501 \"EtherLink\" support"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.  Also, consider buying a
-	  new card, since the 3c501 is slow, broken, and obsolete: you will
-	  have problems.  Some people suggest to ping ("man ping") a nearby
-	  machine every minute ("man cron") when using this card.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called 3c501.
-
 config EL3
 	tristate "3c509/3c579 \"EtherLink III\" support"
 	depends on (ISA || EISA)
diff --git a/drivers/net/ethernet/3com/Makefile b/drivers/net/ethernet/3com/Makefile
index 1e5382a..74046af 100644
--- a/drivers/net/ethernet/3com/Makefile
+++ b/drivers/net/ethernet/3com/Makefile
@@ -2,7 +2,6 @@
 # Makefile for the 3Com Ethernet device drivers
 #
 
-obj-$(CONFIG_EL1) += 3c501.o
 obj-$(CONFIG_EL3) += 3c509.o
 obj-$(CONFIG_3C515) += 3c515.o
 obj-$(CONFIG_PCMCIA_3C589) += 3c589_cs.o
-- 
1.8.1
