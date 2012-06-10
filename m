From: Daniel Borkmann <danborkmann@iogearbox.net>
Subject: [PATCH] af_packet: check loop for greater than zero in tpacket_fill_skb
Date: Sun, 10 Jun 2012 21:25:08 +0200
Message-ID: <4FD4F494.6020102@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35682 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751399Ab2FJTZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 15:25:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It could be more safe to check the 'to_write' for 'greater than zero'
instead for 'not zero'. 'to_write' is of type int and subtraction operations
are performed on it, so in the case of malformed values that are
subtracted from 'to_write', it could become less than zero, which is then
interpreted as 'not zero' in the while condition, thus the loop won't
return as expected.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 net/packet/af_packet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 0f66174..3e53680 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2027,7 +2027,7 @@ static int tpacket_fill_skb(struct packet_sock *po, struct sk_buff *skb,
 	skb->truesize += to_write;
 	atomic_add(to_write, &po->sk.sk_wmem_alloc);
 
-	while (likely(to_write)) {
+	while (likely(to_write > 0)) {
 		nr_frags = skb_shinfo(skb)->nr_frags;
 
 		if (unlikely(nr_frags >= MAX_SKB_FRAGS)) {
