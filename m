From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 11/18] [TCP] FRTO: frto_counter modulo-op converted to two assignments
Date: Mon, 19 Feb 2007 13:38:05 +0200
Message-ID: <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:37500 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932135AbXBSLiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:16 -0500
In-Reply-To: <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 309da3e..9fc7f66 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2551,11 +2551,11 @@ static void tcp_process_frto(struct sock
=20
 	if (tp->frto_counter =3D=3D 1) {
 		tp->snd_cwnd =3D tcp_packets_in_flight(tp) + 2;
+		tp->frto_counter =3D 2;
 	} else /* frto_counter =3D=3D 2 */ {
 		tcp_conservative_spur_to_response(tp);
+		tp->frto_counter =3D 0;
 	}
-
-	tp->frto_counter =3D (tp->frto_counter + 1) % 3;
 }
=20
 /* This routine deals with incoming acks, but not outgoing ones. */
--=20
1.4.2

