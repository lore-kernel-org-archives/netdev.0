From: Jianjun Kong <jianjun@zeuux.org>
Subject: [PATCH] net: replace netdev->priv with netdev_priv()
Date: Mon, 8 Dec 2008 23:23:26 +0800
Message-ID: <20081208152326.GB22436@ubuntu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.zeuux.org ([210.51.160.52]:55912 "EHLO z.billxu.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572AbYLHPXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 10:23:31 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


net: replace netdev->priv with netdev_priv()

Signed-off-by: Jianjun Kong <jianjun@zeuux.org>
---
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 net/atm/lec.c                        |   20 ++++++++++----------
 2 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 6ef3f0d..cc91dad 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -988,7 +988,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
  */
 static int netxen_nic_open(struct net_device *netdev)
 {
-	struct netxen_adapter *adapter = (struct netxen_adapter *)netdev->priv;
+	struct netxen_adapter *adapter = netdev_priv(netdev);
 	int err = 0;
 	int ctx, ring;
 	irq_handler_t handler;
diff --git a/net/atm/lec.c b/net/atm/lec.c
index 8f701cd..df4f6c6 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -152,7 +152,7 @@ static void lec_handle_bridge(struct sk_buff *skb, struct net_device *dev)
 		buff += 4;
 		mesg->content.normal.flag = *buff & 0x01;	/* 0x01 is topology change */
 
-		priv = (struct lec_priv *)dev->priv;
+		priv = dev_priv(dev);
 		atm_force_charge(priv->lecd, skb2->truesize);
 		sk = sk_atm(priv->lecd);
 		skb_queue_tail(&sk->sk_receive_queue, skb2);
@@ -218,7 +218,7 @@ static unsigned char *get_tr_dst(unsigned char *packet, unsigned char *rdesc)
 
 static int lec_open(struct net_device *dev)
 {
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 
 	netif_start_queue(dev);
 	memset(&priv->stats, 0, sizeof(struct net_device_stats));
@@ -252,7 +252,7 @@ static void lec_tx_timeout(struct net_device *dev)
 static int lec_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct sk_buff *skb2;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 	struct lecdatahdr_8023 *lec_h;
 	struct atm_vcc *vcc;
 	struct lec_arp_table *entry;
@@ -442,14 +442,14 @@ static int lec_close(struct net_device *dev)
  */
 static struct net_device_stats *lec_get_stats(struct net_device *dev)
 {
-	return &((struct lec_priv *)dev->priv)->stats;
+	return &(dev_priv(dev))->stats;
 }
 
 static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 	struct atmlec_msg *mesg;
 	struct lec_arp_table *entry;
 	int i;
@@ -596,7 +596,7 @@ static void lec_atm_close(struct atm_vcc *vcc)
 {
 	struct sk_buff *skb;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 
 	priv->lecd = NULL;
 	/* Do something needful? */
@@ -727,7 +727,7 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	unsigned long flags;
 	struct net_device *dev = (struct net_device *)vcc->proto_data;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 
 #if DUMP_PACKETS >0
 	int i = 0;
@@ -1279,7 +1279,7 @@ static int lane2_resolve(struct net_device *dev, const u8 *dst_mac, int force,
 			 u8 **tlvs, u32 *sizeoftlvs)
 {
 	unsigned long flags;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 	struct lec_arp_table *table;
 	struct sk_buff *skb;
 	int retval;
@@ -1326,7 +1326,7 @@ static int lane2_associate_req(struct net_device *dev, const u8 *lan_dst,
 {
 	int retval;
 	struct sk_buff *skb;
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 
 	if (compare_ether_addr(lan_dst, dev->dev_addr))
 		return (0);	/* not our mac address */
@@ -1363,7 +1363,7 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 #if 0
 	int i = 0;
 #endif
-	struct lec_priv *priv = (struct lec_priv *)dev->priv;
+	struct lec_priv *priv = dev_priv(dev);
 #if 0				/*
 				 * Why have the TLVs in LE_ARP entries
 				 * since we do not use them? When you
-- 
1.5.6.3

-- 
Jianjun Kong |Happy Hacking
Homepage: http://kongove.cn
Gtalk:kongjianjun@gmail.com
