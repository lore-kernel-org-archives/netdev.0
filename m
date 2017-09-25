From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] inetpeer: fix RCU lookup() again
Date: Mon, 25 Sep 2017 08:40:02 -0700
Message-ID: <1506354002.6617.10.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:37118 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933656AbdIYPkE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 11:40:04 -0400
Received: by mail-pg0-f65.google.com with SMTP id v5so5053330pgn.4
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 08:40:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

My prior fix was not complete, as we were dereferencing a pointer
three times per node, not twice as I initially thought.

Fixes: 4cc5b44b29a9 ("inetpeer: fix RCU lookup()")
Fixes: b145425f269a ("inetpeer: remove AVL implementation in favor of RB tree")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inetpeer.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index e7eb590c86ce2b33654c17c61619de74ff07bfd1..b20c8ac640811e1b4c5416134181dd77675db878 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -128,9 +128,9 @@ static struct inet_peer *lookup(const struct inetpeer_addr *daddr,
 			break;
 		}
 		if (cmp == -1)
-			pp = &(*pp)->rb_left;
+			pp = &next->rb_left;
 		else
-			pp = &(*pp)->rb_right;
+			pp = &next->rb_right;
 	}
 	*parent_p = parent;
 	*pp_p = pp;
