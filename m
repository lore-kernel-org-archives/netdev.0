From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: do not call sock_put() on TIMEWAIT sockets
Date: Tue, 01 Oct 2013 21:04:11 -0700
Message-ID: <1380686651.19002.64.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:39742 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab3JBEEN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 00:04:13 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so314256pbc.23
        for <netdev@vger.kernel.org>; Tue, 01 Oct 2013 21:04:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 3ab5aee7fe84 ("net: Convert TCP & DCCP hash tables to use RCU /
hlist_nulls") incorrectly used sock_put() on TIMEWAIT sockets.

We should instead use inet_twsk_put()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/inet_hashtables.c  |    2 +-
 net/ipv6/inet6_hashtables.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 7bd8983..96da9c7 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -287,7 +287,7 @@ begintw:
 			if (unlikely(!INET_TW_MATCH(sk, net, acookie,
 						    saddr, daddr, ports,
 						    dif))) {
-				sock_put(sk);
+				inet_twsk_put(inet_twsk(sk));
 				goto begintw;
 			}
 			goto out;
diff --git a/net/ipv6/inet6_hashtables.c b/net/ipv6/inet6_hashtables.c
index 32b4a16..066640e 100644
--- a/net/ipv6/inet6_hashtables.c
+++ b/net/ipv6/inet6_hashtables.c
@@ -116,7 +116,7 @@ begintw:
 			}
 			if (unlikely(!INET6_TW_MATCH(sk, net, saddr, daddr,
 						     ports, dif))) {
-				sock_put(sk);
+				inet_twsk_put(inet_twsk(sk));
 				goto begintw;
 			}
 			goto out;
