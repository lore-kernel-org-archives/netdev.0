From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Subject: [PATCH net-next 2/2] tcp: remove a redundant check for SKBTX_ACK_TSTAMP
Date: Mon, 25 Apr 2016 16:51:13 -0400
Message-ID: <1461617473-11349-2-git-send-email-soheil.kdev@gmail.com>
References: <1461617473-11349-1-git-send-email-soheil.kdev@gmail.com>
Cc: kafai@fb.com, willemb@google.com, edumazet@google.com,
	ycheng@google.com, ncardwell@google.com,
	Soheil Hassas Yeganeh <soheil@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:32806 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964853AbcDYUvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 16:51:44 -0400
Received: by mail-qg0-f66.google.com with SMTP id 7so15873669qgj.0
        for <netdev@vger.kernel.org>; Mon, 25 Apr 2016 13:51:44 -0700 (PDT)
In-Reply-To: <1461617473-11349-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil@google.com>

txstamp_ack in tcp_skb_cb is set iff the SKBTX_ACK_TSTAMP
flag is set for an skb. Thus, it is not required to check
shinfo->tx_flags if the txstamp_ack bit is checked.

Remove the check on shinfo->tx_flags & SKBTX_ACK_TSTAMP, since
it has already been checked using the txstamp_ack bit.

Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_input.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 967520d..2f3fd92 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3087,8 +3087,7 @@ static void tcp_ack_tstamp(struct sock *sk, struct sk_buff *skb,
 		return;
 
 	shinfo = skb_shinfo(skb);
-	if ((shinfo->tx_flags & SKBTX_ACK_TSTAMP) &&
-	    !before(shinfo->tskey, prior_snd_una) &&
+	if (!before(shinfo->tskey, prior_snd_una) &&
 	    before(shinfo->tskey, tcp_sk(sk)->snd_una))
 		__skb_tstamp_tx(skb, NULL, sk, SCM_TSTAMP_ACK);
 }
-- 
2.8.0.rc3.226.g39d4020
