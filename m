From: Jakub Sitnicki <jkbs@redhat.com>
Subject: [PATCH net-next] ipv6: Avoid going through ->sk_net to access the netns
Date: Mon, 31 Jul 2017 10:09:41 +0200
Message-ID: <20170731080941.4920-1-jkbs@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f182.google.com ([209.85.128.182]:36355 "EHLO
        mail-wr0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751623AbdGaIJo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 04:09:44 -0400
Received: by mail-wr0-f182.google.com with SMTP id y43so175810715wrd.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 01:09:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is no need to go through sk->sk_net to access the net namespace
and its sysctl variables because we allocate the sock and initialize
sk_net just a few lines earlier in the same routine.

Signed-off-by: Jakub Sitnicki <jkbs@redhat.com>
---
 net/ipv6/af_inet6.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index a88b5b5..0a7c740 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -210,7 +210,7 @@ static int inet6_create(struct net *net, struct socket *sock, int protocol,
 	np->mcast_hops	= IPV6_DEFAULT_MCASTHOPS;
 	np->mc_loop	= 1;
 	np->pmtudisc	= IPV6_PMTUDISC_WANT;
-	np->autoflowlabel = ip6_default_np_autolabel(sock_net(sk));
+	np->autoflowlabel = ip6_default_np_autolabel(net);
 	sk->sk_ipv6only	= net->ipv6.sysctl.bindv6only;
 
 	/* Init the ipv4 part of the socket since we can have sockets
-- 
2.9.4
