From: Haiyang Zhang <haiyangz@exchange.microsoft.com>
Subject: [PATCH net-next,1/4] hv_netvsc: Clean up unused parameter from netvsc_get_hash()
Date: Mon, 21 Aug 2017 14:55:52 -0700
Message-ID: <1503352555-9256-1-git-send-email-haiyangz@exchange.microsoft.com>
Reply-To: haiyangz@microsoft.com
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
        vkuznets@redhat.com, linux-kernel@vger.kernel.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Haiyang Zhang <haiyangz@microsoft.com>

The parameter "sk" is not in use.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/netvsc_drv.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b33f050..4677d21 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -193,7 +193,7 @@ static int netvsc_close(struct net_device *net)
 /* Azure hosts don't support non-TCP port numbers in hashing yet. We compute
  * hash for non-TCP traffic with only IP numbers.
  */
-static inline u32 netvsc_get_hash(struct sk_buff *skb, struct sock *sk)
+static inline u32 netvsc_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys flow;
 	u32 hash;
@@ -227,7 +227,7 @@ static inline int netvsc_get_tx_queue(struct net_device *ndev,
 	struct sock *sk = skb->sk;
 	int q_idx;
 
-	q_idx = ndc->tx_send_table[netvsc_get_hash(skb, sk) &
+	q_idx = ndc->tx_send_table[netvsc_get_hash(skb) &
 				   (VRSS_SEND_TAB_SIZE - 1)];
 
 	/* If queue index changed record the new value */
-- 
1.7.1
