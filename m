From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv6: add missing lock in ping_v6_sendmsg
Date: Thu,  4 Jul 2013 00:52:49 +0900
Message-ID: <1372866769-11219-1-git-send-email-lorenzo@google.com>
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>, lorenzo@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ye0-f201.google.com ([209.85.213.201]:54648 "EHLO
	mail-ye0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932081Ab3GCPwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 11:52:54 -0400
Received: by mail-ye0-f201.google.com with SMTP id m7so26264yen.2
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 08:52:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/ping.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index 2b52046..10b9755 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -174,6 +174,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	if (hlimit < 0)
 		hlimit = ip6_dst_hoplimit(dst);
 
+	lock_sock(sk);
 	err = ip6_append_data(sk, ping_getfrag, &pfh, len,
 			      0, hlimit,
 			      np->tclass, NULL, &fl6, rt,
@@ -188,6 +189,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 						 (struct icmp6hdr *) &pfh.icmph,
 						 len);
 	}
+	release_sock(sk);
 
 	return err;
 }
-- 
1.8.3
