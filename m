From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next RFC v1 26/27] afnetns: ipv6: inherit afnetns from calling application
Date: Mon, 13 Mar 2017 00:01:50 +0100
Message-ID: <20170312230151.5185-27-hannes@stressinduktion.org>
References: <20170312230151.5185-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:57396 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S935660AbdCLXCS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:02:18 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id 1B8A22077B
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:17 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id 7A31A2436A
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:02:16 -0400 (EDT)
In-Reply-To: <20170312230151.5185-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 319f83a7d29dd5..3d9d24ec066a67 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4542,7 +4542,7 @@ inet6_rtm_newaddr(struct sk_buff *skb, struct nlmsghdr *nlh)
 		if (IS_ERR(afnetns))
 			return PTR_ERR(afnetns);
 	} else {
-		afnetns = afnetns_get(net_afnetns(net));
+		afnetns = afnetns_get(current->nsproxy->afnet_ns);
 	}
 #else
 	if (tb[IFA_AFNETNS_FD])
-- 
2.9.3
