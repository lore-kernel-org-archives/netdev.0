From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/36] netfilter: ip6t_SYNPROXY: unnecessary to check whether ip6_route_output returns NULL
Date: Mon,  9 May 2016 20:46:30 +0200
Message-ID: <1462819614-5402-13-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:45714 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505AbcEISrT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 14:47:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 5E66FE8E85
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 4EFA613471F
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:18 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id A56BF13470E
	for <netdev@vger.kernel.org>; Mon,  9 May 2016 20:47:13 +0200 (CEST)
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

ip6_route_output() will never return a NULL pointer, so there's no need
to check it.

Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/ipv6/netfilter/ip6t_SYNPROXY.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/netfilter/ip6t_SYNPROXY.c b/net/ipv6/netfilter/ip6t_SYNPROXY.c
index 5d778dd..06bed74 100644
--- a/net/ipv6/netfilter/ip6t_SYNPROXY.c
+++ b/net/ipv6/netfilter/ip6t_SYNPROXY.c
@@ -60,7 +60,7 @@ synproxy_send_tcp(struct net *net,
 	fl6.fl6_dport = nth->dest;
 	security_skb_classify_flow((struct sk_buff *)skb, flowi6_to_flowi(&fl6));
 	dst = ip6_route_output(net, NULL, &fl6);
-	if (dst == NULL || dst->error) {
+	if (dst->error) {
 		dst_release(dst);
 		goto free_nskb;
 	}
-- 
2.1.4
