From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2] ip6_tunnel: Correct tos value in collect_md mode
Date: Thu, 15 Jun 2017 10:30:29 +0800
Message-ID: <1497493829-13050-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>,
        Peter Dawson <petedaws@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Patrick McHardy <kaber@trash.net>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Same as ip_gre, geneve and vxlan, use key->tos as tos value.

CC: Peter Dawson <petedaws@gmail.com>
Fixes: 0e9a709560db ("ip6_tunnel, ip6_gre: fix setting of DSCP on
encapsulated packets”)
Suggested-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>

---
Changes since v2:
  * Add fixes information
  * mask key->tos with RT_TOS() suggested by Daniel
---
 net/ipv6/ip6_tunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index ef99d59..6400726 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1249,7 +1249,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		fl6.flowi6_proto = IPPROTO_IPIP;
 		fl6.daddr = key->u.ipv6.dst;
 		fl6.flowlabel = key->label;
-		dsfield = ip6_tclass(key->label);
+		dsfield =  RT_TOS(key->tos);
 	} else {
 		if (!(t->parms.flags & IP6_TNL_F_IGN_ENCAP_LIMIT))
 			encap_limit = t->parms.encap_limit;
@@ -1320,7 +1320,7 @@ int ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev, __u8 dsfield,
 		fl6.flowi6_proto = IPPROTO_IPV6;
 		fl6.daddr = key->u.ipv6.dst;
 		fl6.flowlabel = key->label;
-		dsfield = ip6_tclass(key->label);
+		dsfield = RT_TOS(key->tos);
 	} else {
 		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
 		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
-- 
1.8.3.1
