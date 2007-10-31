From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 2/2] [TCP]: Another TAGBITS -> SACKED_ACKED|LOST conversion
Date: Wed, 31 Oct 2007 11:49:59 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0710311149020.16864@kivilampi-30.cs.helsinki.fi>
References: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1365841998-1193824199=:16864"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55863 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754345AbXJaJuA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 05:50:00 -0400
In-Reply-To: <Pine.LNX.4.64.0710311136200.16864@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1365841998-1193824199=:16864
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Similar to commit 3eec0047d9bdd, point of this is to avoid
skipping R-bit skbs.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 4d72781..ca9590f 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2078,7 +2078,7 @@ static void tcp_update_scoreboard(struct sock *sk)
 			if (!tcp_skb_timedout(sk, skb))
 				break;
 
-			if (!(TCP_SKB_CB(skb)->sacked&TCPCB_TAGBITS)) {
+			if (!(TCP_SKB_CB(skb)->sacked & (TCPCB_SACKED_ACKED|TCPCB_LOST))) {
 				TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
 				tp->lost_out += tcp_skb_pcount(skb);
 				tcp_verify_retransmit_hint(tp, skb);
-- 
1.5.0.6

---696243703-1365841998-1193824199=:16864--
