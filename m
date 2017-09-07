From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ip6_tunnel: fix setting hop_limit value for ipv6 tunnel
Date: Thu,  7 Sep 2017 14:08:35 +0800
Message-ID: <1504764515-13536-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1504764515-13536-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Similar to vxlan/geneve tunnel, if hop_limit is zero, it should fall
back to ip6_dst_hoplimt().

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_tunnel.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 3a0ba2a..10a693a 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1184,6 +1184,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		init_tel_txopt(&opt, encap_limit);
 		ipv6_push_frag_opts(skb, &opt.ops, &proto);
 	}
+	hop_limit = hop_limit ? : ip6_dst_hoplimit(dst);
 
 	/* Calculate max headroom for all the headers and adjust
 	 * needed_headroom if necessary.
-- 
1.8.3.1
