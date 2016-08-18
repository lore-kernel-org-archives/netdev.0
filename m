From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: ipv4: fix sparse error in fib_good_nh()
Date: Thu, 18 Aug 2016 10:19:34 -0700
Message-ID: <1471540774.29842.76.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36270 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753982AbcHSDBC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 23:01:02 -0400
Received: by mail-pf0-f195.google.com with SMTP id y134so689516pfg.3
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 20:00:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fixes following sparse errors :

net/ipv4/fib_semantics.c:1579:61: warning: incorrect type in argument 2
(different base types)
net/ipv4/fib_semantics.c:1579:61:    expected unsigned int [unsigned]
[usertype] key
net/ipv4/fib_semantics.c:1579:61:    got restricted __be32 const
[usertype] nh_gw


Fixes: a6db4494d218c ("net: ipv4: Consider failed nexthops in multipath routes")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/fib_semantics.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 539fa264e67d..8066ccc48a17 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1576,7 +1576,8 @@ static bool fib_good_nh(const struct fib_nh *nh)
 
 		rcu_read_lock_bh();
 
-		n = __ipv4_neigh_lookup_noref(nh->nh_dev, nh->nh_gw);
+		n = __ipv4_neigh_lookup_noref(nh->nh_dev,
+					      (__force u32)nh->nh_gw);
 		if (n)
 			state = n->nud_state;
 
