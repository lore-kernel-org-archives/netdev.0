From: Rami Rosen <ramirose@gmail.com>
Subject: [PATCH] net: ena: change the return type of ena_set_push_mode() to be void.
Date: Tue, 23 Aug 2016 20:20:17 +0300
Message-ID: <1471972817-4103-1-git-send-email-ramirose@gmail.com>
Cc: netanel@annapurnalabs.com, Rami Rosen <ramirose@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36307 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752228AbcHWRU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 13:20:27 -0400
Received: by mail-wm0-f68.google.com with SMTP id i138so18950808wmf.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 10:20:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes the return type of ena_set_push_mode() to be void,
as it always returns 0.

Signed-off-by: Rami Rosen <ramirose@gmail.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 5c536b8..bfeaec5 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -2681,8 +2681,8 @@ static int ena_calc_io_queue_num(struct pci_dev *pdev,
 	return io_queue_num;
 }
 
-static int ena_set_push_mode(struct pci_dev *pdev, struct ena_com_dev *ena_dev,
-			     struct ena_com_dev_get_features_ctx *get_feat_ctx)
+static void ena_set_push_mode(struct pci_dev *pdev, struct ena_com_dev *ena_dev,
+			      struct ena_com_dev_get_features_ctx *get_feat_ctx)
 {
 	bool has_mem_bar;
 
@@ -2693,8 +2693,6 @@ static int ena_set_push_mode(struct pci_dev *pdev, struct ena_com_dev *ena_dev,
 		ena_dev->tx_mem_queue_type = ENA_ADMIN_PLACEMENT_POLICY_DEV;
 	else
 		ena_dev->tx_mem_queue_type = ENA_ADMIN_PLACEMENT_POLICY_HOST;
-
-	return 0;
 }
 
 static void ena_set_dev_offloads(struct ena_com_dev_get_features_ctx *feat,
@@ -2913,11 +2911,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_free_region;
 	}
 
-	rc = ena_set_push_mode(pdev, ena_dev, &get_feat_ctx);
-	if (rc) {
-		dev_err(&pdev->dev, "Invalid module param(push_mode)\n");
-		goto err_device_destroy;
-	}
+	ena_set_push_mode(pdev, ena_dev, &get_feat_ctx);
 
 	if (ena_dev->tx_mem_queue_type == ENA_ADMIN_PLACEMENT_POLICY_DEV) {
 		ena_dev->mem_bar = ioremap_wc(pci_resource_start(pdev, ENA_MEM_BAR),
-- 
2.7.4
