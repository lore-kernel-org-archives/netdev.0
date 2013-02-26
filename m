From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] qlcnic: Remove redundant NULL check before kfree
Date: Wed, 27 Feb 2013 01:25:31 +0530
Message-ID: <1361908531-3292-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, sony.chacko@qlogic.com,
	jitendra.kalsaria@qlogic.com
To: netdev@vger.kernel.org, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:57943 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758639Ab3BZTzu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:55:50 -0500
Received: by mail-da0-f48.google.com with SMTP id w4so2169614dam.7
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:55:50 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 28a6d48..b4c33c2 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -192,8 +192,7 @@ int qlcnic_alloc_sds_rings(struct qlcnic_recv_context *recv_ctx, int count)
 
 void qlcnic_free_sds_rings(struct qlcnic_recv_context *recv_ctx)
 {
-	if (recv_ctx->sds_rings != NULL)
-		kfree(recv_ctx->sds_rings);
+	kfree(recv_ctx->sds_rings);
 
 	recv_ctx->sds_rings = NULL;
 }
@@ -2038,10 +2037,8 @@ static void qlcnic_remove(struct pci_dev *pdev)
 
 	qlcnic_detach(adapter);
 
-	if (adapter->npars != NULL)
-		kfree(adapter->npars);
-	if (adapter->eswitch != NULL)
-		kfree(adapter->eswitch);
+	kfree(adapter->npars);
+	kfree(adapter->eswitch);
 
 	if (qlcnic_82xx_check(adapter))
 		qlcnic_clr_all_drv_state(adapter, 0);
-- 
1.7.9.5
