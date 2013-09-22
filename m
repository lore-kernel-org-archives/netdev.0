From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 2/5] Bluetooth: Fix assignment of 0/1 to bool variables
Date: Sun, 22 Sep 2013 20:44:10 +0200
Message-ID: <1379875453-20083-2-git-send-email-peter.senna@gmail.com>
References: <1379875453-20083-1-git-send-email-peter.senna@gmail.com>
Cc: gustavo@padovan.org, johan.hedberg@gmail.com, davem@davemloft.net,
	linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org,
	Peter Senna Tschudin <peter.senna@gmail.com>
To: marcel@holtmann.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <1379875453-20083-1-git-send-email-peter.senna@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert 0 to false and 1 to true when assigning values to bool
variables. Inspired by commit 3db1cd5c05f35fb43eb134df6f321de4e63141f2.

The simplified semantic patch that find this problem is as
follows (http://coccinelle.lip6.fr/):

@@
bool b;
@@
(
-b = 0
+b = false
|
-b = 1
+b = true
)

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 net/bluetooth/l2cap_core.c |   16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff -u -p a/net/bluetooth/l2cap_core.c b/net/bluetooth/l2cap_core.c
--- a/net/bluetooth/l2cap_core.c
+++ b/net/bluetooth/l2cap_core.c
@@ -5797,7 +5797,7 @@ static int l2cap_rx_state_recv(struct l2
 			       struct sk_buff *skb, u8 event)
 {
 	int err = 0;
-	bool skb_in_use = 0;
+	bool skb_in_use = false;
 
 	BT_DBG("chan %p, control %p, skb %p, event %d", chan, control, skb,
 	       event);
@@ -5818,7 +5818,7 @@ static int l2cap_rx_state_recv(struct l2
 							   control->txseq);
 
 			chan->buffer_seq = chan->expected_tx_seq;
-			skb_in_use = 1;
+			skb_in_use = true;
 
 			err = l2cap_reassemble_sdu(chan, skb, control);
 			if (err)
@@ -5854,7 +5854,7 @@ static int l2cap_rx_state_recv(struct l2
 			 * current frame is stored for later use.
 			 */
 			skb_queue_tail(&chan->srej_q, skb);
-			skb_in_use = 1;
+			skb_in_use = true;
 			BT_DBG("Queued %p (queue len %d)", skb,
 			       skb_queue_len(&chan->srej_q));
 
@@ -5932,7 +5932,7 @@ static int l2cap_rx_state_srej_sent(stru
 {
 	int err = 0;
 	u16 txseq = control->txseq;
-	bool skb_in_use = 0;
+	bool skb_in_use = false;
 
 	BT_DBG("chan %p, control %p, skb %p, event %d", chan, control, skb,
 	       event);
@@ -5944,7 +5944,7 @@ static int l2cap_rx_state_srej_sent(stru
 			/* Keep frame for reassembly later */
 			l2cap_pass_to_tx(chan, control);
 			skb_queue_tail(&chan->srej_q, skb);
-			skb_in_use = 1;
+			skb_in_use = true;
 			BT_DBG("Queued %p (queue len %d)", skb,
 			       skb_queue_len(&chan->srej_q));
 
@@ -5955,7 +5955,7 @@ static int l2cap_rx_state_srej_sent(stru
 
 			l2cap_pass_to_tx(chan, control);
 			skb_queue_tail(&chan->srej_q, skb);
-			skb_in_use = 1;
+			skb_in_use = true;
 			BT_DBG("Queued %p (queue len %d)", skb,
 			       skb_queue_len(&chan->srej_q));
 
@@ -5970,7 +5970,7 @@ static int l2cap_rx_state_srej_sent(stru
 			 * the missing frames.
 			 */
 			skb_queue_tail(&chan->srej_q, skb);
-			skb_in_use = 1;
+			skb_in_use = true;
 			BT_DBG("Queued %p (queue len %d)", skb,
 			       skb_queue_len(&chan->srej_q));
 
@@ -5984,7 +5984,7 @@ static int l2cap_rx_state_srej_sent(stru
 			 * SREJ'd frames.
 			 */
 			skb_queue_tail(&chan->srej_q, skb);
-			skb_in_use = 1;
+			skb_in_use = true;
 			BT_DBG("Queued %p (queue len %d)", skb,
 			       skb_queue_len(&chan->srej_q));
 

