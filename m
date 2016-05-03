From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/5] netdevice: add helper to update trans_start
Date: Tue,  3 May 2016 16:31:00 +0200
Message-ID: <1462285862-30946-4-git-send-email-fw@strlen.de>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1462285862-30946-1-git-send-email-fw@strlen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

trans_start exists twice:
- as member of net_device (legacy)
- as member of netdev_queue

In order to get rid of the legacy case, add a helper for the
dev->trans_update (this patch), then convert spots that do

dev->trans_start = jiffies

to use this helper (next patch).

This would then allow us to change the helper so that it updates the
trans_stamp of netdev queue 0 instead.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/netdevice.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f218259..798f285 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -3481,6 +3481,12 @@ static inline void txq_trans_update(struct netdev_queue *txq)
 		txq->trans_start = jiffies;
 }
 
+/* legacy drivers only, netdev_start_xmit() sets txq->trans_start */
+static inline void netif_trans_update(struct net_device *dev)
+{
+	dev->trans_start = jiffies;
+}
+
 /**
  *	netif_tx_lock - grab network device transmit lock
  *	@dev: network device
-- 
2.7.3
