From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/4] netns: minor cleanup in rtnl_net_getid()
Date: Wed,  1 Apr 2015 14:49:47 +0200
Message-ID: <1427892589-4266-3-git-send-email-nicolas.dichtel@6wind.com>
References: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:55536 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753438AbbDAMuI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 08:50:08 -0400
In-Reply-To: <1427892589-4266-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to initialize err, it will be overridden by the value of nlmsg_parse().

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/core/net_namespace.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index ce6396a75b8b..6c770be87f1f 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -569,8 +569,8 @@ static int rtnl_net_getid(struct sk_buff *skb, struct nlmsghdr *nlh)
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *tb[NETNSA_MAX + 1];
 	struct sk_buff *msg;
-	int err = -ENOBUFS;
 	struct net *peer;
+	int err;
 
 	err = nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, NETNSA_MAX,
 			  rtnl_net_policy);
-- 
2.2.2
