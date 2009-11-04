From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 1/1] NET: sungem, use spin_trylock_irqsave
Date: Wed,  4 Nov 2009 17:06:58 +0100
Message-ID: <1257350818-4194-1-git-send-email-jirislaby@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Slaby <jirislaby@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757049AbZKDQG4@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use spin_trylock_irqsave instead of open-coded
local_irq_save+spin_trylock.

Impact: cleanup

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
---
 drivers/net/sungem.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/sungem.c b/drivers/net/sungem.c
index 7019a0d..51bde03 100644
--- a/drivers/net/sungem.c
+++ b/drivers/net/sungem.c
@@ -1034,10 +1034,8 @@ static netdev_tx_t gem_start_xmit(struct sk_buff *skb,
 			(csum_stuff_off << 21));
 	}
 
-	local_irq_save(flags);
-	if (!spin_trylock(&gp->tx_lock)) {
+	if (!spin_trylock_irqsave(&gp->tx_lock, flags)) {
 		/* Tell upper layer to requeue */
-		local_irq_restore(flags);
 		return NETDEV_TX_LOCKED;
 	}
 	/* We raced with gem_do_stop() */
-- 
1.6.4.2
