From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 08/10] net: bcmgenet: hook into the build system
Date: Thu, 13 Feb 2014 14:53:47 -0800
Message-ID: <1392332029-24669-9-git-send-email-f.fainelli@gmail.com>
References: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <devicetree@vger.kernel.org>,
	<cernekee@gmail.com>, <mark.rutland@arm.com>,
	<romieu@fr.zoreil.com>, Florian Fainelli <f.fainelli@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:51626 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939AbaBMWz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:55:29 -0500
In-Reply-To: <1392332029-24669-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a new configuration symbol: CONFIG_BCMGENET which allows
us to build the Broadcom GENET driver and hook the driver files into the
build system.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v1, v2:
- rebased against net-next/master

 drivers/net/ethernet/broadcom/Kconfig        | 10 ++++++++++
 drivers/net/ethernet/broadcom/Makefile       |  1 +
 drivers/net/ethernet/broadcom/genet/Makefile |  2 ++
 3 files changed, 13 insertions(+)
 create mode 100644 drivers/net/ethernet/broadcom/genet/Makefile

diff --git a/drivers/net/ethernet/broadcom/Kconfig b/drivers/net/ethernet/broadcom/Kconfig
index 3f97d9f..a489712 100644
--- a/drivers/net/ethernet/broadcom/Kconfig
+++ b/drivers/net/ethernet/broadcom/Kconfig
@@ -60,6 +60,16 @@ config BCM63XX_ENET
 	  This driver supports the ethernet MACs in the Broadcom 63xx
 	  MIPS chipset family (BCM63XX).
 
+config BCMGENET
+	tristate "Broadcom GENET internal MAC support"
+	select MII
+	select PHYLIB
+	select FIXED_PHY
+	select BCM7XXX_PHY
+	help
+	  This driver supports the built-in Ethernet MACs found in the
+	  Broadcom BCM7xxx Set Top Box family chipset.
+
 config BNX2
 	tristate "Broadcom NetXtremeII support"
 	depends on PCI
diff --git a/drivers/net/ethernet/broadcom/Makefile b/drivers/net/ethernet/broadcom/Makefile
index 68efa1a..fd639a0 100644
--- a/drivers/net/ethernet/broadcom/Makefile
+++ b/drivers/net/ethernet/broadcom/Makefile
@@ -4,6 +4,7 @@
 
 obj-$(CONFIG_B44) += b44.o
 obj-$(CONFIG_BCM63XX_ENET) += bcm63xx_enet.o
+obj-$(CONFIG_BCMGENET) += genet/
 obj-$(CONFIG_BNX2) += bnx2.o
 obj-$(CONFIG_CNIC) += cnic.o
 obj-$(CONFIG_BNX2X) += bnx2x/
diff --git a/drivers/net/ethernet/broadcom/genet/Makefile b/drivers/net/ethernet/broadcom/genet/Makefile
new file mode 100644
index 0000000..31f55a9
--- /dev/null
+++ b/drivers/net/ethernet/broadcom/genet/Makefile
@@ -0,0 +1,2 @@
+obj-$(CONFIG_BCMGENET) += genet.o
+genet-objs := bcmgenet.o bcmmii.o
-- 
1.8.3.2
