From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH] vmxnet3: remove unused variable
Date: Mon, 13 Jun 2011 11:48:30 -0400
Message-ID: <1307980110-9585-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"VMware, Inc." <pv-drivers@vmware.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55725 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751001Ab1FMPt0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 11:49:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing some backporting I noticed that vmxnet3 had a variable that was set
but never used.  Get rid of it, and stop the compiler from griping

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
CC: "VMware, Inc." <pv-drivers@vmware.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index fa6e2ac..a9b60a2 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -405,10 +405,8 @@ vmxnet3_tq_cleanup(struct vmxnet3_tx_queue *tq,
 
 	while (tq->tx_ring.next2comp != tq->tx_ring.next2fill) {
 		struct vmxnet3_tx_buf_info *tbi;
-		union Vmxnet3_GenericDesc *gdesc;
 
 		tbi = tq->buf_info + tq->tx_ring.next2comp;
-		gdesc = tq->tx_ring.base + tq->tx_ring.next2comp;
 
 		vmxnet3_unmap_tx_buf(tbi, adapter->pdev);
 		if (tbi->skb) {
-- 
1.7.5.4

