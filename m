From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 4/4] [TCP]: Wrap-safed reordering detection FRTO check
Date: Mon,  1 Oct 2007 15:29:44 +0300
Message-ID: <119124178462-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11912417841620-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417843256-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417843258-git-send-email-ilpo.jarvinen@helsinki.fi> <11912417841037-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:51017 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751447AbXJAM3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 08:29:46 -0400
In-Reply-To: <11912417841037-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case somebody has a suggestion about a better place for this
check, which must guarantee execution "early enough" (i.e,
before the wrap can occur), I'm very open to them.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index cec2611..e22ffe7 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -3024,6 +3024,9 @@ static int tcp_ack(struct sock *sk, struct sk_buf=
f *skb, int flag)
 	/* See if we can take anything off of the retransmit queue. */
 	flag |=3D tcp_clean_rtx_queue(sk, &seq_rtt);
=20
+	/* Guarantee sacktag reordering detection against wrap-arounds */
+	if (before(tp->frto_highmark, tp->snd_una))
+		tp->frto_highmark =3D 0;
 	if (tp->frto_counter)
 		frto_cwnd =3D tcp_process_frto(sk, flag);
=20
--=20
1.5.0.6

