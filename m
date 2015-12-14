From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] netlink: fix boolean evaluation on bound
Date: Mon, 14 Dec 2015 17:55:25 +0100
Message-ID: <1450112125-29848-1-git-send-email-hannes@stressinduktion.org>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53570 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751155AbbLNQzb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2015 11:55:31 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id EF06821E30
	for <netdev@vger.kernel.org>; Mon, 14 Dec 2015 11:55:30 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

portid may be 0, thus bound will set the flag to false for in-kernel
created netlink sockets.

Fixes: da314c9923fed55 ("netlink: Replace rhash_portid with bound")
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
This patch should not affect anything and is just meant to close this
loophole in future. I based it on net, but you can also apply it to
net-next.

 net/netlink/af_netlink.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 59651af8cc2705..278e94c3c7f6d1 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1137,7 +1137,7 @@ static int netlink_insert(struct sock *sk, u32 portid)
 
 	/* We need to ensure that the socket is hashed and visible. */
 	smp_wmb();
-	nlk_sk(sk)->bound = portid;
+	nlk_sk(sk)->bound = true;
 
 err:
 	release_sock(sk);
-- 
2.5.0
