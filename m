From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 31/64] Bluetooth: Change acknowledgement to use the value of txWindow
Date: Mon, 10 May 2010 11:37:21 +0200
Message-ID: <803020c6fa63aa738cfda3329c9675b42023e9d2.1273484097.git.marcel@holtmann.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755843Ab0EJJi6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:38:58 -0400
In-Reply-To: <14b5aa71ec506f4e38ca6a1dc02ecd668ecfd902.1273484097.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

Now that we can set the txWindow we need to change the acknowledgement
procedure to ack after each (pi->txWindow/6 + 1). The plus 1 is to avoi=
d
the zero value.
It also renames pi->num_to_ack to a better name: pi->num_acked.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    3 +--
 net/bluetooth/l2cap.c         |    7 ++++---
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index 07ae4cc..059260b 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -30,7 +30,6 @@
 #define L2CAP_DEFAULT_MIN_MTU		48
 #define L2CAP_DEFAULT_FLUSH_TO		0xffff
 #define L2CAP_DEFAULT_TX_WINDOW		63
-#define L2CAP_DEFAULT_NUM_TO_ACK        (L2CAP_DEFAULT_TX_WINDOW/5)
 #define L2CAP_DEFAULT_MAX_TX		3
 #define L2CAP_DEFAULT_RETRANS_TO	1000    /* 1 second */
 #define L2CAP_DEFAULT_MONITOR_TO	12000   /* 12 seconds */
@@ -333,7 +332,7 @@ struct l2cap_pinfo {
 	__u8		frames_sent;
 	__u8		unacked_frames;
 	__u8		retry_count;
-	__u8		num_to_ack;
+	__u8		num_acked;
 	__u16		sdu_len;
 	__u16		partial_sdu_len;
 	struct sk_buff	*sdu;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 5300796..0b0b237 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -2254,7 +2254,7 @@ static inline void l2cap_ertm_init(struct sock *s=
k)
 	l2cap_pi(sk)->expected_ack_seq =3D 0;
 	l2cap_pi(sk)->unacked_frames =3D 0;
 	l2cap_pi(sk)->buffer_seq =3D 0;
-	l2cap_pi(sk)->num_to_ack =3D 0;
+	l2cap_pi(sk)->num_acked =3D 0;
 	l2cap_pi(sk)->frames_sent =3D 0;
=20
 	setup_timer(&l2cap_pi(sk)->retrans_timer,
@@ -3466,6 +3466,7 @@ static inline int l2cap_data_channel_iframe(struc=
t sock *sk, u16 rx_control, str
 	u8 tx_seq =3D __get_txseq(rx_control);
 	u8 req_seq =3D __get_reqseq(rx_control);
 	u8 sar =3D rx_control >> L2CAP_CTRL_SAR_SHIFT;
+	int num_to_ack =3D (pi->tx_win/6) + 1;
 	int err =3D 0;
=20
 	BT_DBG("sk %p rx_control 0x%4.4x len %d", sk, rx_control, skb->len);
@@ -3553,8 +3554,8 @@ expected:
=20
 	__mod_ack_timer();
=20
-	pi->num_to_ack =3D (pi->num_to_ack + 1) % L2CAP_DEFAULT_NUM_TO_ACK;
-	if (pi->num_to_ack =3D=3D L2CAP_DEFAULT_NUM_TO_ACK - 1)
+	pi->num_acked =3D (pi->num_acked + 1) % num_to_ack;
+	if (pi->num_acked =3D=3D num_to_ack - 1)
 		l2cap_send_ack(pi);
=20
 	return 0;
--=20
1.6.6.1

