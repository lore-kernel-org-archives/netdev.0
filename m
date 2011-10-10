From: danborkmann@iogearbox.net
Subject: [PATCH] af_packet: remove unnecessary BUG_ON() in
 tpacket_destruct_skb
Date: Mon, 10 Oct 2011 18:52:46 +0200
Message-ID: <20111010185246.15533bv1p3pmnba6@mail.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8;
 DelSp="Yes";
 format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:34990 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753076Ab1JJQzo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 12:55:44 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If skb is NULL, then stack trace is thrown anyway on dereference.
Therefore, the stack trace triggered by BUG_ON is duplicate.

Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
---
  net/packet/af_packet.c |    2 --
  1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index fabb4fa..886ae50 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1170,8 +1170,6 @@ static void tpacket_destruct_skb(struct sk_buff *skb)
  	struct packet_sock *po = pkt_sk(skb->sk);
  	void *ph;

-	BUG_ON(skb == NULL);
-
  	if (likely(po->tx_ring.pg_vec)) {
  		ph = skb_shinfo(skb)->destructor_arg;
  		BUG_ON(__packet_get_status(po, ph) != TP_STATUS_SENDING);
