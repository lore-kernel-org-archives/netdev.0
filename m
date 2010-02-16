From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 1/6] bnx2: Check BNX2_FLAG_USING_MSIX flag when
 setting up MSIX.
Date: Mon, 15 Feb 2010 21:42:07 -0800
Message-ID: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2763 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335Ab0BPFdE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:33:04 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Checking the flag is more correct than checking bp->irq_nvecs. By
accident it is not a problem because we always have more than 1
vectors when using MSIX mode.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index c7f5515..48bc578 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4940,7 +4940,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		      BNX2_HC_CONFIG_COLLECT_STATS;
 	}
 
-	if (bp->irq_nvecs > 1) {
+	if (bp->flags & BNX2_FLAG_USING_MSIX) {
 		REG_WR(bp, BNX2_HC_MSIX_BIT_VECTOR,
 		       BNX2_HC_MSIX_BIT_VECTOR_VAL);
 
-- 
1.6.4.GIT


