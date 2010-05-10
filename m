From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 55/64] Bluetooth: Fix race condition on l2cap_ertm_send()
Date: Mon, 10 May 2010 11:37:45 +0200
Message-ID: <dfc909befbfe967bd7f46ef33b6969c1b7f3cf42.1273484098.git.marcel@holtmann.org>
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
 <f6e6b16823de0aff31cb8ee8c098383e3aceec58.1273484097.git.marcel@holtmann.org>
 <0ee0d20855ae9271de3f6695f4cafc08ab2533bb.1273484097.git.marcel@holtmann.org>
 <812e737e29a1d559e7bfbea675fdcfcbad9f5e1f.1273484097.git.marcel@holtmann.org>
 <3b1a9f3fa6ad842991538da2c3b2e29e047b131f.1273484097.git.marcel@holtmann.org>
 <84fb0a6334af0ccad3544f6972c055d90fbb9fbe.1273484097.git.marcel@holtmann.org>
 <bd3c9e255e76ae232d417e3914ca5d80ca3e9485.1273484097.git.marcel@holtmann.org>
 <0041ecfa3025d7612fdaab12b2f07c9c3c09f42f.1273484098.git.marcel@holtmann.org>
 <afefdbc4cf3b9d409d07e1e5264e7ff88bc48711.1273484098.git.marcel@holtmann.org>
 <01760bdde9a92413b7fff928d08e19352bf09d82.1273484098.git.marcel@holtmann.org>
 <44651b85cc3a076147af5d181fc4833ef8debc59.1273484098.git.marcel@holtmann.org>
 <59203a21a56c53afeb6f45e059299e6f1437f30f.1273484098.git.marcel@holtmann.org>
 <0301ef04b5f49a95681694fc0d75af9441faa919.1273484098.git.marcel@holtmann.org>
 <a2e12a2a312f816d5970b0c809d43b399fbfe90c.1273484098.git.marcel@holtmann.org>
 <9b16dc6551cbde65d0ac525af3c46efab53a2c46.1273484098.git.marcel@holtmann.org>
 <ff12fd643334071084b6145cad3793bb6c956638.1273484098.git.marcel@holtmann.org>
 <9a9c6a34416b3743c09c00f3d6708d9df3c21629.1273484098.git.marcel@holtmann.org>
 <f11d676da4059c7888efca810ab300b931736a26.1273484098.git.marcel@holtmann.org>
 <18778a63ddc83bc89bda3b119fb02eb121512a66.1273484098.git.marcel@holtmann.org>
 <9b53350d3cf5b330c3261d89b5e62a2dc25c5653.1273484098.git.marcel@holtmann.org>
 <1890d36bb556a27684ad29654a9898ab9a5f57ee.1273484098.git.marcel@holtmann.org>
 <6161c0382bbab883a634d284f7367a88bbe88534.1273484098.git.marcel@holtmann.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755931Ab0EJJjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:13 -0400
In-Reply-To: <6161c0382bbab883a634d284f7367a88bbe88534.1273484098.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Gustavo F. Padovan <padovan@profusion.mobi>

l2cap_ertm_send() can be called both from user context and bottom half
context. The socket locks for that contexts are different, the user
context uses a mutex(which can sleep) and the second one uses a
spinlock_bh. That creates a race condition when we have interruptions o=
n
both contexts at the same time.

The better way to solve this is to add a new spinlock to lock
l2cap_ertm_send() and the vars it access. The other solution was to def=
er
l2cap_ertm_send() with a workqueue, but we the sending process already
has one defer on the hci layer. It's not a good idea add another one.

The patch refactor the code to create l2cap_retransmit_frames(), then w=
e
encapulate the lock of l2cap_ertm_send() for some call. It also changes
l2cap_retransmit_frame() to l2cap_retransmit_one_frame() to avoid
confusion

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Reviewed-by: Jo=C3=A3o Paulo Rechi Vita <jprvita@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 include/net/bluetooth/l2cap.h |    1 +
 net/bluetooth/l2cap.c         |   99 +++++++++++++++++++++++++++------=
--------
 2 files changed, 67 insertions(+), 33 deletions(-)

diff --git a/include/net/bluetooth/l2cap.h b/include/net/bluetooth/l2ca=
p.h
index d0185cc..7c695bf 100644
--- a/include/net/bluetooth/l2cap.h
+++ b/include/net/bluetooth/l2cap.h
@@ -353,6 +353,7 @@ struct l2cap_pinfo {
=20
 	__le16		sport;
=20
+	spinlock_t		send_lock;
 	struct timer_list	retrans_timer;
 	struct timer_list	monitor_timer;
 	struct timer_list	ack_timer;
diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 9d514f9..fe663e9 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1368,7 +1368,7 @@ static int l2cap_streaming_send(struct sock *sk)
 	return 0;
 }
=20
-static void l2cap_retransmit_frame(struct sock *sk, u8 tx_seq)
+static void l2cap_retransmit_one_frame(struct sock *sk, u8 tx_seq)
 {
 	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
 	struct sk_buff *skb, *tx_skb;
@@ -1467,10 +1467,29 @@ static int l2cap_ertm_send(struct sock *sk)
 	return nsent;
 }
=20
+static int l2cap_retransmit_frames(struct sock *sk)
+{
+	struct l2cap_pinfo *pi =3D l2cap_pi(sk);
+	int ret;
+
+	spin_lock_bh(&pi->send_lock);
+
+	if (!skb_queue_empty(TX_QUEUE(sk)))
+		sk->sk_send_head =3D TX_QUEUE(sk)->next;
+
+	pi->next_tx_seq =3D pi->expected_ack_seq;
+	ret =3D l2cap_ertm_send(sk);
+
+	spin_unlock_bh(&pi->send_lock);
+
+	return ret;
+}
+
 static void l2cap_send_ack(struct l2cap_pinfo *pi)
 {
 	struct sock *sk =3D (struct sock *)pi;
 	u16 control =3D 0;
+	int nframes;
=20
 	control |=3D pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT;
=20
@@ -1479,10 +1498,17 @@ static void l2cap_send_ack(struct l2cap_pinfo *=
pi)
 		pi->conn_state |=3D L2CAP_CONN_RNR_SENT;
 		l2cap_send_sframe(pi, control);
 		return;
-	} else if (l2cap_ertm_send(sk) =3D=3D 0) {
-		control |=3D L2CAP_SUPER_RCV_READY;
-		l2cap_send_sframe(pi, control);
 	}
+
+	spin_lock_bh(&pi->send_lock);
+	nframes =3D l2cap_ertm_send(sk);
+	spin_unlock_bh(&pi->send_lock);
+
+	if (nframes > 0)
+		return;
+
+	control |=3D L2CAP_SUPER_RCV_READY;
+	l2cap_send_sframe(pi, control);
 }
=20
 static void l2cap_send_srejtail(struct sock *sk)
@@ -1673,8 +1699,10 @@ static inline int l2cap_sar_segment_sdu(struct s=
ock *sk, struct msghdr *msg, siz
 		size +=3D buflen;
 	}
 	skb_queue_splice_tail(&sar_queue, TX_QUEUE(sk));
+	spin_lock_bh(&pi->send_lock);
 	if (sk->sk_send_head =3D=3D NULL)
 		sk->sk_send_head =3D sar_queue.next;
+	spin_unlock_bh(&pi->send_lock);
=20
 	return size;
 }
@@ -1745,8 +1773,15 @@ static int l2cap_sock_sendmsg(struct kiocb *iocb=
, struct socket *sock, struct ms
 				goto done;
 			}
 			__skb_queue_tail(TX_QUEUE(sk), skb);
+
+			if (pi->mode =3D=3D L2CAP_MODE_ERTM)
+				spin_lock_bh(&pi->send_lock);
+
 			if (sk->sk_send_head =3D=3D NULL)
 				sk->sk_send_head =3D skb;
+
+			if (pi->mode =3D=3D L2CAP_MODE_ERTM)
+				spin_unlock_bh(&pi->send_lock);
 		} else {
 		/* Segment SDU into multiples PDUs */
 			err =3D l2cap_sar_segment_sdu(sk, msg, len);
@@ -1754,10 +1789,13 @@ static int l2cap_sock_sendmsg(struct kiocb *ioc=
b, struct socket *sock, struct ms
 				goto done;
 		}
=20
-		if (pi->mode =3D=3D L2CAP_MODE_STREAMING)
+		if (pi->mode =3D=3D L2CAP_MODE_STREAMING) {
 			err =3D l2cap_streaming_send(sk);
-		else
+		} else {
+			spin_lock_bh(&pi->send_lock);
 			err =3D l2cap_ertm_send(sk);
+			spin_unlock_bh(&pi->send_lock);
+		}
=20
 		if (err >=3D 0)
 			err =3D len;
@@ -2321,6 +2359,7 @@ static inline void l2cap_ertm_init(struct sock *s=
k)
=20
 	__skb_queue_head_init(SREJ_QUEUE(sk));
 	__skb_queue_head_init(BUSY_QUEUE(sk));
+	spin_lock_init(&l2cap_pi(sk)->send_lock);
=20
 	INIT_WORK(&l2cap_pi(sk)->busy_work, l2cap_busy_work);
 }
@@ -3340,7 +3379,9 @@ static inline void l2cap_send_i_or_rr_or_rnr(stru=
ct sock *sk)
 	if (pi->conn_state & L2CAP_CONN_REMOTE_BUSY && pi->unacked_frames > 0=
)
 		__mod_retrans_timer();
=20
+	spin_lock_bh(&pi->send_lock);
 	l2cap_ertm_send(sk);
+	spin_unlock_bh(&pi->send_lock);
=20
 	if (!(pi->conn_state & L2CAP_CONN_LOCAL_BUSY) &&
 			pi->frames_sent =3D=3D 0) {
@@ -3857,12 +3898,8 @@ expected:
 	if (rx_control & L2CAP_CTRL_FINAL) {
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
-		else {
-			if (!skb_queue_empty(TX_QUEUE(sk)))
-				sk->sk_send_head =3D TX_QUEUE(sk)->next;
-			pi->next_tx_seq =3D pi->expected_ack_seq;
-			l2cap_ertm_send(sk);
-		}
+		else
+			l2cap_retransmit_frames(sk);
 	}
=20
 	err =3D l2cap_push_rx_skb(sk, skb, rx_control);
@@ -3907,12 +3944,8 @@ static inline void l2cap_data_channel_rrframe(st=
ruct sock *sk, u16 rx_control)
=20
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
-		else {
-			if (!skb_queue_empty(TX_QUEUE(sk)))
-				sk->sk_send_head =3D TX_QUEUE(sk)->next;
-			pi->next_tx_seq =3D pi->expected_ack_seq;
-			l2cap_ertm_send(sk);
-		}
+		else
+			l2cap_retransmit_frames(sk);
=20
 	} else {
 		if ((pi->conn_state & L2CAP_CONN_REMOTE_BUSY) &&
@@ -3920,10 +3953,13 @@ static inline void l2cap_data_channel_rrframe(s=
truct sock *sk, u16 rx_control)
 			__mod_retrans_timer();
=20
 		pi->conn_state &=3D ~L2CAP_CONN_REMOTE_BUSY;
-		if (pi->conn_state & L2CAP_CONN_SREJ_SENT)
+		if (pi->conn_state & L2CAP_CONN_SREJ_SENT) {
 			l2cap_send_ack(pi);
-		else
+		} else {
+			spin_lock_bh(&pi->send_lock);
 			l2cap_ertm_send(sk);
+			spin_unlock_bh(&pi->send_lock);
+		}
 	}
 }
=20
@@ -3940,17 +3976,10 @@ static inline void l2cap_data_channel_rejframe(=
struct sock *sk, u16 rx_control)
 	if (rx_control & L2CAP_CTRL_FINAL) {
 		if (pi->conn_state & L2CAP_CONN_REJ_ACT)
 			pi->conn_state &=3D ~L2CAP_CONN_REJ_ACT;
-		else {
-			if (!skb_queue_empty(TX_QUEUE(sk)))
-				sk->sk_send_head =3D TX_QUEUE(sk)->next;
-			pi->next_tx_seq =3D pi->expected_ack_seq;
-			l2cap_ertm_send(sk);
-		}
+		else
+			l2cap_retransmit_frames(sk);
 	} else {
-		if (!skb_queue_empty(TX_QUEUE(sk)))
-			sk->sk_send_head =3D TX_QUEUE(sk)->next;
-		pi->next_tx_seq =3D pi->expected_ack_seq;
-		l2cap_ertm_send(sk);
+		l2cap_retransmit_frames(sk);
=20
 		if (pi->conn_state & L2CAP_CONN_WAIT_F)
 			pi->conn_state |=3D L2CAP_CONN_REJ_ACT;
@@ -3966,8 +3995,12 @@ static inline void l2cap_data_channel_srejframe(=
struct sock *sk, u16 rx_control)
 	if (rx_control & L2CAP_CTRL_POLL) {
 		pi->expected_ack_seq =3D tx_seq;
 		l2cap_drop_acked_frames(sk);
-		l2cap_retransmit_frame(sk, tx_seq);
+		l2cap_retransmit_one_frame(sk, tx_seq);
+
+		spin_lock_bh(&pi->send_lock);
 		l2cap_ertm_send(sk);
+		spin_unlock_bh(&pi->send_lock);
+
 		if (pi->conn_state & L2CAP_CONN_WAIT_F) {
 			pi->srej_save_reqseq =3D tx_seq;
 			pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
@@ -3977,9 +4010,9 @@ static inline void l2cap_data_channel_srejframe(s=
truct sock *sk, u16 rx_control)
 				pi->srej_save_reqseq =3D=3D tx_seq)
 			pi->conn_state &=3D ~L2CAP_CONN_SREJ_ACT;
 		else
-			l2cap_retransmit_frame(sk, tx_seq);
+			l2cap_retransmit_one_frame(sk, tx_seq);
 	} else {
-		l2cap_retransmit_frame(sk, tx_seq);
+		l2cap_retransmit_one_frame(sk, tx_seq);
 		if (pi->conn_state & L2CAP_CONN_WAIT_F) {
 			pi->srej_save_reqseq =3D tx_seq;
 			pi->conn_state |=3D L2CAP_CONN_SREJ_ACT;
--=20
1.6.6.1

