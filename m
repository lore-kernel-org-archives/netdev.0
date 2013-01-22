From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 09/15] drivers/net: delete old 8 bit ISA Racal ni5010 support.
Date: Mon, 21 Jan 2013 20:46:16 -0500
Message-ID: <1358819182-28032-10-git-send-email-paul.gortmaker@windriver.com>
References: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Andreas Mohr <andi@lisas.de>,
	Jan-Pascal van Best <janpascal@vanbest.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:45385 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753242Ab3AVBqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 20:46:46 -0500
In-Reply-To: <1358819182-28032-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These cards were only available in 8bit format, and in addition
they only had AUI and BNC(10-Base2) interfaces (i.e. no RJ-45).

In fact, they are so rare, that an internet search on these old
cards almost comes up empty, unless the "Micom interlan" name
is used.

This puts them in the equivalent domain as the 3c501, so there
should be no strong opposition to the driver removal, as nobody
is seriously using 3.9+ with 8 bit ISA hardware.

In doing so, the whole "ethernet/racal" category becomes empty,
so we clean up the Makefile/Kconfig and subdir appropriately.

Cc: Andreas Mohr <andi@lisas.de>
Cc: Jan-Pascal van Best <janpascal@vanbest.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 MAINTAINERS                         |   7 -
 drivers/net/Space.c                 |   4 -
 drivers/net/ethernet/Kconfig        |   1 -
 drivers/net/ethernet/Makefile       |   1 -
 drivers/net/ethernet/racal/Kconfig  |  33 --
 drivers/net/ethernet/racal/Makefile |   5 -
 drivers/net/ethernet/racal/ni5010.c | 771 ------------------------------------
 drivers/net/ethernet/racal/ni5010.h | 144 -------
 8 files changed, 966 deletions(-)
 delete mode 100644 drivers/net/ethernet/racal/Kconfig
 delete mode 100644 drivers/net/ethernet/racal/Makefile
 delete mode 100644 drivers/net/ethernet/racal/ni5010.c
 delete mode 100644 drivers/net/ethernet/racal/ni5010.h

diff --git a/MAINTAINERS b/MAINTAINERS
index cd5b31f..88866e6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5370,13 +5370,6 @@ F:	include/linux/sunrpc/
 F:	include/uapi/linux/nfs*
 F:	include/uapi/linux/sunrpc/
 
-NI5010 NETWORK DRIVER
-M:	Jan-Pascal van Best <janpascal@vanbest.org>
-M:	Andreas Mohr <andi@lisas.de>
-L:	netdev@vger.kernel.org
-S:	Maintained
-F:	drivers/net/ethernet/racal/ni5010.*
-
 NILFS2 FILESYSTEM
 M:	KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
 L:	linux-nilfs@vger.kernel.org
diff --git a/drivers/net/Space.c b/drivers/net/Space.c
index b69dac1..4141c64 100644
--- a/drivers/net/Space.c
+++ b/drivers/net/Space.c
@@ -50,7 +50,6 @@ extern struct net_device *eth16i_probe(int unit);
 extern struct net_device *i82596_probe(int unit);
 extern struct net_device *ewrk3_probe(int unit);
 extern struct net_device *e2100_probe(int unit);
-extern struct net_device *ni5010_probe(int unit);
 extern struct net_device *ni65_probe(int unit);
 extern struct net_device *sonic_probe(int unit);
 extern struct net_device *seeq8005_probe(int unit);
@@ -153,9 +152,6 @@ static struct devprobe2 isa_probes[] __initdata = {
 #if defined(CONFIG_MVME16x_NET) || defined(CONFIG_BVME6000_NET)	/* Intel I82596 */
 	{i82596_probe, 0},
 #endif
-#ifdef CONFIG_NI5010
-	{ni5010_probe, 0},
-#endif
 #ifdef CONFIG_NI65
 	{ni65_probe, 0},
 #endif
diff --git a/drivers/net/ethernet/Kconfig b/drivers/net/ethernet/Kconfig
index e4ff389..ed956e0 100644
--- a/drivers/net/ethernet/Kconfig
+++ b/drivers/net/ethernet/Kconfig
@@ -135,7 +135,6 @@ config ETHOC
 source "drivers/net/ethernet/packetengines/Kconfig"
 source "drivers/net/ethernet/pasemi/Kconfig"
 source "drivers/net/ethernet/qlogic/Kconfig"
-source "drivers/net/ethernet/racal/Kconfig"
 source "drivers/net/ethernet/realtek/Kconfig"
 source "drivers/net/ethernet/renesas/Kconfig"
 source "drivers/net/ethernet/rdc/Kconfig"
diff --git a/drivers/net/ethernet/Makefile b/drivers/net/ethernet/Makefile
index d447307..8268d85 100644
--- a/drivers/net/ethernet/Makefile
+++ b/drivers/net/ethernet/Makefile
@@ -53,7 +53,6 @@ obj-$(CONFIG_ETHOC) += ethoc.o
 obj-$(CONFIG_NET_PACKET_ENGINE) += packetengines/
 obj-$(CONFIG_NET_VENDOR_PASEMI) += pasemi/
 obj-$(CONFIG_NET_VENDOR_QLOGIC) += qlogic/
-obj-$(CONFIG_NET_VENDOR_RACAL) += racal/
 obj-$(CONFIG_NET_VENDOR_REALTEK) += realtek/
 obj-$(CONFIG_SH_ETH) += renesas/
 obj-$(CONFIG_NET_VENDOR_RDC) += rdc/
diff --git a/drivers/net/ethernet/racal/Kconfig b/drivers/net/ethernet/racal/Kconfig
deleted file mode 100644
index 01969e0..0000000
diff --git a/drivers/net/ethernet/racal/Makefile b/drivers/net/ethernet/racal/Makefile
deleted file mode 100644
index 1e210ca..0000000
diff --git a/drivers/net/ethernet/racal/ni5010.c b/drivers/net/ethernet/racal/ni5010.c
deleted file mode 100644
index 8079822..0000000
diff --git a/drivers/net/ethernet/racal/ni5010.h b/drivers/net/ethernet/racal/ni5010.h
deleted file mode 100644
index e10e717..0000000
-- 
1.8.1
