From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 2/5] Bluetooth: Fix memory leak in L2CAP
Date: Sat, 30 Jan 2010 06:08:45 -0800
Message-ID: <e420aba331f44de0eed6871441293a6124d566d1.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
 <fcafde2e6d81aa7901f9b10e6a097592f0637b79.1264859950.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:60247 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753063Ab0A3OJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 09:09:36 -0500
In-Reply-To: <fcafde2e6d81aa7901f9b10e6a097592f0637b79.1264859950.git.marcel@holtmann.org>
In-Reply-To: <cover.1264859950.git.marcel@holtmann.org>
References: <cover.1264859950.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>

Move skb_clone after error confition check so it is not going
potentially out of the scope.

Signed-off-by: Andrei Emeltchenko <andrei.emeltchenko@nokia.com>
Acked-by: Gustavo F. Padovan <padovan@profusion.mobi>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 net/bluetooth/l2cap.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/bluetooth/l2cap.c b/net/bluetooth/l2cap.c
index 8acc19e..400efa2 100644
--- a/net/bluetooth/l2cap.c
+++ b/net/bluetooth/l2cap.c
@@ -1368,7 +1368,6 @@ static int l2cap_ertm_send(struct sock *sk)
 
 	while ((skb = sk->sk_send_head) && (!l2cap_tx_window_full(sk)) &&
 	       !(pi->conn_state & L2CAP_CONN_REMOTE_BUSY)) {
-		tx_skb = skb_clone(skb, GFP_ATOMIC);
 
 		if (pi->remote_max_tx &&
 				bt_cb(skb)->retries == pi->remote_max_tx) {
@@ -1376,6 +1375,8 @@ static int l2cap_ertm_send(struct sock *sk)
 			break;
 		}
 
+		tx_skb = skb_clone(skb, GFP_ATOMIC);
+
 		bt_cb(skb)->retries++;
 
 		control = get_unaligned_le16(tx_skb->data + L2CAP_HDR_SIZE);
-- 
1.6.6

