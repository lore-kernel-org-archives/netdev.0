From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 1/9] [TCP]: Make invariant check complain about invalid sacked_out
Date: Mon, 31 Dec 2007 12:47:49 +0200
Message-ID: <1199098077874-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42223 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797AbXLaKr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Dec 2007 05:47:59 -0500
In-Reply-To: <11990980772344-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Earlier resolution for NewReno's sacked_out should now keep
it small enough for this to become invariant-like check.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 722c9cb..41f4b86 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -2504,11 +2504,8 @@ tcp_fastretrans_alert(struct sock *sk, int pkts_=
acked, int flag)
 				    (tcp_fackets_out(tp) > tp->reordering));
 	int fast_rexmit =3D 0;
=20
-	/* Some technical things:
-	 * 1. Reno does not count dupacks (sacked_out) automatically. */
-	if (!tp->packets_out)
+	if (WARN_ON(!tp->packets_out && tp->sacked_out))
 		tp->sacked_out =3D 0;
-
 	if (WARN_ON(!tp->sacked_out && tp->fackets_out))
 		tp->fackets_out =3D 0;
=20
--=20
1.5.0.6

