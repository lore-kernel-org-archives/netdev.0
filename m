From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/18] [TCP] FRTO: Incorrectly clears TCPCB_EVER_RETRANS bit
Date: Mon, 19 Feb 2007 13:37:55 +0200
Message-ID: <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932122AbXBSLiO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:14 -0500
In-Reply-To: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46RTO was slightly too brave... Should only clear
TCPCB_SACKED_RETRANS bit.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 1a14191..b21e232 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1266,7 +1266,7 @@ void tcp_enter_frto(struct sock *sk)
 	tp->undo_retrans =3D 0;
=20
 	sk_stream_for_retrans_queue(skb, sk) {
-		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_RETRANS;
+		TCP_SKB_CB(skb)->sacked &=3D ~TCPCB_SACKED_RETRANS;
 	}
 	tcp_sync_left_out(tp);
=20
--=20
1.4.2

