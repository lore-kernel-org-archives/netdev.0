From: Yuchung Cheng <ycheng@google.com>
Subject: [PATCH net-next 5/6] tcp: make congestioin control more robust against reordering
Date: Thu, 14 Jan 2016 15:43:33 -0800
Message-ID: <1452815014-601-6-git-send-email-ycheng@google.com>
References: <1452815014-601-1-git-send-email-ycheng@google.com>
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:36434 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119AbcANXoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jan 2016 18:44:21 -0500
Received: by mail-pa0-f42.google.com with SMTP id yy13so291904152pab.3
        for <netdev@vger.kernel.org>; Thu, 14 Jan 2016 15:44:21 -0800 (PST)
In-Reply-To: <1452815014-601-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change enables congestion control to update cwnd based on
not only packet cumulatively acked but also packets delivered
out-of-order. This makes congestion control robust against packet
reordering because it may raise cwnd as long as packets are being
delivered once reordering has been detected (i.e., it only cares
the amount of packets delivered, not the ordering among them).

Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 2d6eaad..39c5326 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3662,7 +3662,7 @@ static int tcp_ack(struct sock *sk, const struct sk_buff *skb, int flag)
 		tcp_cwnd_reduction(sk, acked_sacked, flag);
 	} else if (tcp_may_raise_cwnd(sk, flag)) {
 		/* Advance cwnd if state allows */
-		tcp_cong_avoid(sk, ack, acked);
+		tcp_cong_avoid(sk, ack, acked_sacked);
 	}
 
 	if ((flag & FLAG_FORWARD_PROGRESS) || !(flag & FLAG_NOT_DUP)) {
-- 
2.6.0.rc2.230.g3dd15c0
