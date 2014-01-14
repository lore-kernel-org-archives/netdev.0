From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] net,via-rhine: Fix tx_timeout handling
Date: Tue, 14 Jan 2014 22:46:36 +0100
Message-ID: <1389735996-4692-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, Richard Weinberger <richard@nod.at>
To: davem@davemloft.net, rl@hellgate.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rhine_reset_task() misses to disable the tx scheduler upon reset,
this can lead to a crash if work is still scheduled while we're resetting
the tx queue.

Fixes:
[   93.591707] BUG: unable to handle kernel NULL pointer dereference at 0000004c
[   93.595514] IP: [<c119d10d>] rhine_napipoll+0x491/0x6

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/ethernet/via/via-rhine.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index cce6c4b..ef312bc 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1618,6 +1618,7 @@ static void rhine_reset_task(struct work_struct *work)
 		goto out_unlock;
 
 	napi_disable(&rp->napi);
+	netif_tx_disable(dev);
 	spin_lock_bh(&rp->lock);
 
 	/* clear all descriptors */
-- 
1.8.4.2
