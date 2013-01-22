From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 10/15] drivers/net: delete at1700 ISA 10Mbit driver
Date: Mon, 21 Jan 2013 20:46:17 -0500
Message-ID: <1358819182-28032-11-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45358 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752939Ab3AVBqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:40 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These Fujitsu MB86965 based ISA 10Mbit cards were another of the
relatively rare cards dating from the early 1990s that for one reason
or another didn't seem to get a lot of use in linux.  So we retire it
now with a reasonable degree of confidence that it won't impact anyone.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/Space.c                   |   4 -
 drivers/net/ethernet/fujitsu/Kconfig  |  12 -
 drivers/net/ethernet/fujitsu/Makefile |   1 -
 drivers/net/ethernet/fujitsu/at1700.c | 791 ----------------------------------
 4 files changed, 808 deletions(-)
 delete mode 100644 drivers/net/ethernet/fujitsu/at1700.c

diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index 4141c64..e7d916d5 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -44,7 +44,6 @@ extern struct net_device *el2_probe(int unit);
 extern struct net_device *ne_probe(int unit);
 extern struct net_device *hp_probe(int unit);
 extern struct net_device *hp_plus_probe(int unit);
-extern struct net_device *at1700_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
 extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
@@ -140,9 +139,6 @@ static struct devprobe2 isa_probes[] __initdata = {
  	{cs89x0_probe, 0},
 #endif
 #endif
-#ifdef CONFIG_AT1700
-	{at1700_probe, 0},
-#endif
 #ifdef CONFIG_ETH16I
 	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
 #endif
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index aca1568..af114fd 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -17,18 +17,6 @@ config NET_VENDOR_FUJITSU
 
 if NET_VENDOR_FUJITSU
 
-config AT1700
-	tristate "AT1700/1720 support (EXPERIMENTAL)"
-	depends on ISA && EXPERIMENTAL
-	select CRC32
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called at1700.
-
 config PCMCIA_FMVJ18X
 	tristate "Fujitsu FMV-J18x PCMCIA support"
 	depends on PCMCIA
diff --git a/drivers/net/ethernet/fujitsu/Makefile b/drivers/net/ethernet/fujitsu/Makefile
index 2730ae6..e54d0af 100644
--- a/drivers/net/ethernet/fujitsu/Makefile
+++ b/drivers/net/ethernet/fujitsu/Makefile
@@ -2,6 +2,5 @@
 # Makefile for the Fujitsu network device drivers.
 #
 
-obj-$(CONFIG_AT1700) += at1700.o
 obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_PCMCIA_FMVJ18X) += fmvj18x_cs.o
diff --git a/drivers/net/ethernet/fujitsu/at1700.c b/drivers/net/ethernet/fujitsu/at1700.c
deleted file mode 100644
index 4b80dc4..0000000
-- 
1.8.1
