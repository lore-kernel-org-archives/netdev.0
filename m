From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH net-next 3/7] drivers: net: xgene: Fix wrong logical operation
Date: Wed, 15 Mar 2017 13:27:17 -0700
Message-ID: <1489609641-31557-4-git-send-email-isubramanian@apm.com>
References: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Cc: linux-arm-kernel@lists.infradead.org, patches@apm.com,
        kchudgar@apm.com, qnguyen@apm.com,
        Iyappan Subramanian <isubramanian@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33304 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751495AbdCOU0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 16:26:18 -0400
Received: by mail-pf0-f169.google.com with SMTP id w189so13701681pfb.0
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 13:26:13 -0700 (PDT)
In-Reply-To: <1489609641-31557-1-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quan Nguyen <qnguyen@apm.com>

This patch fixes the wrong logical OR operation by changing it to
bit-wise OR operation.

Fixes: 3bb502f83080 ("drivers: net: xgene: fix statistics counters race condition")
Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Quan Nguyen <qnguyen@apm.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index b3568c4..ec43278 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -677,9 +677,9 @@ static int xgene_enet_rx_frame(struct xgene_enet_desc_ring *rx_ring,
 	buf_pool->rx_skb[skb_index] = NULL;
 
 	/* checking for error */
-	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) ||
+	status = (GET_VAL(ELERR, le64_to_cpu(raw_desc->m0)) << LERR_LEN) |
 		  GET_VAL(LERR, le64_to_cpu(raw_desc->m0));
-	if (unlikely(status > 2)) {
+	if (unlikely(status)) {
 		dev_kfree_skb_any(skb);
 		xgene_enet_free_pagepool(page_pool, raw_desc, exp_desc);
 		xgene_enet_parse_error(rx_ring, netdev_priv(rx_ring->ndev),
-- 
1.9.1
