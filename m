From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 1/1] drivers: net: xgene: fix kbuild warnings
Date: Thu, 30 Apr 2015 16:09:17 -0700
Message-ID: <1430435357-20679-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, fengguang.wu@intel.com,
	dan.carpenter@oracle.com, kchudgar@apm.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og124.obsmtp.com ([64.18.0.212]:50258 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750881AbbD3XDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 19:03:25 -0400
Received: by pdbqd1 with SMTP id qd1so74818809pdb.2
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 16:03:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed the following kbuild warnings:
1. unused variable 'of_id'
2. buffer overflow 'ring_cfg' 5 <= 5

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 drivers/net/ethernet/apm/xgene/xgene_enet_main.h | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 735d7c6..1bb3175 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -1173,7 +1173,9 @@ static int xgene_enet_probe(struct platform_device *pdev)
 	struct xgene_enet_pdata *pdata;
 	struct device *dev = &pdev->dev;
 	struct xgene_mac_ops *mac_ops;
+#ifdef CONFIG_OF
 	const struct of_device_id *of_id;
+#endif
 	int ret;
 
 	ndev = alloc_etherdev(sizeof(struct xgene_enet_pdata));
diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
index 19a0427..1c85fc8 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.h
@@ -83,7 +83,7 @@ struct xgene_enet_desc_ring {
 	u16 irq;
 	char irq_name[IRQ_ID_SIZE];
 	u32 size;
-	u32 state[NUM_RING_CONFIG];
+	u32 state[X2_NUM_RING_CONFIG];
 	void __iomem *cmd_base;
 	void __iomem *cmd;
 	dma_addr_t dma;
-- 
1.9.1
