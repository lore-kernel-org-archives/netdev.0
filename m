From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] geneve: fix ip_hdr_len reserved for geneve6 tunnel.
Date: Mon, 28 Nov 2016 13:26:58 +0800
Message-ID: <1480310818-78456-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexander Duyck <aduyck@mirantis.com>,
        Pravin B Shelar <pshelar@nicira.com>,
        Jiri Benc <jbenc@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It shold reserved sizeof(ipv6hdr) for geneve in ipv6 tunnel.

Fixes: c3ef5aa5e5 ('geneve: Merge ipv4 and ipv6 geneve_build_skb()')

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 drivers/net/geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 7b80e28..45301cb 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -852,7 +852,7 @@ static int geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev,
 					   ip_hdr(skb), skb);
 		ttl = key->ttl ? : ip6_dst_hoplimit(dst);
 	}
-	err = geneve_build_skb(dst, skb, info, xnet, sizeof(struct iphdr));
+	err = geneve_build_skb(dst, skb, info, xnet, sizeof(struct ipv6hdr));
 	if (unlikely(err))
 		return err;
 
-- 
1.8.3.1
