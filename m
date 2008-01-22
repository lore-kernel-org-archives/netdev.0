From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.25 2/4][BNX2]: Fix minor bug in bnx2_has_work().
Date: Mon, 21 Jan 2008 17:08:01 -0800
Message-ID: <1200964081.10010.47.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1039 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755894AbYAVA0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 19:26:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Fix minor bug in bnx2_has_work().

It is more correct to get the status block from the bnx2_napi struct
instead of the bnx2 struct.  It happens that they are the same in this
case because we are using the first MSIX vector.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 8348af2..7ee7746 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2903,8 +2903,7 @@ bnx2_tx_msix(int irq, void *dev_instance)
 static inline int
 bnx2_has_work(struct bnx2_napi *bnapi)
 {
-	struct bnx2 *bp = bnapi->bp;
-	struct status_block *sblk = bp->status_blk;
+	struct status_block *sblk = bnapi->status_blk;
 
 	if ((bnx2_get_hw_rx_cons(bnapi) != bnapi->rx_cons) ||
 	    (bnx2_get_hw_tx_cons(bnapi) != bnapi->hw_tx_cons))


