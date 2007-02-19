From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 16/18] [TCP]: Prevent reordering adjustments during FRTO
Date: Mon, 19 Feb 2007 13:38:10 +0200
Message-ID: <1171885092532-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921158-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921574-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921409-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921389-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092244-git-
 send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46068 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932145AbXBSLiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:18 -0500
In-Reply-To: <1171885092244-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be honest, I'm not too sure how the reord stuff works in the
first place but this seems necessary.

When FRTO has been active, the one and only retransmission could
be unnecessary but the state and sending order might not be what
the sacktag code expects it to be (to work correctly).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 5d935b1..356de02 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1224,7 +1224,8 @@ tcp_sacktag_write_queue(struct sock *sk,
=20
 	tp->left_out =3D tp->sacked_out + tp->lost_out;
=20
-	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Loss=
)
+	if ((reord < tp->fackets_out) && icsk->icsk_ca_state !=3D TCP_CA_Loss=
 &&
+	    (tp->frto_highmark && after(tp->snd_una, tp->frto_highmark)))
 		tcp_update_reordering(sk, ((tp->fackets_out + 1) - reord), 0);
=20
 #if FASTRETRANS_DEBUG > 0
--=20
1.4.2

