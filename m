From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ip_gre: comments change
Date: Thu, 30 Sep 2010 07:32:57 +0200
Message-ID: <1285824777.5211.663.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40349 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753733Ab0I3FdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 01:33:04 -0400
Received: by fxm4 with SMTP id 4so485377fxm.19
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 22:33:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HARD_TX_LOCK no longer protects tunnels from dead loops,
but xmit_recursion percpu counter.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/ip_gre.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 035db63..fbe2c47 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -64,13 +64,13 @@
    We cannot track such dead loops during route installation,
    it is infeasible task. The most general solutions would be
    to keep skb->encapsulation counter (sort of local ttl),
-   and silently drop packet when it expires. It is the best
+   and silently drop packet when it expires. It is a good
    solution, but it supposes maintaing new variable in ALL
    skb, even if no tunneling is used.
 
-   Current solution: HARD_TX_LOCK lock breaks dead loops.
-
-
+   Current solution: xmit_recursion breaks dead loops. This is a percpu
+   counter, since when we enter the first ndo_xmit(), cpu migration is
+   forbidden. We force an exit if this counter reaches RECURSION_LIMIT
 
    2. Networking dead loops would not kill routers, but would really
    kill network. IP hop limit plays role of "t->recursion" in this case,


