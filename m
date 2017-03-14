From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net 3/7] qed: Fix mapping leak on LL2 rx flow
Date: Tue, 14 Mar 2017 15:26:00 +0200
Message-ID: <1489497964-13734-4-git-send-email-Yuval.Mintz@cavium.com>
References: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39037 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752181AbdCNN0X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Mar 2017 09:26:23 -0400
In-Reply-To: <1489497964-13734-1-git-send-email-Yuval.Mintz@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When receiving an Rx LL2 packet, qed fails to unmap the previous buffer.

Fixes: 0a7fb11c23c0 ("qed: Add Light L2 support");
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qed/qed_ll2.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_ll2.c b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
index 5fb34db..29ae5ec 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_ll2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_ll2.c
@@ -211,6 +211,8 @@ static void qed_ll2b_complete_rx_packet(struct qed_hwfn *p_hwfn,
 	/* If need to reuse or there's no replacement buffer, repost this */
 	if (rc)
 		goto out_post;
+	dma_unmap_single(&cdev->pdev->dev, buffer->phys_addr,
+			 cdev->ll2->rx_size, DMA_FROM_DEVICE);
 
 	skb = build_skb(buffer->data, 0);
 	if (!skb) {
-- 
1.9.3
