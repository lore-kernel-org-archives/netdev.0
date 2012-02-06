From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3 net-next] bnx2: Add missing memory barrier in
 bnx2_start_xmit()
Date: Sun, 5 Feb 2012 17:24:39 -0800
Message-ID: <1328491480-13030-2-git-send-email-mchan@broadcom.com>
References: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3298 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754641Ab2BFBRu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Feb 2012 20:17:50 -0500
In-Reply-To: <1328491480-13030-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Zolotarov <vlad@scalemp.com>

Sync DMA descriptor before hitting the TX mailbox for weak memory model
CPUs.

There has been discussions several years ago about this.  Some believe
that writel() should guarantee ordering.  Others want explicit barriers
if necessary.  Today writel() does not have the ordering guarantee and
many other drivers use explicit barriers.

Signed-off-by: Vlad Zolotarov <vlad@scalemp.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index 2ab31da..7105989 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -6565,6 +6565,9 @@ bnx2_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 	txbd->tx_bd_vlan_tag_flags |= TX_BD_FLAGS_END;
 
+	/* Sync BD data before updating TX mailbox */
+	wmb();
+
 	netdev_tx_sent_queue(txq, skb->len);
 
 	prod = NEXT_TX_BD(prod);
-- 
1.6.4.GIT
