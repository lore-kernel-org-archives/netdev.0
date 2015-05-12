From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] net: macb: OR vs AND typos
Date: Tue, 12 May 2015 21:15:24 +0300
Message-ID: <20150512181524.GE5672@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Harini Katakam <harini.katakam@xilinx.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The bitwise tests are always true here because it uses '|' where '&' is
intended.

Fixes: 98b5a0f4a228 ('net: macb: Add support for jumbo frames')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index e7c10b0..5fca309 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -1644,7 +1644,7 @@ static void macb_init_hw(struct macb *bp)
 	config |= MACB_BF(RBOF, NET_IP_ALIGN);	/* Make eth data aligned */
 	config |= MACB_BIT(PAE);		/* PAuse Enable */
 	config |= MACB_BIT(DRFCS);		/* Discard Rx FCS */
-	if (bp->caps | MACB_CAPS_JUMBO)
+	if (bp->caps & MACB_CAPS_JUMBO)
 		config |= MACB_BIT(JFRAME);	/* Enable jumbo frames */
 	else
 		config |= MACB_BIT(BIG);	/* Receive oversized frames */
@@ -1656,12 +1656,12 @@ static void macb_init_hw(struct macb *bp)
 		config |= MACB_BIT(NBC);	/* No BroadCast */
 	config |= macb_dbw(bp);
 	macb_writel(bp, NCFGR, config);
-	if ((bp->caps | MACB_CAPS_JUMBO) && bp->jumbo_max_len)
+	if ((bp->caps & MACB_CAPS_JUMBO) && bp->jumbo_max_len)
 		gem_writel(bp, JML, bp->jumbo_max_len);
 	bp->speed = SPEED_10;
 	bp->duplex = DUPLEX_HALF;
 	bp->rx_frm_len_mask = MACB_RX_FRMLEN_MASK;
-	if (bp->caps | MACB_CAPS_JUMBO)
+	if (bp->caps & MACB_CAPS_JUMBO)
 		bp->rx_frm_len_mask = MACB_RX_JFRMLEN_MASK;
 
 	macb_configure_dma(bp);
@@ -1875,7 +1875,7 @@ static int macb_change_mtu(struct net_device *dev, int new_mtu)
 		return -EBUSY;
 
 	max_mtu = ETH_DATA_LEN;
-	if (bp->caps | MACB_CAPS_JUMBO)
+	if (bp->caps & MACB_CAPS_JUMBO)
 		max_mtu = gem_readl(bp, JML) - ETH_HLEN - ETH_FCS_LEN;
 
 	if ((new_mtu > max_mtu) || (new_mtu < GEM_MTU_MIN_SIZE))
