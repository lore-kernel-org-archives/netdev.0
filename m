From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/2] bnx2: Use proper handler during netpoll.
Date: Tue, 23 Mar 2010 15:13:12 -0800
Message-ID: <1269385992-18525-2-git-send-email-mchan@broadcom.com>
References: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1856 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754092Ab0CWXDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Mar 2010 19:03:01 -0400
In-Reply-To: <1269385992-18525-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netpoll needs to call the proper handler depending on the IRQ mode
and the vector.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 417de1c..a257bab 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7646,9 +7646,11 @@ poll_bnx2(struct net_device *dev)
 	int i;
 
 	for (i = 0; i < bp->irq_nvecs; i++) {
-		disable_irq(bp->irq_tbl[i].vector);
-		bnx2_interrupt(bp->irq_tbl[i].vector, &bp->bnx2_napi[i]);
-		enable_irq(bp->irq_tbl[i].vector);
+		struct bnx2_irq *irq = &bp->irq_tbl[i];
+
+		disable_irq(irq->vector);
+		irq->handler(irq->vector, &bp->bnx2_napi[i]);
+		enable_irq(irq->vector);
 	}
 }
 #endif
-- 
1.6.4.GIT


