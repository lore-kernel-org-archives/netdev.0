From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-2.6] net/ipv6/udp.c: fix typo in flush_stack()
Date: Thu, 9 Dec 2010 14:40:30 +0100
Message-ID: <20101209134029.GB2820@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, eric.dumazet@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:12457 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747Ab0LINke (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 08:40:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

skb1 should be passed as parameter to sk_rcvqueues_full() here.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 91def93..d2b268e 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -602,7 +602,7 @@ static void flush_stack(struct sock **stack, unsigned int count,
 
 		sk = stack[i];
 		if (skb1) {
-			if (sk_rcvqueues_full(sk, skb)) {
+			if (sk_rcvqueues_full(sk, skb1)) {
 				kfree_skb(skb1);
 				goto drop;
 			}
