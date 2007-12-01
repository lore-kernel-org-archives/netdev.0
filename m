From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 06/21] [TCP]: Remove local variable and use packets_in_flight directly
Date: Sun,  2 Dec 2007 00:48:01 +0200
Message-ID: <11965492962509-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11965492963603-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492964079-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296202-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296278-git-send-email-ilpo.jarvinen@helsinki.fi> <11965492961750-git-send-email-ilpo.jarvinen@helsinki.fi> <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"=?ISO-8859-1?q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46714 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802AbXLAWsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2007 17:48:20 -0500
In-Reply-To: <1196549296588-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: =3D?ISO-8859-1?q?Ilpo_J=3DE4rvinen?=3D <ilpo.jarvinen@helsinki.=
fi>

Lines won't be that long and it's compiler's job to optimize
them.

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_output.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 4cb4a7f..20365c0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1294,7 +1294,6 @@ static int tcp_mtu_probe(struct sock *sk)
 	int len;
 	int probe_size;
 	int size_needed;
-	unsigned int pif;
 	int copy;
 	int mss_now;
=20
@@ -1327,11 +1326,9 @@ static int tcp_mtu_probe(struct sock *sk)
 	if (after(tp->snd_nxt + size_needed, tp->snd_una + tp->snd_wnd))
 		return 0;
=20
-	/* Do we need to wait to drain cwnd? */
-	pif =3D tcp_packets_in_flight(tp);
-	if (pif + 2 > tp->snd_cwnd) {
-		/* With no packets in flight, don't stall. */
-		if (pif =3D=3D 0)
+	/* Do we need to wait to drain cwnd? With none in flight, don't stall=
 */
+	if (tcp_packets_in_flight(tp) + 2 > tp->snd_cwnd) {
+		if (!tcp_packets_in_flight(tp))
 			return -1;
 		else
 			return 0;
--=20
1.5.0.6

