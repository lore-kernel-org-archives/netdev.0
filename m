From: Richard Weinberger <richard@nod.at>
Subject: [PATCH] via-rhine: Fix tx_timeout handling
Date: Fri, 19 Jul 2013 23:30:28 +0200
Message-ID: <1374269428-6827-1-git-send-email-richard@nod.at>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Weinberger <richard@nod.at>
To: rl@hellgate.ch
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rhine_reset_task() misses to call netif_stop_queue(),
this can lead to a crash if work is still scheduled while
we're resetting the tx queue.

Fixes:
[   93.591707] BUG: unable to handle kernel NULL pointer dereference at 0000004c
[   93.595514] IP: [<c119d10d>] rhine_napipoll+0x491/0x6e

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/net/ethernet/via/via-rhine.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index b75eb9e..57e1b40 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -1615,6 +1615,7 @@ static void rhine_reset_task(struct work_struct *work)
 		goto out_unlock;
 
 	napi_disable(&rp->napi);
+	netif_stop_queue(dev);
 	spin_lock_bh(&rp->lock);
 
 	/* clear all descriptors */
-- 
1.8.3.1
