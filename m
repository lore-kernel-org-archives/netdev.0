From: Vince Bridgers <vbridger@opensource.altera.com>
Subject: [PATCH net 3/5] stmmac: Read tx-fifo-depth and rx-fifo-depth from the devicetree
Date: Wed, 15 Apr 2015 11:17:40 -0500
Message-ID: <1429114662-1528-4-git-send-email-vbridger@opensource.altera.com>
References: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <vbridger@opensource.altera.com>, <vbridger@altera.com>
To: <peppe.cavallaro@st.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0071.outbound.protection.outlook.com ([65.55.169.71]:53856
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754720AbbDOUhz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Apr 2015 16:37:55 -0400
In-Reply-To: <1429114662-1528-1-git-send-email-vbridger@opensource.altera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Read the tx-fifo-depth and rx-fifo-depth from the devicetree. The Synopsys
stmmac controller fifos are configurable per product instance, and the fifo
sizes are needed to configure certain features correctly such as flow control.

Signed-off-by: Vince Bridgers <vbridger@opensource.altera.com>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c | 4 ++++
 include/linux/stmmac.h                                | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f9b42f1..705bbdf 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -181,6 +181,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 				     sizeof(struct stmmac_mdio_bus_data),
 				     GFP_KERNEL);
 
+	of_property_read_u32(np, "tx-fifo-depth", &plat->tx_fifo_size);
+
+	of_property_read_u32(np, "rx-fifo-depth", &plat->rx_fifo_size);
+
 	plat->force_sf_dma_mode =
 		of_property_read_bool(np, "snps,force_sf_dma_mode");
 
diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
index cd63851..7f484a2 100644
--- a/include/linux/stmmac.h
+++ b/include/linux/stmmac.h
@@ -114,6 +114,8 @@ struct plat_stmmacenet_data {
 	int maxmtu;
 	int multicast_filter_bins;
 	int unicast_filter_entries;
+	int tx_fifo_size;
+	int rx_fifo_size;
 	void (*fix_mac_speed)(void *priv, unsigned int speed);
 	void (*bus_setup)(void __iomem *ioaddr);
 	void *(*setup)(struct platform_device *pdev);
-- 
1.9.1
