From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 1/3] bnx2x: clamp num_queues to prevent passing a negative value
Date: Tue, 25 Feb 2014 16:04:24 +0100
Message-ID: <1393340666-3539-2-git-send-email-mschmidt@redhat.com>
References: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Cc: netdev@vger.kernel.org, ariele@broadcom.com, dmitry@broadcom.com,
	yuvalmin@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12951 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752072AbaBYPEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Feb 2014 10:04:33 -0500
In-Reply-To: <1393340666-3539-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the clamp() macro to make the calculation of the number of queues
slightly easier to understand. It also avoids a crash when someone
accidentally passes a negative value in num_queues= module parameter.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 5ee13af..64c17b6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -61,10 +61,9 @@ static void bnx2x_add_all_napi(struct bnx2x *bp)
 
 static int bnx2x_calc_num_queues(struct bnx2x *bp)
 {
-	return  bnx2x_num_queues ?
-		 min_t(int, bnx2x_num_queues, BNX2X_MAX_QUEUES(bp)) :
-		 min_t(int, netif_get_num_default_rss_queues(),
-		       BNX2X_MAX_QUEUES(bp));
+	int nq = bnx2x_num_queues ? : netif_get_num_default_rss_queues();
+	nq = clamp(nq, 1, BNX2X_MAX_QUEUES(bp));
+	return nq;
 }
 
 /**
-- 
1.8.5.3
