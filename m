From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH v2 2/2] ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit path.
Date: Sat, 21 May 2016 18:17:35 +0800
Message-ID: <1463825855-7363-2-git-send-email-yanhaishuang@cmss.chinamobile.com>
References: <1463825855-7363-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9827 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751743AbcEUKRu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2016 06:17:50 -0400
In-Reply-To: <1463825855-7363-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In gre6 xmit path, we are sending a GRE packet, so set fl6 proto
to IPPROTO_GRE properly.

Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
Changes in v2:
  - Initialize the flow protocol in ip6gre_tnl_link_config
---
 net/ipv6/ip6_gre.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 8ea5a4d..e706621 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -712,6 +712,7 @@ static void ip6gre_tnl_link_config(struct ip6_tnl *t, int set_mtu)
 	fl6->daddr = p->raddr;
 	fl6->flowi6_oif = p->link;
 	fl6->flowlabel = 0;
+	fl6->flowi6_proto = IPPROTO_GRE;
 
 	if (!(p->flags&IP6_TNL_F_USE_ORIG_TCLASS))
 		fl6->flowlabel |= IPV6_TCLASS_MASK & p->flowinfo;
-- 
1.8.3.1
