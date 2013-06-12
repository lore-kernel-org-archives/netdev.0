From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] udp: fix two sparse errors
Date: Wed, 12 Jun 2013 14:31:39 -0700
Message-ID: <1371072699.3252.73.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:58588 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751890Ab3FLVbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 17:31:43 -0400
Received: by mail-wi0-f176.google.com with SMTP id ey16so927057wid.9
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 14:31:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit ba418fa357a7b3c ("soreuseport: UDP/IPv4 implementation")
added following sparse errors :

net/ipv4/udp.c:433:60: warning: cast from restricted __be16
net/ipv4/udp.c:433:60: warning: incorrect type in argument 1 (different base types)
net/ipv4/udp.c:433:60:    expected unsigned short [unsigned] [usertype] val
net/ipv4/udp.c:433:60:    got restricted __be16 [usertype] sport
net/ipv4/udp.c:433:60: warning: cast from restricted __be16
net/ipv4/udp.c:433:60: warning: cast from restricted __be16
net/ipv4/udp.c:514:60: warning: cast from restricted __be16
net/ipv4/udp.c:514:60: warning: incorrect type in argument 1 (different base types)
net/ipv4/udp.c:514:60:    expected unsigned short [unsigned] [usertype] val
net/ipv4/udp.c:514:60:    got restricted __be16 [usertype] sport
net/ipv4/udp.c:514:60: warning: cast from restricted __be16
net/ipv4/udp.c:514:60: warning: cast from restricted __be16

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f65bc32..959502a 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -430,7 +430,7 @@ begin:
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
 				hash = inet_ehashfn(net, daddr, hnum,
-						    saddr, htons(sport));
+						    saddr, sport);
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
@@ -511,7 +511,7 @@ begin:
 			reuseport = sk->sk_reuseport;
 			if (reuseport) {
 				hash = inet_ehashfn(net, daddr, hnum,
-						    saddr, htons(sport));
+						    saddr, sport);
 				matches = 1;
 			}
 		} else if (score == badness && reuseport) {
