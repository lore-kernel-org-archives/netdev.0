From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 45/47] Bluetooth: Acknowledge L2CAP packets when receiving RR-frames (F-bit=1)
Date: Sun, 30 Aug 2009 01:50:59 -0700
Message-ID: <ca42a613c92d131ff02d5714419d58c36c3459f3.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
 <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
 <e7a25f9839fd392ec2c96e7e2b3734501d761a24.1251621661.git.marcel@holtmann.org>
 <08b0b0ce8c609b0e2284b134f0614e211374a038.1251621661.git.marcel@holtmann.org>
 <944fe798c6a48336e82bbc0d4e280587325a4d95.1251621661.git.marcel@holtmann.org>
 <542399037d0cb2b2e96dfb8ced35b07dfb1c3706.1251621661.git.marcel@holtmann.org>
 <4271e08d8b799171af18d7864908ec444282efe5.1251621661.git.marcel@holtmann.org>
 <dcf47f3bc798888f9ea40b9f626d669dc62086bf.1251621661.git.marcel@holtmann.org>
 <9666fb356da78a5ec28403197d72e8cd6aa16424.1251621661.git.marcel@holtmann.org>
 <60dee5ccd789ee8a380eee802b6cb24c52123428.1251621661.git.marcel@holtmann.org>
 <91d697302b291205171840bfe84c1563e171acb2.1251621661.git.marcel@holtmann.org>
 <e0721f99ba33d13a88746732be2d74ca805abf55.1251621661.git.marcel@holtmann.org>
 <9374253ffe609f2d70dd5ae280182cb6f08fef08.1251621661.git.marcel@holtmann.org>
 <3318b2362bf0528be77123c480249663557dfbfc.1251621661.git.marcel@holtmann.org>
 <5959809ded86e267c1a95fb44738a224c30d3434.1251621661.git.marcel@holtmann.org>
 <a6a67efd7088702fdbbb780c5a3f8e1a74e77b63.1251621661.git.marcel@holtmann.org>
 <52d18347dfb61519aa0f58fe1759edd3ad8c4e36.1251621661.git.marcel@holtmann.org>
 <44dd46de325c4d47abfd1361e5d84a548edb8e42.1251621661.git.marcel@holtmann.org>
 <c6b03cf986eab00e20d0dbc852b233bb83472138.1251621661.git.marcel@holtmann.org>
 <65c7c4918450f8c4545ccb02a9c7a3d77e073535.1251621661.git.marcel@holtmann.org>
 <f2fcfcd670257236ebf2088bbdf26f6a8ef459fe.1251621661.git.marcel@holtmann.org>
 <22121fc9152ca8f25a2d790860832ccb6a414c4d.1251621661.git.marcel@holtmann.org>
 <1c2acffb76d4bc5fd27c4ea55cc27ad8ead10f9a.1251621661.git.marcel@holtmann.org>
 <c74e560cd0101455f1889515e1527e4c2e266113.1251621661.git.marcel@holtmann.org>
 <30afb5b2aa83adf4f69e5090d48e1bb04b64c58a.1251621661.git.marcel@holtmann.org>
 <e90bac061b17cd81bd0df30606c64f4543bf5ca0.1251621661.git.marcel@holtmann.org>
 <6840ed0770d79b9bb0800e5e026a067040ef18f5.1251621661.git.marcel@holtmann.org>
 <fcc203c30d72dde82692f6b761a80e5ca5fdd8fa.1251621661.git.marcel@holtmann.org>
 <8f17154f1f70fcc6faa31ac82164fcf7f0599f38.1251621661.git.marcel@holtmann.org>
 <ef54fd937fbd5ebaeb023818524565bd526a5f36.1251621661.git.marcel@holtmann.org>
 <9e726b17422bade75fba94e625cd35fd1353e682.1251621661.git.marcel@holtmann.org>
 <e686219a64fee9be9ce438dc3f040cd71ddd168a.1251621661.git.marcel@holtmann.org>
 <1b7bf4edca0fdbad70c44e139f4cfebd6759de81.1251621661.git.marcel@holtmann.org>
 <d2e353f7c3c5fbb3add0341c10ae167ee745d23b.1251621661.git.marcel@holtmann.org>
 <7bee549e197c9c0e92b89857a409675c1d5e9dff.1251621661.git.marcel@holtmann.org>
 <cbe86b98a6aceefe943ada1471eb52fd9ac4c504.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53346 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251AbZH3Iwo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:44 -0400
In-Reply-To: <cbe86b98a6aceefe943ada1471eb52fd9ac4c504.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Implement the Recv ReqSeqAndFBit event when a RR frame with F bit set is
received.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index e5847c5..0a36c61 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3348,9 +3348,13 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 	case L2CAP_SUPER_RCV_READY:
 		if (rx_control & L2CAP_CTRL_POLL) {
 			u16 control = L2CAP_CTRL_FINAL;
-			control |= L2CAP_SUPER_RCV_READY;
+			control |= L2CAP_SUPER_RCV_READY |
+				(pi->buffer_seq << L2CAP_CTRL_REQSEQ_SHIFT);
 			l2cap_send_sframe(l2cap_pi(sk), control);
 		} else if (rx_control & L2CAP_CTRL_FINAL) {
+			pi->expected_ack_seq = tx_seq;
+			l2cap_drop_acked_frames(sk);
+
 			if (!(pi->conn_state & L2CAP_CONN_WAIT_F))
 				break;
 
-- 
1.6.2.5

