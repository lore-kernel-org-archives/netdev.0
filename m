From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH V2 1/7] cpsw: rename register banks to match the reference manual
Date: Mon, 15 Oct 2012 21:48:07 +0200
Message-ID: <7202ed077758e53bd49d818a3b90755a0db752c8.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Sriramakrishnan A G <srk@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:64148 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753893Ab2JOTst (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 15:48:49 -0400
Received: by mail-wi0-f178.google.com with SMTP id hr7so2548396wib.1
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 12:48:48 -0700 (PDT)
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
In-Reply-To: <cover.1350329726.git.richardcochran@gmail.com>
References: <cover.1350329726.git.richardcochran@gmail.com>
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
index fb1a692..3568b46 100644
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
@@ -984,7 +984,7 @@ static int __devinit cpsw_probe(struct platform_device *pdev)
 		dev_err(priv->dev, "unable to map i/o region\n");
 		goto clean_cpsw_ss_iores_ret;
 	}
-	priv->ss_regs = regs;
+	priv->wr_regs = regs;
 
 	for_each_slave(priv, cpsw_slave_init, priv);
 
-- 
1.7.2.5
