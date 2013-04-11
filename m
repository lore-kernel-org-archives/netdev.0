From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/2] xfrm_user: constify netlink dispatch table
Date: Thu, 11 Apr 2013 09:56:09 +0200
Message-ID: <1365666969-22645-3-git-send-email-steffen.klassert@secunet.com>
References: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56594 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753887Ab3DKH4Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 03:56:25 -0400
In-Reply-To: <1365666969-22645-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>

There is no need to modify the netlink dispatch table at runtime.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_user.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 204cba1..aa77874 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2315,7 +2315,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_SA_EXTRA_FLAGS]	= { .type = NLA_U32 },
 };
 
-static struct xfrm_link {
+static const struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
@@ -2349,7 +2349,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *attrs[XFRMA_MAX+1];
-	struct xfrm_link *link;
+	const struct xfrm_link *link;
 	int type, err;
 
 	type = nlh->nlmsg_type;
-- 
1.7.9.5
