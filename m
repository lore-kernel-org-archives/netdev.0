From: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
Subject: [PATCH] sit: reload iphdr in ipip6_rcv
Date: Sun,  4 Jun 2017 14:43:43 +0800
Message-ID: <1496558623-11437-1-git-send-email-yanhaishuang@cmss.chinamobile.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
To: "David S. Miller" <davem@davemloft.net>,
        Jesse Gross <jesse@kernel.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:19260 "EHLO
        cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750852AbdFDGwx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 02:52:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since iptunnel_pull_header() can call pskb_may_pull(),
we must reload any pointer that was related to skb->head.

Fixes: a09a4c8dd1ec ("tunnels: Remove encapsulation offloads on decap")
Signed-off-by: Haishuang Yan <yanhaishuang@cmss.chinamobile.com>
---
 net/ipv6/sit.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 61e5902..af832e7 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -657,6 +657,7 @@ static int ipip6_rcv(struct sk_buff *skb)
 		if (iptunnel_pull_header(skb, 0, htons(ETH_P_IPV6),
 		    !net_eq(tunnel->net, dev_net(tunnel->dev))))
 			goto out;
+		iph = ip_hdr(skb);
 
 		err = IP_ECN_decapsulate(iph, skb);
 		if (unlikely(err)) {
-- 
1.8.3.1
