From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 1/5] Bluetooth: Remove double free of SKB pointer in L2CAP
Date: Sat, 30 Jan 2010 06:08:44 -0800
Message-ID: <fcafde2e6d81aa7901f9b10e6a097592f0637b79.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60244 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753101Ab0A3OJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 09:09:35 -0500
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>

Trivial fix for double free of SKB pointer with kfree_skb to
make code simplier and cleaner. Remove unused variable err.

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 1120cf1..8acc19e 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -3518,7 +3518,6 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 	struct l2cap_pinfo *pi;
 	u16 control, len;
 	u8 tx_seq;
-	int err;
 
 	sk = l2cap_get_chan_by_scid(&conn->chan_list, cid);
 	if (!sk) {
@@ -3570,13 +3569,11 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 			goto drop;
 
 		if (__is_iframe(control))
-			err = l2cap_data_channel_iframe(sk, control, skb);
+			l2cap_data_channel_iframe(sk, control, skb);
 		else
-			err = l2cap_data_channel_sframe(sk, control, skb);
+			l2cap_data_channel_sframe(sk, control, skb);
 
-		if (!err)
-			goto done;
-		break;
+		goto done;
 
 	case L2CAP_MODE_STREAMING:
 		control = get_unaligned_le16(skb->data);
@@ -3602,7 +3599,7 @@ static inline int l2cap_data_channel(struct l2cap_conn *conn, u16 cid, struct sk
 		else
 			pi->expected_tx_seq = tx_seq + 1;
 
-		err = l2cap_sar_reassembly_sdu(sk, skb, control);
+		l2cap_sar_reassembly_sdu(sk, skb, control);
 
 		goto done;
 
-- 
1.6.6

