From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 34/64] Bluetooth: Fix bug when retransmitting I-frames
Date: Mon, 10 May 2010 11:37:24 +0200
Message-ID: <f6e6b16823de0aff31cb8ee8c098383e3aceec58.1273484097.git.marcel@holtmann.org>
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
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
 <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
 <8abb52ee00c4b3f857269eb6b7145991bab869bf.1273484096.git.marcel@holtmann.org>
 <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
 <c1b4f43be01c2a363be021485dd18cca33cfab8a.1273484097.git.marcel@holtmann.org>
 <2fb862e215e53630066c677e06d7551fa38bf235.1273484097.git.marcel@holtmann.org>
 <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
 <1c7621596d11b9c3e19eb88a818758dee4901c95.1273484097.git.marcel@holtmann.org>
 <10467e9e9b89272b25b56688bb276d0830e9ab9a.1273484097.git.marcel@holtmann.org>
 <052897ca5019d9157ae09e5e84eee2a9ef5dccc6.1273484097.git.marcel@holtmann.org>
 <855666cccc939d392316de17512e17a08b2fa05a.1273484097.git.marcel@holtmann.org>
 <14b5aa71ec506f4e38ca6a1dc02ecd668ecfd902.1273484097.git.marcel@holtmann.org>
 <803020c6fa63aa738cfda3329c9675b42023e9d2.1273484097.git.marcel@holtmann.org>
 <369ba30264826f38eefc61b93688100be8adbd4d.1273484097.git.marcel@holtmann.org>
 <68d7f0ce911e41e463c45911be031cdf6a096fe8.1273484097.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53460 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755863Ab0EJJjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:00 -0400
In-Reply-To: <68d7f0ce911e41e463c45911be031cdf6a096fe8.1273484097.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

If there is no frames to retransmit l2cap was crashing the kernel, now
we check if the queue is empty first.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index f9e4da2..4c7b2d2 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3546,7 +3546,8 @@ expected:
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
 		else {
-			sk->sk_send_head =3D TX_QUEUE(sk)->next;
+			if (!skb_queue_empty(TX_QUEUE(sk)))
+				sk->sk_send_head =3D TX_QUEUE(sk)->next;
 			pi->next_tx_seq =3D pi->expected_ack_seq;
 			l2cap_ertm_send(sk);
 		}
@@ -3593,7 +3594,8 @@ static inline void l2cap_data_channel_rrframe(str=
uct sock *sk, u16 rx_control)
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
 		else {
-			sk->sk_send_head =3D TX_QUEUE(sk)->next;
+			if (!skb_queue_empty(TX_QUEUE(sk)))
+				sk->sk_send_head =3D TX_QUEUE(sk)->next;
 			pi->next_tx_seq =3D pi->expected_ack_seq;
 			l2cap_ertm_send(sk);
 		}
@@ -3625,12 +3627,14 @@ static inline void l2cap_data_channel_rejframe(=
struct sock *sk, u16 rx_control)
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
 		else {
-			sk->sk_send_head =3D TX_QUEUE(sk)->next;
+			if (!skb_queue_empty(TX_QUEUE(sk)))
+				sk->sk_send_head =3D TX_QUEUE(sk)->next;
 			pi->next_tx_seq =3D pi->expected_ack_seq;
 			l2cap_ertm_send(sk);
 		}
 	} else {
-		sk->sk_send_head =3D TX_QUEUE(sk)->next;
+		if (!skb_queue_empty(TX_QUEUE(sk)))
+			sk->sk_send_head =3D TX_QUEUE(sk)->next;
 		pi->next_tx_seq =3D pi->expected_ack_seq;
 		l2cap_ertm_send(sk);
=20
--=20
1.6.6.1

