From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net-ipv6: remove unused IP6_ECN_clear() function
Date: Tue, 26 Sep 2017 20:37:22 -0700
Message-ID: <20170927033722.89146-1-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34386 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965646AbdI0Dh3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 23:37:29 -0400
Received: by mail-pg0-f68.google.com with SMTP id u18so7941463pgo.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 20:37:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maciej Żenczykowski <maze@google.com>

This function is unused, and furthermore it is buggy since it suffers
from the same issue that requires IP6_ECN_set_ce() to take a pointer
to the skb so that it may (in case of CHECKSUM_COMPLETE) update skb->csum

Instead of fixing it, let's just outright remove it.

Tested: builds, and 'git grep IP6_ECN_clear' comes up empty

Signed-off-by: Maciej Żenczykowski <maze@google.com>
---
 include/net/inet_ecn.h | 5 -----
 1 file changed, 5 deletions(-)

diff --git a/include/net/inet_ecn.h b/include/net/inet_ecn.h
index dce2d586d9ce..f5ff16d72fe6 100644
--- a/include/net/inet_ecn.h
+++ b/include/net/inet_ecn.h
@@ -133,11 +133,6 @@ static inline int IP6_ECN_set_ce(struct sk_buff *skb, struct ipv6hdr *iph)
 	return 1;
 }
 
-static inline void IP6_ECN_clear(struct ipv6hdr *iph)
-{
-	*(__be32*)iph &= ~htonl(INET_ECN_MASK << 20);
-}
-
 static inline void ipv6_copy_dscp(unsigned int dscp, struct ipv6hdr *inner)
 {
 	dscp &= ~INET_ECN_MASK;
-- 
2.14.1.992.g2c7b836f3a-goog
