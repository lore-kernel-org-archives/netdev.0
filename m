From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 1/8] bnx2: Zero out status block before chip
 reset.
Date: Fri, 21 Aug 2009 19:20:43 -0700
Message-ID: <1250907650-24672-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4822 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933148AbZHVCNr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 22:13:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case IRQs are shared, we will not mistakenly start processing
the ring based on old status block indices.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 756d4b4..e75b6e9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4858,6 +4858,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG2, BNX2_RBUF_CONFIG2_VAL(mtu));
 	bnx2_reg_wr_ind(bp, BNX2_RBUF_CONFIG3, BNX2_RBUF_CONFIG3_VAL(mtu));
 
+	memset(bp->bnx2_napi[0].status_blk.msi, 0, bp->status_stats_size);
 	for (i = 0; i < BNX2_MAX_MSIX_VEC; i++)
 		bp->bnx2_napi[i].last_status_idx = 0;
 
-- 
1.5.6.GIT


