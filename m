From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net-next 1/3] bnx2x: drop redundant error message about allocation failure
Date: Fri,  4 Dec 2015 17:22:34 +0100
Message-ID: <1449246156-13796-2-git-send-email-mschmidt@redhat.com>
References: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45246 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753534AbbLDQWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2015 11:22:39 -0500
In-Reply-To: <1449246156-13796-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alloc_pages() already prints a warning when it fails. No need to emit
another message. Certainly not at KERN_ERR level, because it is no big
deal if this GFP_ATOMIC allocation fails occasionally.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index d9add7c02e..5b6c17c53d 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -558,10 +558,8 @@ static int bnx2x_alloc_rx_sge(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 			put_page(pool->page);
 
 		pool->page = alloc_pages(gfp_mask, PAGES_PER_SGE_SHIFT);
-		if (unlikely(!pool->page)) {
-			BNX2X_ERR("Can't alloc sge\n");
+		if (unlikely(!pool->page))
 			return -ENOMEM;
-		}
 
 		pool->offset = 0;
 	}
-- 
2.5.0
