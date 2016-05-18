From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH 2/2] ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit path.
Date: Wed, 18 May 2016 18:05:52 +0800
Message-ID: <1463565952-8781-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8347 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885AbcERKGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 06:06:06 -0400
In-Reply-To: <1463565952-8781-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In gre6 xmit path, we are sending a GRE packet, so set fl6 proto
to IPPROTO_GRE properly.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/ip6_gre.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 8ea5a4d..cc84098 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -541,6 +541,7 @@ static inline int ip6gre_xmit_ipv4(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv4_get_dsfield(iph);
 
@@ -595,6 +596,7 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 		encap_limit = t->parms.encap_limit;
 
 	memcpy(&fl6, &t->fl.u.ip6, sizeof(fl6));
+	fl6.flowi6_proto = IPPROTO_GRE;
 
 	dsfield = ipv6_get_dsfield(ipv6h);
 	if (t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS)
-- 
1.8.3.1
