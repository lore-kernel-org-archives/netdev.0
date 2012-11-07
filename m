From: Joachim Eastwood <manabian@gmail.com>
Subject: [PATCH 3/8] net/macb: export macb_set_hwaddr and macb_get_hwaddr
Date: Wed,  7 Nov 2012 19:14:52 +0100
Message-ID: <1352312097-31320-4-git-send-email-manabian@gmail.com>
References: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Cc: plagnioj@jcrosoft.com, netdev@vger.kernel.org,
	Joachim Eastwood <manabian@gmail.com>
To: nicolas.ferre@atmel.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:38659 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751748Ab2KGSPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2012 13:15:15 -0500
Received: by mail-la0-f46.google.com with SMTP id h6so1452444lag.19
        for <netdev@vger.kernel.org>; Wed, 07 Nov 2012 10:15:15 -0800 (PST)
In-Reply-To: <1352312097-31320-1-git-send-email-manabian@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

for usage in at91_ether driver.

Signed-off-by: Joachim Eastwood <manabian@gmail.com>
---
 drivers/net/ethernet/cadence/macb.c | 8 +++++---
 drivers/net/ethernet/cadence/macb.h | 2 ++
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index a9e5a50..6be5a26 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -98,7 +98,7 @@ static void *macb_rx_buffer(struct macb *bp, unsigned int index)
 	return bp->rx_buffers + RX_BUFFER_SIZE * macb_rx_ring_wrap(index);
 }
 
-static void __macb_set_hwaddr(struct macb *bp)
+void macb_set_hwaddr(struct macb *bp)
 {
 	u32 bottom;
 	u16 top;
@@ -108,8 +108,9 @@ static void __macb_set_hwaddr(struct macb *bp)
 	top = cpu_to_le16(*((u16 *)(bp->dev->dev_addr + 4)));
 	macb_or_gem_writel(bp, SA1T, top);
 }
+EXPORT_SYMBOL_GPL(macb_set_hwaddr);
 
-static void __init macb_get_hwaddr(struct macb *bp)
+void macb_get_hwaddr(struct macb *bp)
 {
 	struct macb_platform_data *pdata;
 	u32 bottom;
@@ -149,6 +150,7 @@ static void __init macb_get_hwaddr(struct macb *bp)
 	netdev_info(bp->dev, "invalid hw address, using random\n");
 	eth_hw_addr_random(bp->dev);
 }
+EXPORT_SYMBOL_GPL(macb_get_hwaddr);
 
 static int macb_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
@@ -1035,7 +1037,7 @@ static void macb_init_hw(struct macb *bp)
 	u32 config;
 
 	macb_reset_hw(bp);
-	__macb_set_hwaddr(bp);
+	macb_set_hwaddr(bp);
 
 	config = macb_mdc_clk_div(bp);
 	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index 4235ab8..d723494 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -573,6 +573,8 @@ extern const struct ethtool_ops macb_ethtool_ops;
 int macb_mii_init(struct macb *bp);
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
 void macb_set_rx_mode(struct net_device *dev);
+void macb_set_hwaddr(struct macb *bp);
+void macb_get_hwaddr(struct macb *bp);
 
 static inline bool macb_is_gem(struct macb *bp)
 {
-- 
1.8.0
