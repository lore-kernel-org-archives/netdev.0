From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 10/64] Bluetooth: Use a l2cap_pinfo struct instead l2cap_pi() macro
Date: Mon, 10 May 2010 11:37:00 +0200
Message-ID: <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53433 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755653Ab0EJJio (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:44 -0400
In-Reply-To: <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Trivial clean up.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 99cf177..a9c152a 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1291,7 +1291,7 @@ static int l2cap_streaming_send(struct sock *sk)
 		control |=3D pi->next_tx_seq << L2CAP_CTRL_TXSEQ_SHIFT;
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
=20
-		if (l2cap_pi(sk)->fcs =3D=3D L2CAP_FCS_CRC16) {
+		if (pi->fcs =3D=3D L2CAP_FCS_CRC16) {
 			fcs =3D crc16(0, (u8 *)tx_skb->data, tx_skb->len - 2);
 			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
 		}
@@ -1344,7 +1344,7 @@ static int l2cap_retransmit_frame(struct sock *sk=
, u8 tx_seq)
 				| (tx_seq << L2CAP_CTRL_TXSEQ_SHIFT);
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
=20
-		if (l2cap_pi(sk)->fcs =3D=3D L2CAP_FCS_CRC16) {
+		if (pi->fcs =3D=3D L2CAP_FCS_CRC16) {
 			fcs =3D crc16(0, (u8 *)tx_skb->data, tx_skb->len - 2);
 			put_unaligned_le16(fcs, tx_skb->data + tx_skb->len - 2);
 		}
@@ -1388,7 +1388,7 @@ static int l2cap_ertm_send(struct sock *sk)
 		put_unaligned_le16(control, tx_skb->data + L2CAP_HDR_SIZE);
=20
=20
-		if (l2cap_pi(sk)->fcs =3D=3D L2CAP_FCS_CRC16) {
+		if (pi->fcs =3D=3D L2CAP_FCS_CRC16) {
 			fcs =3D crc16(0, (u8 *)skb->data, tx_skb->len - 2);
 			put_unaligned_le16(fcs, skb->data + tx_skb->len - 2);
 		}
@@ -3518,10 +3518,10 @@ static inline int l2cap_data_channel_sframe(str=
uct sock *sk, u16 rx_control, str
 		pi->expected_ack_seq =3D tx_seq;
 		l2cap_drop_acked_frames(sk);
=20
-		del_timer(&l2cap_pi(sk)->retrans_timer);
+		del_timer(&pi->retrans_timer);
 		if (rx_control & L2CAP_CTRL_POLL) {
 			u16 control =3D L2CAP_CTRL_FINAL;
-			l2cap_send_rr_or_rnr(l2cap_pi(sk), control);
+			l2cap_send_rr_or_rnr(pi, control);
 		}
 		break;
 	}
@@ -3622,7 +3622,7 @@ static inline int l2cap_data_channel(struct l2cap=
_conn *conn, u16 cid, struct sk
 		goto done;
=20
 	default:
-		BT_DBG("sk %p: bad mode 0x%2.2x", sk, l2cap_pi(sk)->mode);
+		BT_DBG("sk %p: bad mode 0x%2.2x", sk, pi->mode);
 		break;
 	}
=20
--=20
1.6.6.1

