From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 3/5] Bluetooth: Ack L2CAP I-frames before retransmit missing packet
Date: Thu, 17 Dec 2009 12:22:45 -0800
Message-ID: <186ee8cf0130993dea8ab8867ff1af8a148f9ae6.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
 <971beb83aeb2a309175682cf5683d64fd4591841.1261080894.git.marcel@holtmann.org>
 <186de9a33803c7ee20d9af75c9049b50e68a3a08.1261080894.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33954 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765314AbZLQUXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Dec 2009 15:23:21 -0500
In-Reply-To: <186de9a33803c7ee20d9af75c9049b50e68a3a08.1261080894.git.marcel@holtmann.org>
In-Reply-To: <cover.1261080894.git.marcel@holtmann.org>
References: <cover.1261080894.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>

Moving the Ack to before l2cap_retransmit_frame() we can avoid the
case where txWindow is full and the packet can't be retransmited.

Signed-off-by: Gustavo F. Padovan <gustavo@las.ic.unicamp.br>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 7db9a1f..fb0f81d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3471,9 +3471,9 @@ static inline int l2cap_data_channel_sframe(struct sock *sk, u16 rx_control, str
 		pi->conn_state &= ~L2CAP_CONN_REMOTE_BUSY;
 
 		if (rx_control & L2CAP_CTRL_POLL) {
-			l2cap_retransmit_frame(sk, tx_seq);
 			pi->expected_ack_seq = tx_seq;
 			l2cap_drop_acked_frames(sk);
+			l2cap_retransmit_frame(sk, tx_seq);
 			l2cap_ertm_send(sk);
 			if (pi->conn_state & L2CAP_CONN_WAIT_F) {
 				pi->srej_save_reqseq = tx_seq;
-- 
1.6.5.2

