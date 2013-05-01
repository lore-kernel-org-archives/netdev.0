From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Prevent memory leak when cnic is absent
Date: Wed, 1 May 2013 17:27:58 +0300
Message-ID: <1367418478-7416-3-git-send-email-yuvalmin@broadcom.com>
References: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4735 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034Ab3EAP2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 May 2013 11:28:24 -0400
In-Reply-To: <1367418478-7416-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x driver allocates searcher T2 tables, but it releases that memory
during unload only released if the cnic is loaded.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 9cc39f1..c31eca9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -7757,6 +7757,8 @@ void bnx2x_free_mem(struct bnx2x *bp)
 	BNX2X_PCI_FREE(bp->eq_ring, bp->eq_mapping,
 		       BCM_PAGE_SIZE * NUM_EQ_PAGES);
 
+	BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, SRC_T2_SZ);
+
 	bnx2x_iov_free_mem(bp);
 }
 
-- 
1.8.1.227.g44fe835
