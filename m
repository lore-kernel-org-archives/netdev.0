From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv4: fix rcu lock imbalance in
 fib_select_default()
Date: Mon, 14 Feb 2011 15:02:04 +0100
Message-ID: <1297692124.2996.30.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:57823 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172Ab1BNOCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 09:02:08 -0500
Received: by gyb11 with SMTP id 11so2060380gyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Feb 2011 06:02:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 0c838ff1ade7 (ipv4: Consolidate all default route selection
implementations.) forgot to remove one rcu_read_unlock() from
fib_select_default().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/fib_semantics.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 146bd82..562f34c 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1189,7 +1189,7 @@ void fib_select_default(struct fib_result *res)
 		fib_result_assign(res, last_resort);
 	tb->tb_default = last_idx;
 out:
-	rcu_read_unlock();
+	return;
 }
 
 #ifdef CONFIG_IP_ROUTE_MULTIPATH


