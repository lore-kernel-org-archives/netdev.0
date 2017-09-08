From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] ipv6: fix typo in fib6_net_exit()
Date: Fri, 08 Sep 2017 15:48:47 -0700
Message-ID: <1504910927.15310.105.camel@edumazet-glaptop3.roam.corp.google.com>
References: <204659713af1979c26b8defb2b52e1668b4e5aad.1504859062.git.sd@queasysnail.net>
         <1504893592.15310.80.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sabrina Dubroca <sd@queasysnail.net>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:36431 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752952AbdIHWsu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 18:48:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id f84so2035945pfj.3
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 15:48:50 -0700 (PDT)
In-Reply-To: <1504893592.15310.80.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 FIB should use FIB6_TABLE_HASHSZ, not FIB_TABLE_HASHSZ.

Fixes: ba1cc08d9488 ("ipv6: fix memory leak with multiple tables during netns destruction")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_fib.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)


diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 8280172c806ca47c5ca4aef723d405a0a8d7df2a..e5308d7cbd75c4fb67861082382122d445cf5b74 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -2033,7 +2033,7 @@ static void fib6_net_exit(struct net *net)
 	rt6_ifdown(net, NULL);
 	del_timer_sync(&net->ipv6.ip6_fib_timer);
 
-	for (i = 0; i < FIB_TABLE_HASHSZ; i++) {
+	for (i = 0; i < FIB6_TABLE_HASHSZ; i++) {
 		struct hlist_head *head = &net->ipv6.fib_table_hash[i];
 		struct hlist_node *tmp;
 		struct fib6_table *tb;
