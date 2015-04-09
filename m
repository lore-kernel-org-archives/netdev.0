From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: md5: fix a typo in tcp_v4_md5_lookup()
Date: Thu, 09 Apr 2015 14:36:42 -0700
Message-ID: <1428615402.25985.280.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:33613 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754288AbbDIVgp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 17:36:45 -0400
Received: by ignm3 with SMTP id m3so3306857ign.0
        for <netdev@vger.kernel.org>; Thu, 09 Apr 2015 14:36:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Lookup key for tcp_md5_do_lookup() has to be taken
from addr_sk, not sk (which can be the listener)

Fixes: fd3a154a00fb ("tcp: md5: get rid of tcp_v[46]_reqsk_md5_lookup()")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 560f9571f7c43957b5996957ebed5f093fff6d75..37578d52897e58942b6e6b8ef4e8db6f0f245b85 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -897,9 +897,9 @@ EXPORT_SYMBOL(tcp_md5_do_lookup);
 struct tcp_md5sig_key *tcp_v4_md5_lookup(struct sock *sk,
 					 const struct sock *addr_sk)
 {
-	union tcp_md5_addr *addr;
+	const union tcp_md5_addr *addr;
 
-	addr = (union tcp_md5_addr *)&sk->sk_daddr;
+	addr = (const union tcp_md5_addr *)&addr_sk->sk_daddr;
 	return tcp_md5_do_lookup(sk, addr, AF_INET);
 }
 EXPORT_SYMBOL(tcp_v4_md5_lookup);
