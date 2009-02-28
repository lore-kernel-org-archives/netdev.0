From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 02/17] tcp: don't backtrack to sacked skbs
Date: Sat, 28 Feb 2009 16:44:27 +0200
Message-ID: <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58368 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752524AbZB1Oop (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:45 -0500
In-Reply-To: <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Backtracking to sacked skbs is a horrible performance killer
since the hint cannot be advanced successfully past them...
=2E..And it's totally unnecessary too.

In theory this is 2.6.27..28 regression but I doubt anybody
can make .28 to have worse performance because of other TCP
improvements.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index f6f61b3..2471cd4 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2065,7 +2065,7 @@ begin_fwd:
 			goto begin_fwd;
=20
 		} else if (!(sacked & TCPCB_LOST)) {
-			if (hole =3D=3D NULL && !(sacked & TCPCB_SACKED_RETRANS))
+			if (hole =3D=3D NULL && !(sacked & (TCPCB_SACKED_RETRANS|TCPCB_SACK=
ED_ACKED)))
 				hole =3D skb;
 			continue;
=20
--=20
1.5.6.5

