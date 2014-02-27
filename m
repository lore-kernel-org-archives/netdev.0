From: Lorenzo Colitti <lorenzo@google.com>
Subject: [PATCH] net: ipv6: ping: Use socket mark in routing lookup
Date: Thu, 27 Feb 2014 13:38:26 +0900
Message-ID: <1393475906-7521-1-git-send-email-lorenzo@google.com>
Cc: David Miller <davem@davemloft.net>,
	Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:56894 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929AbaB0Eil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 23:38:41 -0500
Received: by mail-pd0-f180.google.com with SMTP id y10so1916736pdj.11
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 20:38:41 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Lorenzo Colitti <lorenzo@google.com>
---
 net/ipv6/ping.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/ping.c b/net/ipv6/ping.c
index fb9beb7..587bbdc 100644
--- a/net/ipv6/ping.c
+++ b/net/ipv6/ping.c
@@ -135,6 +135,7 @@ int ping_v6_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 	fl6.flowi6_proto = IPPROTO_ICMPV6;
 	fl6.saddr = np->saddr;
 	fl6.daddr = *daddr;
+	fl6.flowi6_mark = sk->sk_mark;
 	fl6.fl6_icmp_type = user_icmph.icmp6_type;
 	fl6.fl6_icmp_code = user_icmph.icmp6_code;
 	security_sk_classify_flow(sk, flowi6_to_flowi(&fl6));
-- 
1.9.0.rc1.175.g0b1dcb5
