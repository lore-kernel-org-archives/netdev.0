From: Li Yu <raise.sail@gmail.com>
Subject: [PATCH] tcp: remove useless update for flag parameter in tcp_enter_frto_loss()
Date: Wed, 28 Mar 2012 12:23:17 +0800
Message-ID: <4F729235.8040706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:48905 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804Ab2C1EXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2012 00:23:21 -0400
Received: by pbcun15 with SMTP id un15so1182299pbc.19
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 21:23:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It seem that we forget remove below two lines after copying code :)

This update never impacts others.

Sorry for last mail with legal notices improperly, I used wrong
mail.

Signed-off-by Li Yu <bingtian.ly@taobao.com>

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e886e2f..b2f8ada 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2169,8 +2169,6 @@ static void tcp_enter_frto_loss(struct sock *sk,
int allowed_segments, int flag)
 			/* For some reason this R-bit might get cleared? */
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
 				tp->retrans_out += tcp_skb_pcount(skb);
-			/* ...enter this if branch just for the first segment */
-			flag |= FLAG_DATA_ACKED;
 		} else {
 			if (TCP_SKB_CB(skb)->sacked & TCPCB_RETRANS)
 				tp->undo_marker = 0;
