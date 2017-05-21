From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 3/5] atm: Adjust 19 checks for null pointers
Date: Sun, 21 May 2017 22:16:21 +0200
Message-ID: <1d76ff36-b20c-6bd7-dc34-00a2a976e8aa@users.sourceforge.net>
References: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org,
        Augusto Mecking Caringi <augustocaringi@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jarod Wilson <jarod@redhat.com>,
        Javier Martinez Canillas <javier@osg.samsung.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <49543220-93e4-781c-877b-381277837152@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Sun, 21 May 2017 21:34:23 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

The script “checkpatch.pl” pointed information out like the following.

Comparison to NULL could be written …

Thus fix the affected source code places.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/atm/lec.c | 38 +++++++++++++++++++-------------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/atm/lec.c b/net/atm/lec.c
index a11dbd3a5119..ca3aec0c0743 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -139,7 +139,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		struct atmlec_msg *mesg;
 
 		skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-		if (skb2 == NULL)
+		if (!skb2)
 			return;
 		skb2->len = sizeof(struct atmlec_msg);
 		mesg = (struct atmlec_msg *)skb2->data;
@@ -264,7 +264,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 					       min_frame_size - skb->truesize,
 					       GFP_ATOMIC);
 			dev_kfree_skb(skb);
-			if (skb2 == NULL) {
+			if (!skb2) {
 				dev->stats.tx_dropped++;
 				return NETDEV_TX_OK;
 			}
@@ -431,7 +431,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 		pr_debug("%s: bridge zeppelin asks about %pM\n",
 			 dev->name, mesg->content.proxy.mac_addr);
 
-		if (br_fdb_test_addr_hook == NULL)
+		if (!br_fdb_test_addr_hook)
 			break;
 
 		if (br_fdb_test_addr_hook(dev, mesg->content.proxy.mac_addr)) {
@@ -442,7 +442,7 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			pr_debug("%s: entry found, responding to zeppelin\n",
 				 dev->name);
 			skb2 = alloc_skb(sizeof(struct atmlec_msg), GFP_ATOMIC);
-			if (skb2 == NULL)
+			if (!skb2)
 				break;
 			skb2->len = sizeof(struct atmlec_msg);
 			skb_copy_to_linear_data(skb2, mesg, sizeof(*mesg));
@@ -520,7 +520,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	mesg = (struct atmlec_msg *)skb->data;
 	memset(mesg, 0, sizeof(*mesg));
 	mesg->type = type;
-	if (data != NULL)
+	if (data)
 		mesg->sizeoftlvs = data->len;
 	if (mac_addr)
 		ether_addr_copy(mesg->content.normal.mac_addr, mac_addr);
@@ -534,7 +534,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	skb_queue_tail(&sk->sk_receive_queue, skb);
 	sk->sk_data_ready(sk);
 
-	if (data != NULL) {
+	if (data) {
 		pr_debug("about to send %d bytes of data\n", data->len);
 		atm_force_charge(priv->lecd, data->truesize);
 		skb_queue_tail(&sk->sk_receive_queue, data);
@@ -663,7 +663,7 @@ static void lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct lec_vcc_priv *vpriv = LEC_VCC_PRIV(vcc);
 	struct net_device *dev = skb->dev;
 
-	if (vpriv == NULL) {
+	if (!vpriv) {
 		pr_info("vpriv = NULL!?!?!?\n");
 		return;
 	}
@@ -1066,7 +1066,7 @@ static void __exit lane_module_cleanup(void)
 	deregister_atm_ioctl(&lane_ioctl_ops);
 
 	for (i = 0; i < MAX_LEC_ITF; i++) {
-		if (dev_lec[i] != NULL) {
+		if (dev_lec[i]) {
 			unregister_netdev(dev_lec[i]);
 			free_netdev(dev_lec[i]);
 			dev_lec[i] = NULL;
@@ -1097,11 +1097,11 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 		spin_lock_irqsave(&priv->lec_arp_lock, flags);
 		table = lec_arp_find(priv, dst_mac);
 		spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
-		if (table == NULL)
+		if (!table)
 			return -1;
 
 		*tlvs = kmemdup(table->tlvs, table->sizeoftlvs, GFP_ATOMIC);
-		if (*tlvs == NULL)
+		if (!*tlvs)
 			return -1;
 
 		*sizeoftlvs = table->sizeoftlvs;
@@ -1109,12 +1109,12 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 		return 0;
 	}
 
-	if (sizeoftlvs == NULL)
+	if (!sizeoftlvs)
 		retval = send_to_lecd(priv, l_arp_xmt, dst_mac, NULL, NULL);
 
 	else {
 		skb = alloc_skb(*sizeoftlvs, GFP_ATOMIC);
-		if (skb == NULL)
+		if (!skb)
 			return -1;
 		skb->len = *sizeoftlvs;
 		skb_copy_to_linear_data(skb, *tlvs, *sizeoftlvs);
@@ -1143,12 +1143,12 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 	kfree(priv->tlvs);	/* NULL if there was no previous association */
 
 	priv->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
-	if (priv->tlvs == NULL)
+	if (!priv->tlvs)
 		return 0;
 	priv->sizeoftlvs = sizeoftlvs;
 
 	skb = alloc_skb(sizeoftlvs, GFP_ATOMIC);
-	if (skb == NULL)
+	if (!skb)
 		return 0;
 	skb->len = sizeoftlvs;
 	skb_copy_to_linear_data(skb, tlvs, sizeoftlvs);
@@ -1181,13 +1181,13 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 				 */
 	struct lec_arp_table *entry = lec_arp_find(priv, mac_addr);
 
-	if (entry == NULL)
+	if (!entry)
 		return;		/* should not happen */
 
 	kfree(entry->tlvs);
 
 	entry->tlvs = kmemdup(tlvs, sizeoftlvs, GFP_KERNEL);
-	if (entry->tlvs == NULL)
+	if (!entry->tlvs)
 		return;
 	entry->sizeoftlvs = sizeoftlvs;
 #endif
@@ -1854,7 +1854,7 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	entry = lec_arp_find(priv, mac_addr);
-	if (entry == NULL && targetless_le_arp)
+	if (!entry && targetless_le_arp)
 		goto out;	/*
 				 * LANE2: ignore targetless LE_ARPs for which
 				 * we have no entry in the cache. 7.1.30
@@ -1965,7 +1965,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		entry->old_recv_push = old_push;
 #endif
 		entry = make_entry(priv, bus_mac);
-		if (entry == NULL)
+		if (!entry)
 			goto out;
 		del_timer(&entry->timer);
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
@@ -1990,7 +1990,7 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 			 ioc_data->atm_addr[16], ioc_data->atm_addr[17],
 			 ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 		entry = make_entry(priv, bus_mac);
-		if (entry == NULL)
+		if (!entry)
 			goto out;
 		memcpy(entry->atm_addr, ioc_data->atm_addr, ATM_ESA_LEN);
 		eth_zero_addr(entry->mac_addr);
-- 
2.13.0
