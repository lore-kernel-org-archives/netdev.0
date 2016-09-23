From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix a compile error in DBGUNDO()
Date: Thu, 22 Sep 2016 17:54:00 -0700
Message-ID: <1474592040.28155.15.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34237 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754131AbcIWAyC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 20:54:02 -0400
Received: by mail-pf0-f195.google.com with SMTP id 21so4457726pfy.1
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 17:54:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

If DBGUNDO() is enabled (FASTRETRANS_DEBUG > 1), a compile
error will happen, since inet6_sk(sk)->daddr became sk->sk_v6_daddr

Fixes: efe4208f47f9 ("ipv6: make lookups simpler and faster")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 08323bd95f2a..a756b8749a26 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2329,10 +2329,9 @@ static void DBGUNDO(struct sock *sk, const char *msg)
 	}
 #if IS_ENABLED(CONFIG_IPV6)
 	else if (sk->sk_family == AF_INET6) {
-		struct ipv6_pinfo *np = inet6_sk(sk);
 		pr_debug("Undo %s %pI6/%u c%u l%u ss%u/%u p%u\n",
 			 msg,
-			 &np->daddr, ntohs(inet->inet_dport),
+			 &sk->sk_v6_daddr, ntohs(inet->inet_dport),
 			 tp->snd_cwnd, tcp_left_out(tp),
 			 tp->snd_ssthresh, tp->prior_ssthresh,
 			 tp->packets_out);
