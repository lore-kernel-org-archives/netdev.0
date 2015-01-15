From: Xander Huff <xander.huff@ni.com>
Subject: [PATCH v3 3/3] net/macb: Create gem_ethtool_ops for new statistics functions
Date: Thu, 15 Jan 2015 15:45:16 -0600
Message-ID: <1421358316-23660-3-git-send-email-xander.huff@ni.com>
References: <063D6719AE5E284EB5DD2968C1650D6D1CAC999F@AcuExch.aculab.com>
 <1421358316-23660-1-git-send-email-xander.huff@ni.com>
Cc: netdev@vger.kernel.org, jaeden.amero@ni.com, rich.tollerton@ni.com,
	brad.mouring@ni.com, linux-kernel@vger.kernel.org,
	cyrille.pitchen@atmel.com, Xander Huff <xander.huff@ni.com>
To: davem@davemloft.net, nicolas.ferre@atmel.com,
	david.light@aculab.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421358316-23660-1-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

10/100 MACB does not have the same statistics possibilities as GEM. Separate
macb_ethtool_ops to make a new GEM-specific struct with the new statistics
functions included.

Signed-off-by: Xander Huff <xander.huff@ni.com>
---
 drivers/net/ethernet/cadence/macb.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 9edd787..f2f9ca0 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2032,11 +2032,21 @@ const struct ethtool_ops macb_ethtool_ops = {
 	.get_regs		= macb_get_regs,
 	.get_link		= ethtool_op_get_link,
 	.get_ts_info		= ethtool_op_get_ts_info,
+};
+EXPORT_SYMBOL_GPL(macb_ethtool_ops);
+
+const struct ethtool_ops gem_ethtool_ops = {
+	.get_settings		= macb_get_settings,
+	.set_settings		= macb_set_settings,
+	.get_regs_len		= macb_get_regs_len,
+	.get_regs		= macb_get_regs,
+	.get_link		= ethtool_op_get_link,
+	.get_ts_info		= ethtool_op_get_ts_info,
 	.get_ethtool_stats	= gem_get_ethtool_stats,
 	.get_strings		= gem_get_ethtool_strings,
 	.get_sset_count		= gem_get_sset_count,
 };
-EXPORT_SYMBOL_GPL(macb_ethtool_ops);
+EXPORT_SYMBOL_GPL(gem_ethtool_ops);
 
 int macb_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
@@ -2325,7 +2335,6 @@ static int __init macb_probe(struct platform_device *pdev)
 
 	dev->netdev_ops = &macb_netdev_ops;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
-	dev->ethtool_ops = &macb_ethtool_ops;
 
 	dev->base_addr = regs->start;
 
@@ -2339,12 +2348,14 @@ static int __init macb_probe(struct platform_device *pdev)
 		bp->macbgem_ops.mog_free_rx_buffers = gem_free_rx_buffers;
 		bp->macbgem_ops.mog_init_rings = gem_init_rings;
 		bp->macbgem_ops.mog_rx = gem_rx;
+		dev->ethtool_ops = &gem_ethtool_ops;
 	} else {
 		bp->max_tx_length = MACB_MAX_TX_LEN;
 		bp->macbgem_ops.mog_alloc_rx_buffers = macb_alloc_rx_buffers;
 		bp->macbgem_ops.mog_free_rx_buffers = macb_free_rx_buffers;
 		bp->macbgem_ops.mog_init_rings = macb_init_rings;
 		bp->macbgem_ops.mog_rx = macb_rx;
+		dev->ethtool_ops = &macb_ethtool_ops;
 	}
 
 	/* Set features */
-- 
1.9.1
