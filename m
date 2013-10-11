From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] inet_diag: use sock_gen_put()
Date: Fri, 11 Oct 2013 08:54:49 -0700
Message-ID: <1381506889.4971.104.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:35738 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758363Ab3JKPy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 11:54:57 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so4408459pbb.0
        for <netdev@vger.kernel.org>; Fri, 11 Oct 2013 08:54:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

TCP listener refactoring, part 6 :

Use sock_gen_put() from inet_diag_dump_one_icsk() for future
SYN_RECV support.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_diag.c |    9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/inet_diag.c b/net/ipv4/inet_diag.c
index 41e1c3e..56a964a 100644
--- a/net/ipv4/inet_diag.c
+++ b/net/ipv4/inet_diag.c
@@ -336,12 +336,9 @@ int inet_diag_dump_one_icsk(struct inet_hashinfo *hashinfo, struct sk_buff *in_s
 		err = 0;
 
 out:
-	if (sk) {
-		if (sk->sk_state == TCP_TIME_WAIT)
-			inet_twsk_put((struct inet_timewait_sock *)sk);
-		else
-			sock_put(sk);
-	}
+	if (sk)
+		sock_gen_put(sk);
+
 out_nosk:
 	return err;
 }
