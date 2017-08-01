From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 1/7] b44: Initialize 64-bit stats seqcount
Date: Tue,  1 Aug 2017 12:11:06 -0700
Message-ID: <20170801191113.8754-2-f.fainelli@gmail.com>
References: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>,
        Michael Chan <michael.chan@broadcom.com>,
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35381 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdHATL0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 15:11:26 -0400
In-Reply-To: <20170801191113.8754-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 32-bit hosts and with CONFIG_DEBUG_LOCK_ALLOC we should be seeing a
lockdep splat indicating this seqcount is not correctly initialized, fix
that.

Fixes: eeda8585522b ("b44: add 64 bit stats")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/b44.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/b44.c b/drivers/net/ethernet/broadcom/b44.c
index f411936b744c..a1125d10c825 100644
--- a/drivers/net/ethernet/broadcom/b44.c
+++ b/drivers/net/ethernet/broadcom/b44.c
@@ -2368,6 +2368,7 @@ static int b44_init_one(struct ssb_device *sdev,
 	bp->msg_enable = netif_msg_init(b44_debug, B44_DEF_MSG_ENABLE);
 
 	spin_lock_init(&bp->lock);
+	u64_stats_init(&bp->hw_stats.syncp);
 
 	bp->rx_pending = B44_DEF_RX_RING_PENDING;
 	bp->tx_pending = B44_DEF_TX_RING_PENDING;
-- 
2.9.3
