From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next V3 04/10] cpsw: remember the silicon version
Date: Mon, 29 Oct 2012 19:45:14 +0100
Message-ID: <026d147c58c00f4fbe91f1bd8fc6c23b8b57b4ef.1351535539.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Cc: <linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	Cyril Chemparathy <cyril@ti.com>,
	Mugunthan V N <mugunthanvnm@ti.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:44513 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760502Ab2J2Spl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 14:45:41 -0400
Received: by mail-ee0-f46.google.com with SMTP id b15so2256783eek.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 11:45:41 -0700 (PDT)
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
In-Reply-To: <cover.1351535536.git.richardcochran@gmail.com>
References: <cover.1351535536.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch lets the CPSW driver remember the version number in order to
support the two different variants already in the wild.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/net/ethernet/ti/cpsw.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b4ca370..5c427cf 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -76,6 +76,8 @@ do {								\
 #define CPSW_MINOR_VERSION(reg)		(reg & 0xff)
 #define CPSW_RTL_VERSION(reg)		((reg >> 11) & 0x1f)
 
+#define CPSW_VERSION_1		0x19010a
+#define CPSW_VERSION_2		0x19010c
 #define CPDMA_RXTHRESH		0x0c0
 #define CPDMA_RXFREE		0x0e0
 #define CPDMA_TXHDP		0x00
@@ -216,6 +218,7 @@ struct cpsw_priv {
 	struct cpsw_wr_regs __iomem	*wr_regs;
 	struct cpsw_host_regs __iomem	*host_port_regs;
 	u32				msg_enable;
+	u32				version;
 	struct net_device_stats		stats;
 	int				rx_packet_max;
 	int				host_port;
@@ -540,6 +543,7 @@ static int cpsw_ndo_open(struct net_device *ndev)
 	pm_runtime_get_sync(&priv->pdev->dev);
 
 	reg = __raw_readl(&priv->regs->id_ver);
+	priv->version = reg;
 
 	dev_info(priv->dev, "initializing cpsw version %d.%d (%d)\n",
 		 CPSW_MAJOR_VERSION(reg), CPSW_MINOR_VERSION(reg),
-- 
1.7.2.5
