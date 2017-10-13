From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,2/3] hv_netvsc: Rename tx_send_table to tx_table
Date: Fri, 13 Oct 2017 12:28:04 -0700
Message-ID: <20171013192805.18183-3-haiyangz@exchange.microsoft.com>
References: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, sthemmin@microsoft.com,
        olaf@aepfle.de, vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013192805.18183-1-haiyangz@exchange.microsoft.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

Simplify the variable name: tx_send_table

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 2 +-
 drivers/net/hyperv/netvsc.c     | 2 +-
 drivers/net/hyperv/netvsc_drv.c | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 65ceb3aec40e..4958bb6b7376 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -731,7 +731,7 @@ struct net_device_context {
 
 	u32 tx_checksum_mask;
 
-	u32 tx_send_table[VRSS_SEND_TAB_SIZE];
+	u32 tx_table[VRSS_SEND_TAB_SIZE];
 
 	/* Ethtool settings */
 	u8 duplex;
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 6e5194916bbe..d34cf37e949d 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -1110,7 +1110,7 @@ static void netvsc_send_table(struct hv_device *hdev,
 		      nvmsg->msg.v5_msg.send_table.offset);
 
 	for (i = 0; i < count; i++)
-		net_device_ctx->tx_send_table[i] = tab[i];
+		net_device_ctx->tx_table[i] = tab[i];
 }
 
 static void netvsc_send_vf(struct net_device_context *net_device_ctx,
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 8fa964e733ad..da216ca4f2b2 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -252,8 +252,8 @@ static inline int netvsc_get_tx_queue(struct net_device *ndev,
 	struct sock *sk = skb->sk;
 	int q_idx;
 
-	q_idx = ndc->tx_send_table[netvsc_get_hash(skb, ndc) &
-				   (VRSS_SEND_TAB_SIZE - 1)];
+	q_idx = ndc->tx_table[netvsc_get_hash(skb, ndc) &
+			      (VRSS_SEND_TAB_SIZE - 1)];
 
 	/* If queue index changed record the new value */
 	if (q_idx != old_idx &&
-- 
2.14.1
