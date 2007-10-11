From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/7] [TCP]: Fix mark_head_lost to ignore R-bit when trying to mark L
Date: Thu, 11 Oct 2007 14:41:02 +0300
Message-ID: <1192102867725-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <1192102867479-git-send-email-ilpo.jarvinen@helsinki.fi> <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46000 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754916AbXJKLlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 07:41:15 -0400
In-Reply-To: <11921028673599-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This condition (plain R) can arise at least in recovery that
is triggered after tcp_undo_loss. There isn't any reason why
they should not be marked as lost, not marking makes in_flight
estimator to return too large values.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index e40857e..c827285 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1987,7 +1987,7 @@ static void tcp_mark_head_lost(struct sock *sk,
 		cnt +=3D tcp_skb_pcount(skb);
 		if (cnt > packets || after(TCP_SKB_CB(skb)->end_seq, high_seq))
 			break;
-		if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+		if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
 			TCP_SKB_CB(skb)->sacked |=3D TCPCB_LOST;
 			tp->lost_out +=3D tcp_skb_pcount(skb);
 			tcp_verify_retransmit_hint(tp, skb);
--=20
1.5.0.6

