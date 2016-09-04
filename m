From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] vxlan: Update tx_errors statistics if vxlan_build_skb return err.
Date: Sun,  4 Sep 2016 18:52:51 +0800
Message-ID: <1472986371-75583-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Jiri Benc <jbenc@redhat.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If vxlan_build_skb return err < 0, tx_errors should be also increased.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index f605a36..2c72dcd 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2103,6 +2103,7 @@ static void vxlan_xmit_one(struct sk_buff *skb, struct net_device *dev,
 				      vni, md, flags, udp_sum);
 		if (err < 0) {
 			dst_release(ndst);
+			dev->stats.tx_errors++;
 			return;
 		}
 		udp_tunnel6_xmit_skb(ndst, sk, skb, dev,
-- 
1.8.3.1
