From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Missing sk_nulls_node_init() in ping_unhash().
Date: Fri, 01 May 2015 22:03:39 -0400 (EDT)
Message-ID: <20150501.220339.1649228322300133528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbbEBCDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 22:03:42 -0400
Received: from localhost (cpe-66-108-87-106.nyc.res.rr.com [66.108.87.106])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id E78A15915DF
	for <netdev@vger.kernel.org>; Fri,  1 May 2015 19:03:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


If we don't do that, then the poison value is left in the ->pprev
backlink.

This can cause crashes if we do a disconnect, followed by a connect().

Tested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reported-by: Wen Xu <hotdog3645@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ping.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index a93f260..05ff44b 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -158,6 +158,7 @@ void ping_unhash(struct sock *sk)
 	if (sk_hashed(sk)) {
 		write_lock_bh(&ping_table.lock);
 		hlist_nulls_del(&sk->sk_nulls_node);
+		sk_nulls_node_init(&sk->sk_nulls_node);
 		sock_put(sk);
 		isk->inet_num = 0;
 		isk->inet_sport = 0;
-- 
2.1.0
