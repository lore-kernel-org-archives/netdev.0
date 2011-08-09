From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 1/5] bnx2x: init FCOE FP only once
Date: Tue, 9 Aug 2011 16:08:09 +0300
Message-ID: <1312895290.21856.0.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3439 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751981Ab1HINON (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:14:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Zolotarov <vladz@broadcom.com>


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index d724a18..64df0ef 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -63,8 +63,9 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	fp->disable_tpa = ((bp->flags & TPA_ENABLE_FLAG) == 0);
 
 #ifdef BCM_CNIC
-	/* We don't want TPA on FCoE, FWD and OOO L2 rings */
-	bnx2x_fcoe(bp, disable_tpa) = 1;
+	/* We don't want TPA on an FCoE L2 ring */
+	if (IS_FCOE_FP(fp))
+		fp->disable_tpa = 1;
 #endif
 }
 
-- 
1.7.2.2




