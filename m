From: danborkmann@iogearbox.net
Subject: [PATCH] af_packet: tpacket_destruct_skb, deref skb after BUG_ON
 assertion
Date: Sun, 09 Oct 2011 17:19:19 +0200
Message-ID: <20111009171919.10922hrx8qjm2f7b@webmail.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36186 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750853Ab1JIPwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Oct 2011 11:52:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This tiny patch derefs the skb only after BUG_ON(skb==NULL) was evaluated
and not before. Patched against latest Linus tree.

Thanks,
Daniel

Signed-off-by: Daniel Borkmann <danborkmann@iogearbox.net>

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fabb4fa..d9d833b 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1167,11 +1167,12 @@ ring_is_full:

  static void tpacket_destruct_skb(struct sk_buff *skb)
  {
-	struct packet_sock *po = pkt_sk(skb->sk);
+	struct packet_sock *po;
  	void *ph;

  	BUG_ON(skb == NULL);

+	po = pkt_sk(skb->sk);
  	if (likely(po->tx_ring.pg_vec)) {
  		ph = skb_shinfo(skb)->destructor_arg;
  		BUG_ON(__packet_get_status(po, ph) != TP_STATUS_SENDING);
