From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH 08/13] irda: remove spin_is_locked
Date: Tue, 27 Mar 2012 17:47:12 -0700
Message-ID: <1332895637-32572-9-git-send-email-andi@firstfloor.org>
References: <1332895637-32572-1-git-send-email-andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>,
	netdev@vger.kernel.org, samuel@sortiz.org
To: akpm@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332895637-32572-1-git-send-email-andi@firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andi Kleen <ak@linux.intel.com>

It's hard to imagine how this spin_is_locked debugging check is not
totally racy.  Remove it.

Cc: netdev@vger.kernel.org
Cc: samuel@sortiz.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 drivers/net/irda/sir_dev.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/drivers/net/irda/sir_dev.c b/drivers/net/irda/sir_dev.c
index 5039f08..90a1b3e 100644
--- a/drivers/net/irda/sir_dev.c
+++ b/drivers/net/irda/sir_dev.c
@@ -632,11 +632,6 @@ static netdev_tx_t sirdev_hard_xmit(struct sk_buff *skb,
 	/* Init tx buffer*/
 	dev->tx_buff.data = dev->tx_buff.head;
 
-	/* Check problems */
-	if(spin_is_locked(&dev->tx_lock)) {
-		IRDA_DEBUG(3, "%s(), write not completed\n", __func__);
-	}
-
 	/* serialize with write completion */
 	spin_lock_irqsave(&dev->tx_lock, flags);
 
-- 
1.7.7.6
