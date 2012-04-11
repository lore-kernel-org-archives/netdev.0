From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 3/8] r6040: add a MAC operation timeout define
Date: Wed, 11 Apr 2012 19:18:38 +0200
Message-ID: <1334164723-9627-4-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45794 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760773Ab2DKRUN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:13 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2048 is the usual value for busy-waiting on a register r/w, define it
as MAC_DEF_TIMEOUT and use it where it is appropriate.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index fa29596..9ffbf6e 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -137,6 +137,8 @@
 #define MBCR_DEFAULT	0x012A	/* MAC Bus Control Register */
 #define MCAST_MAX	3	/* Max number multicast addresses to filter */
 
+#define MAC_DEF_TIMEOUT	2048	/* Default MAC read/write operation timeout */
+
 /* Descriptor status */
 #define DSC_OWNER_MAC	0x8000	/* MAC is the owner of this descriptor */
 #define DSC_RX_OK	0x4000	/* RX was successful */
@@ -204,7 +206,7 @@ static char version[] __devinitdata = DRV_NAME
 /* Read a word data from PHY Chip */
 static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 {
-	int limit = 2048;
+	int limit = MAC_DEF_TIMEOUT;
 	u16 cmd;
 
 	iowrite16(MDIO_READ + reg + (phy_addr << 8), ioaddr + MMDIO);
@@ -222,7 +224,7 @@ static int r6040_phy_read(void __iomem *ioaddr, int phy_addr, int reg)
 static void r6040_phy_write(void __iomem *ioaddr,
 					int phy_addr, int reg, u16 val)
 {
-	int limit = 2048;
+	int limit = MAC_DEF_TIMEOUT;
 	u16 cmd;
 
 	iowrite16(val, ioaddr + MMWD);
@@ -361,7 +363,7 @@ err_exit:
 static void r6040_reset_mac(struct r6040_private *lp)
 {
 	void __iomem *ioaddr = lp->base;
-	int limit = 2048;
+	int limit = MAC_DEF_TIMEOUT;
 	u16 cmd;
 
 	iowrite16(MAC_RST, ioaddr + MCR1);
-- 
1.7.5.4
