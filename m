From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 3/3] [TCP]: NAGLE_PUSH seems to be a wrong way around
Date: Tue,  4 Dec 2007 18:48:50 +0200
Message-ID: <1196786930388-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11967869303114-git-send-email-ilpo.jarvinen@helsinki.fi> <11967869303567-git-send-email-ilpo.jarvinen@helsinki.fi> <11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:52984 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbXLDQsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 11:48:52 -0500
In-Reply-To: <11967869303709-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

The comment in tcp_nagle_test suggests that. This bug is very
very old, even 2.4.0 seems to have it.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d83c65..6110459 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1157,8 +1157,7 @@ int tcp_may_send_now(struct sock *sk)
 	return (skb &&
 		tcp_snd_test(sk, skb, tcp_current_mss(sk, 1),
 			     (tcp_skb_is_last(sk, skb) ?
-			      TCP_NAGLE_PUSH :
-			      tp->nonagle)));
+			      tp->nonagle : TCP_NAGLE_PUSH)));
 }
=20
 /* Trim TSO SKB to LEN bytes, put the remaining data into a new packet
--=20
1.5.0.6

