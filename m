From: Jiri Slaby <jslaby@suse.cz>
Subject: [PATCH 1/3] NET: pch, fix use after free
Date: Mon, 11 Oct 2010 11:26:56 +0200
Message-ID: <1286789218-13976-1-git-send-email-jslaby@suse.cz>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jirislaby@gmail.com, Masayuki Ohtake <masa-korg@dsn.okisemi.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stanse found that pch_gbe_xmit_frame uses skb after it is freed. Fix
that.

Signed-off-by: Jiri Slaby <jslaby@suse.cz>
Cc: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/pch_gbe/pch_gbe_main.c b/drivers/net/pch_gbe/pch_gbe_main.c
index 53c56cf..e44644f 100644
--- a/drivers/net/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/pch_gbe/pch_gbe_main.c
@@ -1847,9 +1847,9 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned long flags;
 
 	if (unlikely(skb->len > (adapter->hw.mac.max_frame_size - 4))) {
-		dev_kfree_skb_any(skb);
 		pr_err("Transfer length Error: skb len: %d > max: %d\n",
 		       skb->len, adapter->hw.mac.max_frame_size);
+		dev_kfree_skb_any(skb);
 		adapter->stats.tx_length_errors++;
 		return NETDEV_TX_OK;
 	}
-- 
1.7.3.1
