From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: [net-next PATCH] driver: net: cpsw: add no_bd_ram dt parsing
Date: Fri, 9 Oct 2015 15:36:46 +0530
Message-ID: <1444385206-7011-1-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-omap@vger.kernel.org>,
	"David S . Miller" <davem@davemloft.net>,
	Sekhar Nori <nsekhar@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37053 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757235AbbJIKII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2015 06:08:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

cpdma is capable of placing the dma descriptors in ddr using
dma_alloc_coherent() when the internal bd ram size is not enough.
To utilize this feature pass the DT parameter "no_bd_ram" and
increase bd_ram_size and number of rx descriptors.

Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 4 ++++
 drivers/net/ethernet/ti/cpsw.h | 1 +
 2 files changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 8fc90f1..cf1a625 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1987,6 +1987,8 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 	}
 	data->ale_entries = prop;
 
+	data->no_bd_ram = of_property_read_bool(node, "no_bd_ram");
+
 	if (of_property_read_u32(node, "bd_ram_size", &prop)) {
 		dev_err(&pdev->dev, "Missing bd_ram_size property in the DT.\n");
 		return -EINVAL;
@@ -2358,6 +2360,8 @@ static int cpsw_probe(struct platform_device *pdev)
 	dma_params.desc_mem_size	= data->bd_ram_size;
 	dma_params.desc_align		= 16;
 	dma_params.has_ext_regs		= true;
+	if (data->no_bd_ram)
+		dma_params.desc_mem_phys = 0;
 	dma_params.desc_hw_addr         = dma_params.desc_mem_phys;
 
 	priv->dma = cpdma_ctlr_create(&dma_params);
diff --git a/drivers/net/ethernet/ti/cpsw.h b/drivers/net/ethernet/ti/cpsw.h
index ca90efa..b654ac2 100644
--- a/drivers/net/ethernet/ti/cpsw.h
+++ b/drivers/net/ethernet/ti/cpsw.h
@@ -33,6 +33,7 @@ struct cpsw_platform_data {
 	u32	cpts_clock_mult;  /* convert input clock ticks to nanoseconds */
 	u32	cpts_clock_shift; /* convert input clock ticks to nanoseconds */
 	u32	ale_entries;	/* ale table size */
+	bool	no_bd_ram;	/* set if cpsw bd ram should not be used */
 	u32	bd_ram_size;  /*buffer descriptor ram size */
 	u32	rx_descs;	/* Number of Rx Descriptios */
 	u32	mac_control;	/* Mac control register */
-- 
2.6.1.133.gf5b6079
