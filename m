From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH] xfrm_user: constify netlink dispatch table
Date: Sun, 24 Feb 2013 14:10:27 +0100
Message-ID: <1361711427-7880-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:49570 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757187Ab3BXNKp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 08:10:45 -0500
Received: by mail-bk0-f46.google.com with SMTP id j5so899227bkw.5
        for <netdev@vger.kernel.org>; Sun, 24 Feb 2013 05:10:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to modify the netlink dispatch table at runtime.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/xfrm/xfrm_user.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index eb872b2..8f4277c 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -2304,7 +2304,7 @@ static const struct nla_policy xfrma_policy[XFRMA_MAX+1] = {
 	[XFRMA_REPLAY_ESN_VAL]	= { .len = sizeof(struct xfrm_replay_state_esn) },
 };
 
-static struct xfrm_link {
+static const struct xfrm_link {
 	int (*doit)(struct sk_buff *, struct nlmsghdr *, struct nlattr **);
 	int (*dump)(struct sk_buff *, struct netlink_callback *);
 	int (*done)(struct netlink_callback *);
@@ -2338,7 +2338,7 @@ static int xfrm_user_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	struct net *net = sock_net(skb->sk);
 	struct nlattr *attrs[XFRMA_MAX+1];
-	struct xfrm_link *link;
+	const struct xfrm_link *link;
 	int type, err;
 
 	type = nlh->nlmsg_type;
-- 
1.7.10.4
