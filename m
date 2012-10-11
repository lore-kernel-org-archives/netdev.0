From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH RFC 1/7] cpsw: rename register banks to match the reference manual
Date: Thu, 11 Oct 2012 22:27:16 +0200
Message-ID: <a20526f70cad9da003541627b934b689003adc60.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:47986 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752178Ab2JKU1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2012 16:27:36 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so1793709wgb.1
        for <netdev@vger.kernel.org>; Thu, 11 Oct 2012 13:27:35 -0700 (PDT)
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
In-Reply-To: <cover.1349985570.git.richardcochran@gmail.com>
References: <cover.1349985570.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code mixes up the CPSW_SS and the CPSW_WR register naming. This patch
changes the names to conform to the published Technical Reference Manual
from TI, in order to make working on the code less confusing.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index df55e24..a996188 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -129,7 +129,7 @@ static int rx_packet_max = CPSW_MAX_PACKET_SIZE;
 module_param(rx_packet_max, int, 0);
 MODULE_PARM_DESC(rx_packet_max, "maximum receive packet size (bytes)");
 
-struct cpsw_ss_regs {
+struct cpsw_wr_regs {
 	u32	id_ver;
 	u32	soft_reset;
 	u32	control;
@@ -140,7 +140,7 @@ struct cpsw_ss_regs {
 	u32	misc_en;
 };
 
-struct cpsw_regs {
+struct cpsw_ss_regs {
 	u32	id_ver;
 	u32	control;
 	u32	soft_reset;
@@ -202,8 +202,8 @@ struct cpsw_priv {
 	struct napi_struct		napi;
 	struct device			*dev;
 	struct cpsw_platform_data	data;
-	struct cpsw_regs __iomem	*regs;
-	struct cpsw_ss_regs __iomem	*ss_regs;
+	struct cpsw_ss_regs __iomem	*regs;
+	struct cpsw_wr_regs __iomem	*wr_regs;
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
 	struct net_device_stats		stats;
@@ -230,8 +230,8 @@ struct cpsw_priv {
 
 static void cpsw_intr_enable(struct cpsw_priv *priv)
 {
-	__raw_writel(0xFF, &priv->ss_regs->tx_en);
-	__raw_writel(0xFF, &priv->ss_regs->rx_en);
+	__raw_writel(0xFF, &priv->wr_regs->tx_en);
+	__raw_writel(0xFF, &priv->wr_regs->rx_en);
 
 	cpdma_ctlr_int_ctrl(priv->dma, true);
 	return;
@@ -239,8 +239,8 @@ static void cpsw_intr_enable(struct cpsw_priv *priv)
 
 static void cpsw_intr_disable(struct cpsw_priv *priv)
 {
-	__raw_writel(0, &priv->ss_regs->tx_en);
-	__raw_writel(0, &priv->ss_regs->rx_en);
+	__raw_writel(0, &priv->wr_regs->tx_en);
+	__raw_writel(0, &priv->wr_regs->rx_en);
 
 	cpdma_ctlr_int_ctrl(priv->dma, false);
 	return;
@@ -972,7 +972,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		dev_err(priv->dev, "unable to map i/o region\n");
 		goto clean_cpsw_ss_iores_ret;
 	}
-	priv->ss_regs = regs;
+	priv->wr_regs = regs;
 
 	for_each_slave(priv, cpsw_slave_init, priv);
 
-- 
1.7.2.5
