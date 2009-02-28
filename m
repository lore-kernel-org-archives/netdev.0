From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next 09/17] tcp: cleanup ca_state mess in tcp_timer
Date: Sat, 28 Feb 2009 16:44:34 +0200
Message-ID: <12358322832711-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <12358322821815-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821434-git-send-email-ilpo.jarvinen@helsinki.fi>
 <1235832282317-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322823783-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322821182-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322832831-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831953-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322831147-git-send-email-ilpo.jarvinen@helsinki.fi>
 <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	"=?utf-8?q?Ilpo=20J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54623 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752744AbZB1Oou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Feb 2009 09:44:50 -0500
In-Reply-To: <12358322833102-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>

Redundant checks made indentation impossible to follow.
However, it might be useful to make this ca_state+is_sack
indexed array.

Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_timer.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 0170e91..b144a26 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -328,19 +328,16 @@ static void tcp_retransmit_timer(struct sock *sk)
 	if (icsk->icsk_retransmits =3D=3D 0) {
 		int mib_idx;
=20
-		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder ||
-		    icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
-			if (tcp_is_sack(tp)) {
-				if (icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
-					mib_idx =3D LINUX_MIB_TCPSACKRECOVERYFAIL;
-				else
-					mib_idx =3D LINUX_MIB_TCPSACKFAILURES;
-			} else {
-				if (icsk->icsk_ca_state =3D=3D TCP_CA_Recovery)
-					mib_idx =3D LINUX_MIB_TCPRENORECOVERYFAIL;
-				else
-					mib_idx =3D LINUX_MIB_TCPRENOFAILURES;
-			}
+		if (icsk->icsk_ca_state =3D=3D TCP_CA_Disorder) {
+			if (tcp_is_sack(tp))
+				mib_idx =3D LINUX_MIB_TCPSACKFAILURES;
+			else
+				mib_idx =3D LINUX_MIB_TCPRENOFAILURES;
+		} else if (icsk->icsk_ca_state =3D=3D TCP_CA_Recovery) {
+			if (tcp_is_sack(tp))
+				mib_idx =3D LINUX_MIB_TCPSACKRECOVERYFAIL;
+			else
+				mib_idx =3D LINUX_MIB_TCPRENORECOVERYFAIL;
 		} else if (icsk->icsk_ca_state =3D=3D TCP_CA_Loss) {
 			mib_idx =3D LINUX_MIB_TCPLOSSFAILURES;
 		} else {
--=20
1.5.6.5

