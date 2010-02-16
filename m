From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH -next 2/6] bnx2: Need to call cnic_setup_cnic_irq_info()
 after MTU change.
Date: Mon, 15 Feb 2010 21:42:08 -0800
Message-ID: <1266298932-28129-2-git-send-email-mchan@broadcom.com>
References: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3643 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751247Ab0BPFdB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 00:33:01 -0500
In-Reply-To: <1266298932-28129-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New status blocks are allocated during MTU change so we need to
update this information for the cnic driver.

Signed-off-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Benjamin Li <benli@broadcom.com>
---
 drivers/net/bnx2.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 48bc578..063f283 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -7141,6 +7141,13 @@ bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 			dev_close(bp->dev);
 			return rc;
 		}
+#ifdef BCM_CNIC
+		mutex_lock(&bp->cnic_lock);
+		/* Let cnic know about the new status block. */
+		if (bp->cnic_eth_dev.drv_state & CNIC_DRV_STATE_REGD)
+			bnx2_setup_cnic_irq_info(bp);
+		mutex_unlock(&bp->cnic_lock);
+#endif
 		bnx2_netif_start(bp);
 	}
 	return 0;
-- 
1.6.4.GIT


