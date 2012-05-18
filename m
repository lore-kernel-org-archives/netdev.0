From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: remove csummode in ip6_append_data()
Date: Fri, 18 May 2012 17:37:56 +0200
Message-ID: <1337355476.7029.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:42944 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755456Ab2ERPiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 11:38:05 -0400
Received: by bkcji2 with SMTP id ji2so2459014bkc.19
        for <netdev@vger.kernel.org>; Fri, 18 May 2012 08:38:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

csummode variable is always CHECKSUM_NONE in ip6_append_data()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/ip6_output.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index be2264e..a254e4b 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1198,7 +1198,6 @@ int ip6_append_data(struct sock *sk, int getfrag(void *from, char *to,
 	int copy;
 	int err;
 	int offset = 0;
-	int csummode = CHECKSUM_NONE;
 	__u8 tx_flags = 0;
 
 	if (flags&MSG_PROBE)
@@ -1411,7 +1410,7 @@ alloc_new_skb:
 			/*
 			 *	Fill in the control structures
 			 */
-			skb->ip_summed = csummode;
+			skb->ip_summed = CHECKSUM_NONE;
 			skb->csum = 0;
 			/* reserve for fragmentation and ipsec header */
 			skb_reserve(skb, hh_len + sizeof(struct frag_hdr) +
@@ -1454,7 +1453,6 @@ alloc_new_skb:
 			transhdrlen = 0;
 			exthdrlen = 0;
 			dst_exthdrlen = 0;
-			csummode = CHECKSUM_NONE;
 
 			/*
 			 * Put the packet on the pending queue
