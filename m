From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 07/14] net/macb: export some symbols for at91_ether
Date: Thu, 18 Oct 2012 23:01:12 +0200
Message-ID: <1350594079-4337-8-git-send-email-manabian@gmail.com>
References: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Cc: netdev@vger.kernel.org, Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:52354 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756553Ab2JRVBk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 17:01:40 -0400
Received: by mail-la0-f46.google.com with SMTP id h6so6136401lag.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 14:01:39 -0700 (PDT)
In-Reply-To: <1350594079-4337-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export some symbols to start sharing code between
macb and at91_ether drivers.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 9 ++++++---
 drivers/net/ethernet/cadence/macb.h | 5 +++++
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 033064b..8ee6de5 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -228,7 +228,7 @@ static int macb_mii_probe(struct net_device *dev)
 	return 0;
 }
 
-static int macb_mii_init(struct macb *bp)
+int macb_mii_init(struct macb *bp)
 {
 	struct macb_platform_data *pdata;
 	int err = -ENXIO, i;
@@ -284,6 +284,7 @@ err_out_free_mdiobus:
 err_out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(macb_mii_init);
 
 static void macb_update_stats(struct macb *bp)
 {
@@ -1214,15 +1215,16 @@ static void macb_get_drvinfo(struct net_device *dev,
 	strcpy(info->bus_info, dev_name(&bp->pdev->dev));
 }
 
-static const struct ethtool_ops macb_ethtool_ops = {
+const struct ethtool_ops macb_ethtool_ops = {
 	.get_settings		= macb_get_settings,
 	.set_settings		= macb_set_settings,
 	.get_drvinfo		= macb_get_drvinfo,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
 };
+EXPORT_SYMBOL_GPL(macb_ethtool_ops);
 
-static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct macb *bp = netdev_priv(dev);
 	struct phy_device *phydev = bp->phy_dev;
@@ -1235,6 +1237,7 @@ static int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 
 	return phy_mii_ioctl(phydev, rq, cmd);
 }
+EXPORT_SYMBOL_GPL(macb_ioctl);
 
 static const struct net_device_ops macb_netdev_ops = {
 	.ndo_open		= macb_open,
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 138311f..335d111 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -577,6 +577,11 @@ struct macb {
 	struct recv_desc_bufs *dlist_phys;	/* descriptor list physical address */
 };
 
+extern const struct ethtool_ops macb_ethtool_ops;
+
+int macb_mii_init(struct macb *bp);
+int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+
 static inline bool macb_is_gem(struct macb *bp)
 {
 	return MACB_BFEXT(IDNUM, macb_readl(bp, MID)) == 0x2;
-- 
1.7.12.3
