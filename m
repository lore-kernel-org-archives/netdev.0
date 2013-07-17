From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] net/irda: fixed style issues in irttp
Date: Wed, 17 Jul 2013 12:25:38 +0100
Message-ID: <1374060338-5633-1-git-send-email-dragos.foianu@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dragos Foianu <dragos.foianu@gmail.com>
To: samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Applied error fixes suggested by checpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
---
 net/irda/irttp.c |   50 +++++++++++++++++++++++---------------------------
 1 file changed, 23 insertions(+), 27 deletions(-)

diff --git a/net/irda/irttp.c b/net/irda/irttp.c
index ae43c62..85372cf 100644
--- a/net/irda/irttp.c
+++ b/net/irda/irttp.c
@@ -75,7 +75,7 @@ static pi_minor_info_t pi_minor_call_table[] = {
 	{ NULL, 0 },                                             /* 0x00 */
 	{ irttp_param_max_sdu_size, PV_INTEGER | PV_BIG_ENDIAN } /* 0x01 */
 };
-static pi_major_info_t pi_major_call_table[] = {{ pi_minor_call_table, 2 }};
+static pi_major_info_t pi_major_call_table[] = { { pi_minor_call_table, 2 } };
 static pi_param_info_t param_info = { pi_major_call_table, 1, 0x0f, 4 };
 
 /************************ GLOBAL PROCEDURES ************************/
@@ -205,7 +205,7 @@ static void irttp_todo_expired(unsigned long data)
  */
 static void irttp_flush_queues(struct tsap_cb *self)
 {
-	struct sk_buff* skb;
+	struct sk_buff *skb;
 
 	IRDA_DEBUG(4, "%s()\n", __func__);
 
@@ -400,7 +400,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	/* The IrLMP spec (IrLMP 1.1 p10) says that we have the right to
 	 * use only 0x01-0x6F. Of course, we can use LSAP_ANY as well.
 	 * JeanII */
-	if((stsap_sel != LSAP_ANY) &&
+	if ((stsap_sel != LSAP_ANY) &&
 	   ((stsap_sel < 0x01) || (stsap_sel >= 0x70))) {
 		IRDA_DEBUG(0, "%s(), invalid tsap!\n", __func__);
 		return NULL;
@@ -427,7 +427,7 @@ struct tsap_cb *irttp_open_tsap(__u8 stsap_sel, int credit, notify_t *notify)
 	ttp_notify.data_indication = irttp_data_indication;
 	ttp_notify.udata_indication = irttp_udata_indication;
 	ttp_notify.flow_indication = irttp_flow_indication;
-	if(notify->status_indication != NULL)
+	if (notify->status_indication != NULL)
 		ttp_notify.status_indication = irttp_status_indication;
 	ttp_notify.instance = self;
 	strncpy(ttp_notify.name, notify->name, NOTIFY_MAX_NAME);
@@ -639,8 +639,7 @@ int irttp_data_request(struct tsap_cb *self, struct sk_buff *skb)
 	 */
 	if ((self->tx_max_sdu_size != 0) &&
 	    (self->tx_max_sdu_size != TTP_SAR_UNBOUND) &&
-	    (skb->len > self->tx_max_sdu_size))
-	{
+	    (skb->len > self->tx_max_sdu_size)) {
 		IRDA_ERROR("%s: SAR enabled, but data is larger than TxMaxSduSize!\n",
 			   __func__);
 		ret = -EMSGSIZE;
@@ -733,8 +732,7 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 	 * poll us through irttp_flow_indication() - Jean II */
 	while ((self->send_credit > 0) &&
 	       (!irlmp_lap_tx_queue_full(self->lsap)) &&
-	       (skb = skb_dequeue(&self->tx_queue)))
-	{
+	       (skb = skb_dequeue(&self->tx_queue))) {
 		/*
 		 *  Since we can transmit and receive frames concurrently,
 		 *  the code below is a critical region and we must assure that
@@ -798,8 +796,7 @@ static void irttp_run_tx_queue(struct tsap_cb *self)
 	 * where we can spend a bit of time doing stuff. - Jean II */
 	if ((self->tx_sdu_busy) &&
 	    (skb_queue_len(&self->tx_queue) < TTP_TX_LOW_THRESHOLD) &&
-	    (!self->close_pend))
-	{
+	    (!self->close_pend)) {
 		if (self->notify.flow_indication)
 			self->notify.flow_indication(self->notify.instance,
 						     self, FLOW_START);
@@ -892,7 +889,7 @@ static int irttp_udata_indication(void *instance, void *sap,
 	/* Just pass data to layer above */
 	if (self->notify.udata_indication) {
 		err = self->notify.udata_indication(self->notify.instance,
-						    self,skb);
+						    self, skb);
 		/* Same comment as in irttp_do_data_indication() */
 		if (!err)
 			return 0;
@@ -1057,7 +1054,7 @@ static void irttp_flow_indication(void *instance, void *sap, LOCAL_FLOW flow)
 	 * to do that. Jean II */
 
 	/* If we need to send disconnect. try to do it now */
-	if(self->disconnect_pend)
+	if (self->disconnect_pend)
 		irttp_start_todo_timer(self, 0);
 }
 
@@ -1116,7 +1113,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	IRDA_ASSERT(self->magic == TTP_TSAP_MAGIC, return -EBADR;);
 
 	if (self->connected) {
-		if(userdata)
+		if (userdata)
 			dev_kfree_skb(userdata);
 		return -EISCONN;
 	}
@@ -1137,7 +1134,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 		 *  headers
 		 */
 		IRDA_ASSERT(skb_headroom(userdata) >= TTP_MAX_HEADER,
-			{ dev_kfree_skb(userdata); return -1; } );
+			{ dev_kfree_skb(userdata); return -1; });
 	}
 
 	/* Initialize connection parameters */
@@ -1157,7 +1154,7 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	 *  Give away max 127 credits for now
 	 */
 	if (n > 127) {
-		self->avail_credit=n-127;
+		self->avail_credit = n - 127;
 		n = 127;
 	}
 
@@ -1166,10 +1163,10 @@ int irttp_connect_request(struct tsap_cb *self, __u8 dtsap_sel,
 	/* SAR enabled? */
 	if (max_sdu_size > 0) {
 		IRDA_ASSERT(skb_headroom(tx_skb) >= (TTP_MAX_HEADER + TTP_SAR_HEADER),
-			{ dev_kfree_skb(tx_skb); return -1; } );
+			{ dev_kfree_skb(tx_skb); return -1; });
 
 		/* Insert SAR parameters */
-		frame = skb_push(tx_skb, TTP_HEADER+TTP_SAR_HEADER);
+		frame = skb_push(tx_skb, TTP_HEADER + TTP_SAR_HEADER);
 
 		frame[0] = TTP_PARAMETERS | n;
 		frame[1] = 0x04; /* Length */
@@ -1386,7 +1383,7 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 		 *  headers
 		 */
 		IRDA_ASSERT(skb_headroom(userdata) >= TTP_MAX_HEADER,
-			{ dev_kfree_skb(userdata); return -1; } );
+			{ dev_kfree_skb(userdata); return -1; });
 	}
 
 	self->avail_credit = 0;
@@ -1409,10 +1406,10 @@ int irttp_connect_response(struct tsap_cb *self, __u32 max_sdu_size,
 	/* SAR enabled? */
 	if (max_sdu_size > 0) {
 		IRDA_ASSERT(skb_headroom(tx_skb) >= (TTP_MAX_HEADER + TTP_SAR_HEADER),
-			{ dev_kfree_skb(tx_skb); return -1; } );
+			{ dev_kfree_skb(tx_skb); return -1; });
 
 		/* Insert TTP header with SAR parameters */
-		frame = skb_push(tx_skb, TTP_HEADER+TTP_SAR_HEADER);
+		frame = skb_push(tx_skb, TTP_HEADER + TTP_SAR_HEADER);
 
 		frame[0] = TTP_PARAMETERS | n;
 		frame[1] = 0x04; /* Length */
@@ -1522,7 +1519,7 @@ int irttp_disconnect_request(struct tsap_cb *self, struct sk_buff *userdata,
 	 * function may be called from various context, like user, timer
 	 * for following a disconnect_indication() (i.e. net_bh).
 	 * Jean II */
-	if(test_and_set_bit(0, &self->disconnect_pend)) {
+	if (test_and_set_bit(0, &self->disconnect_pend)) {
 		IRDA_DEBUG(0, "%s(), disconnect already pending\n",
 			   __func__);
 		if (userdata)
@@ -1627,7 +1624,7 @@ static void irttp_disconnect_indication(void *instance, void *sap,
 	 * Jean II */
 
 	/* No need to notify the client if has already tried to disconnect */
-	if(self->notify.disconnect_indication)
+	if (self->notify.disconnect_indication)
 		self->notify.disconnect_indication(self->notify.instance, self,
 						   reason, skb);
 	else
@@ -1738,8 +1735,7 @@ static void irttp_run_rx_queue(struct tsap_cb *self)
 		 *  This is the last fragment, so time to reassemble!
 		 */
 		if ((self->rx_sdu_size <= self->rx_max_sdu_size) ||
-		    (self->rx_max_sdu_size == TTP_SAR_UNBOUND))
-		{
+		    (self->rx_max_sdu_size == TTP_SAR_UNBOUND)) {
 			/*
 			 * A little optimizing. Only queue the fragment if
 			 * there are other fragments. Since if this is the
@@ -1860,7 +1856,7 @@ static int irttp_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "dtsap_sel: %02x\n",
 		   self->dtsap_sel);
 	seq_printf(seq, "  connected: %s, ",
-		   self->connected? "TRUE":"FALSE");
+		   self->connected ? "TRUE" : "FALSE");
 	seq_printf(seq, "avail credit: %d, ",
 		   self->avail_credit);
 	seq_printf(seq, "remote credit: %d, ",
@@ -1876,9 +1872,9 @@ static int irttp_seq_show(struct seq_file *seq, void *v)
 	seq_printf(seq, "rx_queue len: %u\n",
 		   skb_queue_len(&self->rx_queue));
 	seq_printf(seq, "  tx_sdu_busy: %s, ",
-		   self->tx_sdu_busy? "TRUE":"FALSE");
+		   self->tx_sdu_busy ? "TRUE" : "FALSE");
 	seq_printf(seq, "rx_sdu_busy: %s\n",
-		   self->rx_sdu_busy? "TRUE":"FALSE");
+		   self->rx_sdu_busy ? "TRUE" : "FALSE");
 	seq_printf(seq, "  max_seg_size: %u, ",
 		   self->max_seg_size);
 	seq_printf(seq, "tx_max_sdu_size: %u, ",
-- 
1.7.10.4
