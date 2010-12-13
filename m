From: Yoichi Yuasa <yuasa@linux-mips.org>
Subject: [PATCH net-next-2.6] tcp: clean up twisted goto in
 tcp_rcv_synsent_state_process()
Date: Mon, 13 Dec 2010 17:11:49 +0900
Message-ID: <20101213171149.16f178ef.yuasa@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yuasa@linux-mips.org, netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f170.google.com ([209.85.214.170]:54804 "EHLO
	mail-iw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752929Ab0LMILy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 03:11:54 -0500
Received: by iwn6 with SMTP id 6so8768906iwn.1
        for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 00:11:53 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yoichi Yuasa <yuasa@linux-mips.org>
---
 net/ipv4/tcp_input.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 824e8c8..ae4200c 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5623,9 +5623,7 @@ static int tcp_rcv_synsent_state_process(struct sock *sk, struct sk_buff *skb,
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  TCP_DELACK_MAX, TCP_RTO_MAX);
 
-discard:
-			__kfree_skb(skb);
-			return 0;
+			goto discard;
 		} else {
 			tcp_send_ack(sk);
 		}
@@ -5704,7 +5702,9 @@ discard:
 discard_and_undo:
 	tcp_clear_options(&tp->rx_opt);
 	tp->rx_opt.mss_clamp = saved_clamp;
-	goto discard;
+discard:
+	__kfree_skb(skb);
+	return 0;
 
 reset_and_undo:
 	tcp_clear_options(&tp->rx_opt);
-- 
1.7.3.3

