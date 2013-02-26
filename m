From: Syam Sidhardhan <syamsidhardh@gmail.com>
Subject: [PATCH] netxen: Remove redundant NULL check before kfree
Date: Wed, 27 Feb 2013 01:23:05 +0530
Message-ID: <1361908385-3248-1-git-send-email-s.syam@samsung.com>
Cc: syamsidhardh@gmail.com, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:48591 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758639Ab3BZTxW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:53:22 -0500
Received: by mail-pb0-f49.google.com with SMTP id xa12so2535612pbc.8
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2013 11:53:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

kfree on NULL pointer is a no-op.

Signed-off-by: Syam Sidhardhan <s.syam@samsung.com>
---
 .../net/ethernet/qlogic/netxen/netxen_nic_main.c   |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 501f492..377b521 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -178,8 +178,7 @@ netxen_alloc_sds_rings(struct netxen_recv_context *recv_ctx, int count)
 static void
 netxen_free_sds_rings(struct netxen_recv_context *recv_ctx)
 {
-	if (recv_ctx->sds_rings != NULL)
-		kfree(recv_ctx->sds_rings);
+	kfree(recv_ctx->sds_rings);
 
 	recv_ctx->sds_rings = NULL;
 }
-- 
1.7.9.5
