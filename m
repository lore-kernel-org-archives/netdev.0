From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 16/17] ipv6: kill ICMP6MSGIN_INC_STATS_BH()
Date: Wed, 27 Apr 2016 16:44:42 -0700
Message-ID: <1461800683-25034-17-git-send-email-edumazet@google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33842 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753189AbcD0Xpb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:45:31 -0400
Received: by mail-pa0-f47.google.com with SMTP id r5so25339495pag.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:45:29 -0700 (PDT)
In-Reply-To: <1461800683-25034-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 ICMP stats are atomics anyway.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h | 4 +---
 net/ipv6/icmp.c    | 2 +-
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9f3b53f2819b..64ce3670d40a 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -184,9 +184,7 @@ extern int sysctl_mld_qrv;
 
 #define ICMP6MSGOUT_INC_STATS(net, idev, field)		\
 	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
-#define ICMP6MSGOUT_INC_STATS_BH(net, idev, field)	\
-	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field +256)
-#define ICMP6MSGIN_INC_STATS_BH(net, idev, field)	\
+#define ICMP6MSGIN_INC_STATS(net, idev, field)	\
 	_DEVINC_ATOMIC_ATOMIC(net, icmpv6msg, idev, field)
 
 struct ip6_ra_chain {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 823a1fc576e3..23b9a4cc418e 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -728,7 +728,7 @@ static int icmpv6_rcv(struct sk_buff *skb)
 
 	type = hdr->icmp6_type;
 
-	ICMP6MSGIN_INC_STATS_BH(dev_net(dev), idev, type);
+	ICMP6MSGIN_INC_STATS(dev_net(dev), idev, type);
 
 	switch (type) {
 	case ICMPV6_ECHO_REQUEST:
-- 
2.8.0.rc3.226.g39d4020
