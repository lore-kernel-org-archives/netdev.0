From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 11/15] drivers/net: delete old fujitsu based eth16i driver
Date: Mon, 21 Jan 2013 20:46:18 -0500
Message-ID: <1358819182-28032-12-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Mika Kuoppala <miku@iki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45393 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753366Ab3AVBqt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:49 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is another driver for relatively rare 10Mbit hardware that
originated in the early 1990's.  So we select it for removal at
this point in time as well.

Cc: Mika Kuoppala <miku@iki.fi>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 MAINTAINERS                           |    5 -
 drivers/net/Space.c                   |    4 -
 drivers/net/ethernet/fujitsu/Kconfig  |   11 -
 drivers/net/ethernet/fujitsu/Makefile |    1 -
 drivers/net/ethernet/fujitsu/eth16i.c | 1483 ---------------------------------
 5 files changed, 1504 deletions(-)
 delete mode 100644 drivers/net/ethernet/fujitsu/eth16i.c

diff --git a/MAINTAINERS b/MAINTAINERS
index 88866e6..a7aadea 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2974,11 +2974,6 @@ S:	Maintained
 F:	include/linux/netfilter_bridge/
 F:	net/bridge/
 
-ETHERTEAM 16I DRIVER
-M:	Mika Kuoppala <miku@iki.fi>
-S:	Maintained
-F:	drivers/net/ethernet/fujitsu/eth16i.c
-
 EXT2 FILE SYSTEM
 M:	Jan Kara <jack@suse.cz>
 L:	linux-ext4@vger.kernel.org
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index e7d916d5..15de20b 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -45,7 +45,6 @@ extern struct net_device *ne_probe(int unit);
 extern struct net_device *hp_probe(int unit);
 extern struct net_device *hp_plus_probe(int unit);
 extern struct net_device *fmv18x_probe(int unit);
-extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
@@ -139,9 +138,6 @@ static struct devprobe2 isa_probes[] __initdata = {
  	{cs89x0_probe, 0},
 #endif
 #endif
-#ifdef CONFIG_ETH16I
-	{eth16i_probe, 0},	/* ICL EtherTeam 16i/32 */
-#endif
 #ifdef CONFIG_EWRK3             /* DEC EtherWORKS 3 */
     	{ewrk3_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/fujitsu/Kconfig b/drivers/net/ethernet/fujitsu/Kconfig
index af114fd..c6a8762 100644
--- a/drivers/net/ethernet/fujitsu/Kconfig
+++ b/drivers/net/ethernet/fujitsu/Kconfig
@@ -28,15 +28,4 @@ config PCMCIA_FMVJ18X
 	  To compile this driver as a module, choose M here: the module will be
 	  called fmvj18x_cs.  If unsure, say N.
 
-config ETH16I
-	tristate "ICL EtherTeam 16i/32 support"
-	depends on ISA
-	---help---
-	  If you have a network (Ethernet) card of this type, say Y and read
-	  the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
-
-	  To compile this driver as a module, choose M here. The module
-	  will be called eth16i.
-
 endif # NET_VENDOR_FUJITSU
diff --git a/drivers/net/ethernet/fujitsu/Makefile b/drivers/net/ethernet/fujitsu/Makefile
index e54d0af..21561fd 100644
--- a/drivers/net/ethernet/fujitsu/Makefile
+++ b/drivers/net/ethernet/fujitsu/Makefile
@@ -2,5 +2,4 @@
 # Makefile for the Fujitsu network device drivers.
 #
 
-obj-$(CONFIG_ETH16I) += eth16i.o
 obj-$(CONFIG_PCMCIA_FMVJ18X) += fmvj18x_cs.o
diff --git a/drivers/net/ethernet/fujitsu/eth16i.c b/drivers/net/ethernet/fujitsu/eth16i.c
deleted file mode 100644
index a992d1f..0000000
-- 
1.8.1
