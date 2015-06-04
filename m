From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: remove redundant checks II
Date: Thu, 04 Jun 2015 08:01:12 -0700
Message-ID: <1433430072.1895.40.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1433400561.1895.34.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:34090 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752058AbbFDPBP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 11:01:15 -0400
Received: by igbhj9 with SMTP id hj9so17493409igb.1
        for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 08:01:14 -0700 (PDT)
In-Reply-To: <1433400561.1895.34.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

For same reasons than in commit 12e25e1041d0 ("tcp: remove redundant
checks"), we can remove redundant checks done for timewait sockets.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |    4 ----
 net/ipv6/tcp_ipv6.c |    4 ----
 2 files changed, 8 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 3130c42240c8..d7d4c2b79cf2 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1671,10 +1671,6 @@ do_time_wait:
 		goto discard_it;
 	}
 
-	if (skb->len < (th->doff << 2)) {
-		inet_twsk_put(inet_twsk(sk));
-		goto bad_packet;
-	}
 	if (tcp_checksum_complete(skb)) {
 		inet_twsk_put(inet_twsk(sk));
 		goto csum_error;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index b72e1ffc6bb4..45a7176ed460 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1467,10 +1467,6 @@ do_time_wait:
 
 	tcp_v6_fill_cb(skb, hdr, th);
 
-	if (skb->len < (th->doff<<2)) {
-		inet_twsk_put(inet_twsk(sk));
-		goto bad_packet;
-	}
 	if (tcp_checksum_complete(skb)) {
 		inet_twsk_put(inet_twsk(sk));
 		goto csum_error;
