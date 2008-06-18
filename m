From: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
Subject: [PATCH] net: sh_eth: Fix compile error sh_eth
Date: Wed, 18 Jun 2008 18:32:09 +0900
Message-ID: <4858D619.80403@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Paul Mundt <lethal@linux-sh.org>,
	Linux-sh <linux-sh@vger.kernel.org>, jeff@garzik.org,
	shimoda.yoshihiro@renesas.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.renesas.com ([202.234.163.13]:53123 "EHLO
	mail06.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751702AbYFRJc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 05:32:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix compile error on sh_eth and remove base address macro.

Signed-off-by: Nobuhiro Iwamatsu <iwamatsu.nobuhiro@renesas.com>
---
 drivers/net/sh_eth.c |    4 ++--
 drivers/net/sh_eth.h |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index f64d987..37f3116 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -322,7 +322,7 @@ static int sh_eth_dev_init(struct net_device *ndev)
 	ctrl_outl((FIFO_SIZE_T | FIFO_SIZE_R), ioaddr + FDR);
 	ctrl_outl(0, ioaddr + TFTR);

-	ctrl_outl(RMCR_RST, ioaddr + RMCR);
+	ctrl_outl(0, ioaddr + RMCR);

 	rx_int_var = mdp->rx_int_var = DESC_I_RINT8 | DESC_I_RINT5;
 	tx_int_var = mdp->tx_int_var = DESC_I_TINT2;
@@ -994,7 +994,7 @@ static int sh_mdio_init(struct net_device *ndev, int id)
 	/* Hook up MII support for ethtool */
 	mdp->mii_bus->name = "sh_mii";
 	mdp->mii_bus->dev = &ndev->dev;
-	mdp->mii_bus->id = id;
+	mdp->mii_bus->id[0] = id;

 	/* PHY IRQ */
 	mdp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);
diff --git a/drivers/net/sh_eth.h b/drivers/net/sh_eth.h
index ca2db6b..e01e1c3 100644
--- a/drivers/net/sh_eth.h
+++ b/drivers/net/sh_eth.h
@@ -40,8 +40,6 @@
 #define PKT_BUF_SZ		1538

 /* Chip Base Address */
-#define SH_ETH0_BASE 0xA7000000
-#define SH_ETH1_BASE 0xA7000400
 #define SH_TSU_ADDR 0xA7000804

 /* Chip Registers */
@@ -462,3 +460,5 @@ static void swaps(char *src, int len)
 		*p = swab32(*p);
 #endif
 }
+
+#endif
-- 
1.5.5.1


