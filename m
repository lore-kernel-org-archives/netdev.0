From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 11/17] htcp: merge icsk_ca_state compare
Date: Sat, 28 Feb 2009 16:44:36 +0200
Message-ID: <1235832283214-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:56777 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752773AbZB1Oow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:52 -0500
In-Reply-To: <12358322834113-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Similar to what is done elsewhere in TCP code when double
state checks are being done.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_htcp.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp_htcp.c
index 937549b..9520eec 100644
--- a/net/ipv4/tcp_htcp.c
+++ b/net/ipv4/tcp_htcp.c
@@ -115,8 +115,7 @@ static void measure_achieved_throughput(struct sock=
 *sk, u32 pkts_acked, s32 rtt
 		return;
=20
 	/* achieved throughput calculations */
-	if (icsk->icsk_ca_state !=3D TCP_CA_Open &&
-	    icsk->icsk_ca_state !=3D TCP_CA_Disorder) {
+	if (!((1 << icsk->icsk_ca_state) & (TCPF_CA_Open | TCPF_CA_Disorder))=
) {
 		ca->packetcount =3D 0;
 		ca->lasttime =3D now;
 		return;
--=20
1.5.6.5

