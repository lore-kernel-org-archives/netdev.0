From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 06/64] Bluetooth: Move specific Basic Mode code to the right place
Date: Mon, 10 May 2010 11:36:56 +0200
Message-ID: <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53433 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755702Ab0EJJil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:41 -0400
In-Reply-To: <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Inside "case L2CAP_MODE_BASIC:" we don't need to check for sk_type and
L2CAP mode. So only the length check is fine.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 864c76f..c9a848d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1611,11 +1611,6 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb=
, struct socket *sock, struct ms
 	if (msg->msg_flags & MSG_OOB)
 		return -EOPNOTSUPP;
=20
-	/* Check outgoing MTU */
-	if (sk->sk_type =3D=3D SOCK_SEQPACKET && pi->mode =3D=3D L2CAP_MODE_B=
ASIC &&
-	    len > pi->omtu)
-		return -EINVAL;
-
 	lock_sock(sk);
=20
 	if (sk->sk_state !=3D BT_CONNECTED) {
@@ -1635,6 +1630,12 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb=
, struct socket *sock, struct ms
=20
 	switch (pi->mode) {
 	case L2CAP_MODE_BASIC:
+		/* Check outgoing MTU */
+		if (len > pi->omtu) {
+			err =3D -EINVAL;
+			goto done;
+		}
+
 		/* Create a basic PDU */
 		skb =3D l2cap_create_basic_pdu(sk, msg, len);
 		if (IS_ERR(skb)) {
--=20
1.6.6.1

