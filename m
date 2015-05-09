From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: fec: add support of ethtool get_regs
Date: Sat,  9 May 2015 22:52:08 +0200
Message-ID: <1431204728-16754-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, B38611@freescale.com,
	rmk+kernel@arm.linux.org.uk, Frank.Li@freescale.com,
	LW@KARO-electronics.de
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This enables the ethtool's "-d" and "--register-dump"
options for fec devices.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/freescale/fec_main.c |   24 ++++++++++++++++++++++++
 1 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 66d47e4..07aee1f 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -2118,6 +2118,28 @@ static void fec_enet_get_drvinfo(struct net_device *ndev,
 	strlcpy(info->bus_info, dev_name(&ndev->dev), sizeof(info->bus_info));
 }
 
+static int fec_enet_get_regs_len(struct net_device *ndev)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+	struct resource *r;
+	int s = 0;
+
+	r = platform_get_resource(fep->pdev, IORESOURCE_MEM, 0);
+	if (r) {
+		s = resource_size(r);
+	}
+
+	return s;
+}
+
+static void fec_enet_get_regs(struct net_device *ndev,
+			      struct ethtool_regs *regs, void *regbuf)
+{
+	struct fec_enet_private *fep = netdev_priv(ndev);
+
+	memcpy_fromio(regbuf, fep->hwp, regs->len);
+}
+
 static int fec_enet_get_ts_info(struct net_device *ndev,
 				struct ethtool_ts_info *info)
 {
@@ -2515,6 +2537,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops = {
 	.get_settings		= fec_enet_get_settings,
 	.set_settings		= fec_enet_set_settings,
 	.get_drvinfo		= fec_enet_get_drvinfo,
+	.get_regs_len		= fec_enet_get_regs_len,
+	.get_regs		= fec_enet_get_regs,
 	.nway_reset		= fec_enet_nway_reset,
 	.get_link		= ethtool_op_get_link,
 	.get_coalesce		= fec_enet_get_coalesce,
-- 
1.7.4.4
