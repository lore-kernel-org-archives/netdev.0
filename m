From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 03/13] Bluetooth: Fix drop of packets with invalid req_seq/tx_seq
Date: Thu,  8 Jul 2010 16:59:52 -0300
Message-ID: <5750ca99a700d2e67c3ba5e99522093d9de36162.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36215 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758543Ab0GHUAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 16:00:31 -0400
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
In-Reply-To: <cover.1278619047.git.marcel@holtmann.org>
References: <cover.1278619047.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gustavo F. Padovan <padovan@profusion.mobi>

We shall not use an unsigned var since we are expecting negatives value
there. Using unsigned causes ERTM connection to close due to invalid
ReqSeq numbers.

Signed-off-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index e036419..b08731d 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3789,7 +3789,7 @@ static inline int l2cap_data_channel_iframe(struct sock *sk, u16 rx_control, str
 	u8 tx_seq = __get_txseq(rx_control);
 	u8 req_seq = __get_reqseq(rx_control);
 	u8 sar = rx_control >> L2CAP_CTRL_SAR_SHIFT;
-	u8 tx_seq_offset, expected_tx_seq_offset;
+	int tx_seq_offset, expected_tx_seq_offset;
 	int num_to_ack = (pi->tx_win/6) + 1;
 	int err = 0;
 
@@ -4074,7 +4074,8 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 	struct sock *sk;
 	struct l2cap_pinfo *pi;
 	u16 control, len;
-	u8 tx_seq, req_seq, next_tx_seq_offset, req_seq_offset;
+	u8 tx_seq, req_seq;
+	int next_tx_seq_offset, req_seq_offset;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
 	if (!sk) {
-- 
1.7.1.1

