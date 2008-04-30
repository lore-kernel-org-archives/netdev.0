From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/6] [BNX2]: Zero out context memory for 5709.
Date: Wed, 30 Apr 2008 15:51:55 -0700
Message-ID: <1209595915.7941.63.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: benli@broadcom.com, andy@greyhouse.net
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2084 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759763AbYD3Vr3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Apr 2008 17:47:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Zero out context memory for 5709.

We should zero out the context memory for 5709 before each reset.  When
we resume after suspend for example, the memory may not be zero and the
chip may not function correctly.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index b5560a9..d3d3342 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2220,6 +2220,11 @@ bnx2_init_5709_context(struct bnx2 *bp)
 	for (i = 0; i < bp->ctx_pages; i++) {
 		int j;
 
+		if (bp->ctx_blk[i])
+			memset(bp->ctx_blk[i], 0, BCM_PAGE_SIZE);
+		else
+			return -ENOMEM;
+
 		REG_WR(bp, BNX2_CTX_HOST_PAGE_TBL_DATA0,
 		       (bp->ctx_blk_mapping[i] & 0xffffffff) |
 		       BNX2_CTX_HOST_PAGE_TBL_DATA0_VALID);
-- 
1.5.5.GIT



