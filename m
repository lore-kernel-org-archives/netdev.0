From: Razvan Ghitulete <rghitulete@ixiacom.com>
Subject: [PATCH] net: remove wrong initialization for snd_wl1
Date: Tue, 14 Aug 2012 16:30:20 +0300
Message-ID: <1344951021-22667-1-git-send-email-rghitulete@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dbaluta@ixiacom.com>, Razvan Ghitulete <rghitulete@ixiacom.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from db3ehsobe006.messaging.microsoft.com ([213.199.154.144]:27908
	"EHLO db3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750735Ab2HNNao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2012 09:30:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The field tp->snd_wl1 is twice initialized, the second time
seems to be wrong as it may overwrite any update in tcp_ack.

Signed-off-by: Razvan Ghitulete <rghitulete@ixiacom.com>
---
 net/ipv4/tcp_input.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index fa2c2c2..c423317 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5744,7 +5744,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 
 		TCP_ECN_rcv_synack(tp, th);
 
-		tp->snd_wl1 = TCP_SKB_CB(skb)->seq;
+		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 		tcp_ack(sk, skb, FLAG_SLOWPATH);
 
 		/* Ok.. it's good. Set up sequence numbers and
@@ -5757,7 +5757,6 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 		 * never scaled.
 		 */
 		tp->snd_wnd = ntohs(th->window);
-		tcp_init_wl(tp, TCP_SKB_CB(skb)->seq);
 
 		if (!tp->rx_opt.wscale_ok) {
 			tp->rx_opt.snd_wscale = tp->rx_opt.rcv_wscale = 0;
-- 
1.7.9.5
