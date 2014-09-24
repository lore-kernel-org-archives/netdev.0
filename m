From: Weiping Pan <panweiping3@gmail.com>
Subject: [PATCH net-next] tcp: use tcp_flags in tcp_data_queue()
Date: Wed, 24 Sep 2014 18:35:07 +0800
Message-ID: <08ce1deee03778416354009d6e11ded50e76fc2a.1411554808.git.panweiping3@gmail.com>
Cc: edumazet@google.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58652 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752848AbaIXKfS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 06:35:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Follow the idea in commit e11ecddf5128 (tcp: use TCP_SKB_CB(skb)->tcp_flags in
input path), we can use tcp_flags to avoid cache miss.

Signed-off-by: Weiping Pan <panweiping3@gmail.com>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 13f3da4..85298c9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4392,7 +4392,7 @@ queue_and_out:
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
-		if (th->fin)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
-- 
1.7.4
