From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] stmmac: fix sparse warnings
Date: Wed,  5 Nov 2014 11:45:32 +0200
Message-ID: <1415180732-8011-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	Vince Bridgers <vbridgers2013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:57436 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751188AbaKEJpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Nov 2014 04:45:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following sparse warnings.

drivers/net/ethernet/stmicro/stmmac/enh_desc.c:381:30: warning: symbol 'enh_desc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/norm_desc.c:253:30: warning: symbol 'ndesc_ops' was not declared. Should it be static?
drivers/net/ethernet/stmicro/stmmac/stmmac_hwtstamp.c:141:33: warning: symbol 'stmmac_ptp' was not declared. Should it be static?

There is no functional change.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Acked-by: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
---
Since v1:
- redone as Giuseppe suggested
 drivers/net/ethernet/stmicro/stmmac/common.h | 5 +++++
 drivers/net/ethernet/stmicro/stmmac/stmmac.h | 4 +---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/common.h b/drivers/net/ethernet/stmicro/stmmac/common.h
index 593e6c4..12a174e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/common.h
+++ b/drivers/net/ethernet/stmicro/stmmac/common.h
@@ -341,6 +341,9 @@ struct stmmac_desc_ops {
 	int (*get_rx_timestamp_status) (void *desc, u32 ats);
 };
 
+extern const struct stmmac_desc_ops enh_desc_ops;
+extern const struct stmmac_desc_ops ndesc_ops;
+
 struct stmmac_dma_ops {
 	/* DMA core initialization */
 	int (*init) (void __iomem *ioaddr, int pbl, int fb, int mb,
@@ -410,6 +413,8 @@ struct stmmac_hwtimestamp {
 	 u64(*get_systime) (void __iomem *ioaddr);
 };
 
+extern const struct stmmac_hwtimestamp stmmac_ptp;
+
 struct mac_link {
 	int port;
 	int duplex;
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac.h b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
index c3c4065..2d0036e 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac.h
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac.h
@@ -122,9 +122,7 @@ int stmmac_mdio_unregister(struct net_device *ndev);
 int stmmac_mdio_register(struct net_device *ndev);
 int stmmac_mdio_reset(struct mii_bus *mii);
 void stmmac_set_ethtool_ops(struct net_device *netdev);
-extern const struct stmmac_desc_ops enh_desc_ops;
-extern const struct stmmac_desc_ops ndesc_ops;
-extern const struct stmmac_hwtimestamp stmmac_ptp;
+
 int stmmac_ptp_register(struct stmmac_priv *priv);
 void stmmac_ptp_unregister(struct stmmac_priv *priv);
 int stmmac_resume(struct net_device *ndev);
-- 
2.1.1
