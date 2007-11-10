From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/4] [TCP]: Add unlikely() to sacktag out-of-mem in fragment case
Date: Sat, 10 Nov 2007 12:56:01 +0200
Message-ID: <11946921622225-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11946921623177-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921623696-git-send-email-ilpo.jarvinen@helsinki.fi> <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:50870 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751253AbXKJK4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Nov 2007 05:56:05 -0500
In-Reply-To: <11946921621074-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9fc9096..84bcdc9 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1400,7 +1400,7 @@ tcp_sacktag_write_queue(struct sock *sk, struct s=
k_buff *ack_skb, u32 prior_snd_
 			/* DSACK info lost if out-of-mem, try SACK still */
 			if (in_sack <=3D 0)
 				in_sack =3D tcp_match_skb_to_sack(sk, skb, start_seq, end_seq);
-			if (in_sack < 0)
+			if (unlikely(in_sack < 0))
 				break;
=20
 			sacked =3D TCP_SKB_CB(skb)->sacked;
--=20
1.5.0.6

