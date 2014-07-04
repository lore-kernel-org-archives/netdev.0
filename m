From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 01/10] net/hsr: Better variable names and update
 of contact info.
Date: Fri, 4 Jul 2014 23:34:38 +0200
Message-ID: <53B71DEE.3070005@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:50146 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757326AbaGDVkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:40:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c   | 207 ++++++++++++++++++++++++-----------------=
--------
 net/hsr/hsr_device.h   |   6 +-
 net/hsr/hsr_framereg.c | 108 +++++++++++++-------------
 net/hsr/hsr_framereg.h |  36 ++++-----
 net/hsr/hsr_main.c     | 170 ++++++++++++++++++++--------------------
 net/hsr/hsr_main.h     |  20 ++---
 net/hsr/hsr_netlink.c  |  54 ++++++-------
 net/hsr/hsr_netlink.h  |   8 +-
 8 files changed, 304 insertions(+), 305 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index e5302b7..4dc2a42 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  *
  * This file contains device methods for creating, using and destroyin=
g
  * virtual HSR devices.
@@ -71,49 +71,49 @@ void hsr_set_carrier(struct net_device *hsr_dev, st=
ruct net_device *slave1,
=20
 void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr =3D netdev_priv(hsr_dev);
=20
 	if ((hsr_dev->operstate =3D=3D IF_OPER_UP) && (old_operstate !=3D IF_=
OPER_UP)) {
 		/* Went up */
-		hsr_priv->announce_count =3D 0;
-		hsr_priv->announce_timer.expires =3D jiffies +
+		hsr->announce_count =3D 0;
+		hsr->announce_timer.expires =3D jiffies +
 				msecs_to_jiffies(HSR_ANNOUNCE_INTERVAL);
-		add_timer(&hsr_priv->announce_timer);
+		add_timer(&hsr->announce_timer);
 	}
=20
 	if ((hsr_dev->operstate !=3D IF_OPER_UP) && (old_operstate =3D=3D IF_=
OPER_UP))
 		/* Went down */
-		del_timer(&hsr_priv->announce_timer);
+		del_timer(&hsr->announce_timer);
 }
=20
=20
-int hsr_get_max_mtu(struct hsr_priv *hsr_priv)
+int hsr_get_max_mtu(struct hsr_priv *hsr)
 {
 	int mtu_max;
=20
-	if (hsr_priv->slave[0] && hsr_priv->slave[1])
-		mtu_max =3D min(hsr_priv->slave[0]->mtu, hsr_priv->slave[1]->mtu);
-	else if (hsr_priv->slave[0])
-		mtu_max =3D hsr_priv->slave[0]->mtu;
-	else if (hsr_priv->slave[1])
-		mtu_max =3D hsr_priv->slave[1]->mtu;
+	if (hsr->slave[0] && hsr->slave[1])
+		mtu_max =3D min(hsr->slave[0]->mtu, hsr->slave[1]->mtu);
+	else if (hsr->slave[0])
+		mtu_max =3D hsr->slave[0]->mtu;
+	else if (hsr->slave[1])
+		mtu_max =3D hsr->slave[1]->mtu;
 	else
-		mtu_max =3D HSR_TAGLEN;
+		mtu_max =3D HSR_HLEN;
=20
-	return mtu_max - HSR_TAGLEN;
+	return mtu_max - HSR_HLEN;
 }
=20
 static int hsr_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D netdev_priv(dev);
+	hsr =3D netdev_priv(dev);
=20
-	if (new_mtu > hsr_get_max_mtu(hsr_priv)) {
-		netdev_info(hsr_priv->dev, "A HSR master's MTU cannot be greater tha=
n the smallest MTU of its slaves minus the HSR Tag length (%d octets).\=
n",
-			    HSR_TAGLEN);
+	if (new_mtu > hsr_get_max_mtu(hsr)) {
+		netdev_info(hsr->dev, "A HSR master's MTU cannot be greater than the=
 smallest MTU of its slaves minus the HSR Tag length (%d octets).\n",
+			    HSR_HLEN);
 		return -EINVAL;
 	}
=20
@@ -124,19 +124,19 @@ static int hsr_dev_change_mtu(struct net_device *=
dev, int new_mtu)
=20
 static int hsr_dev_open(struct net_device *dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	int i;
 	char *slave_name;
=20
-	hsr_priv =3D netdev_priv(dev);
+	hsr =3D netdev_priv(dev);
=20
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (hsr_priv->slave[i])
-			slave_name =3D hsr_priv->slave[i]->name;
+		if (hsr->slave[i])
+			slave_name =3D hsr->slave[i]->name;
 		else
 			slave_name =3D "null";
=20
-		if (!is_slave_up(hsr_priv->slave[i]))
+		if (!is_slave_up(hsr->slave[i]))
 			netdev_warn(dev, "Slave %c (%s) is not up; please bring it up to ge=
t a working HSR network\n",
 				    'A' + i, slave_name);
 	}
@@ -156,7 +156,7 @@ static int hsr_dev_close(struct net_device *dev)
 }
=20
=20
-static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_pri=
v *hsr_priv)
+static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_pri=
v *hsr)
 {
 	unsigned long irqflags;
=20
@@ -185,26 +185,26 @@ static void hsr_fill_tag(struct hsr_ethhdr *hsr_e=
thhdr, struct hsr_priv *hsr_pri
 	 */
 	set_hsr_tag_LSDU_size(&hsr_ethhdr->hsr_tag, 0);
=20
-	spin_lock_irqsave(&hsr_priv->seqnr_lock, irqflags);
-	hsr_ethhdr->hsr_tag.sequence_nr =3D htons(hsr_priv->sequence_nr);
-	hsr_priv->sequence_nr++;
-	spin_unlock_irqrestore(&hsr_priv->seqnr_lock, irqflags);
+	spin_lock_irqsave(&hsr->seqnr_lock, irqflags);
+	hsr_ethhdr->hsr_tag.sequence_nr =3D htons(hsr->sequence_nr);
+	hsr->sequence_nr++;
+	spin_unlock_irqrestore(&hsr->seqnr_lock, irqflags);
=20
 	hsr_ethhdr->hsr_tag.encap_proto =3D hsr_ethhdr->ethhdr.h_proto;
=20
 	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_PRP);
 }
=20
-static int slave_xmit(struct sk_buff *skb, struct hsr_priv *hsr_priv,
+static int slave_xmit(struct sk_buff *skb, struct hsr_priv *hsr,
 		      enum hsr_dev_idx dev_idx)
 {
 	struct hsr_ethhdr *hsr_ethhdr;
=20
 	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
=20
-	skb->dev =3D hsr_priv->slave[dev_idx];
+	skb->dev =3D hsr->slave[dev_idx];
=20
-	hsr_addr_subst_dest(hsr_priv, &hsr_ethhdr->ethhdr, dev_idx);
+	hsr_addr_subst_dest(hsr, &hsr_ethhdr->ethhdr, dev_idx);
=20
 	/* Address substitution (IEC62439-3 pp 26, 50): replace mac
 	 * address of outgoing frame with that of the outgoing slave's.
@@ -217,36 +217,36 @@ static int slave_xmit(struct sk_buff *skb, struct=
 hsr_priv *hsr_priv,
=20
 static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	struct hsr_ethhdr *hsr_ethhdr;
 	struct sk_buff *skb2;
 	int res1, res2;
=20
-	hsr_priv =3D netdev_priv(dev);
+	hsr =3D netdev_priv(dev);
 	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
=20
 	if ((skb->protocol !=3D htons(ETH_P_PRP)) ||
 	    (hsr_ethhdr->ethhdr.h_proto !=3D htons(ETH_P_PRP))) {
-		hsr_fill_tag(hsr_ethhdr, hsr_priv);
+		hsr_fill_tag(hsr_ethhdr, hsr);
 		skb->protocol =3D htons(ETH_P_PRP);
 	}
=20
 	skb2 =3D pskb_copy(skb, GFP_ATOMIC);
=20
 	res1 =3D NET_XMIT_DROP;
-	if (likely(hsr_priv->slave[HSR_DEV_SLAVE_A]))
-		res1 =3D slave_xmit(skb, hsr_priv, HSR_DEV_SLAVE_A);
+	if (likely(hsr->slave[HSR_DEV_SLAVE_A]))
+		res1 =3D slave_xmit(skb, hsr, HSR_DEV_SLAVE_A);
=20
 	res2 =3D NET_XMIT_DROP;
-	if (likely(skb2 && hsr_priv->slave[HSR_DEV_SLAVE_B]))
-		res2 =3D slave_xmit(skb2, hsr_priv, HSR_DEV_SLAVE_B);
+	if (likely(skb2 && hsr->slave[HSR_DEV_SLAVE_B]))
+		res2 =3D slave_xmit(skb2, hsr, HSR_DEV_SLAVE_B);
=20
 	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
 		   res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
-		hsr_priv->dev->stats.tx_packets++;
-		hsr_priv->dev->stats.tx_bytes +=3D skb->len;
+		hsr->dev->stats.tx_packets++;
+		hsr->dev->stats.tx_bytes +=3D skb->len;
 	} else {
-		hsr_priv->dev->stats.tx_dropped++;
+		hsr->dev->stats.tx_dropped++;
 	}
=20
 	return NETDEV_TX_OK;
@@ -262,21 +262,21 @@ static int hsr_header_create(struct sk_buff *skb,=
 struct net_device *dev,
 	/* Make room for the HSR tag now. We will fill it in later (in
 	 * hsr_dev_xmit)
 	 */
-	if (skb_headroom(skb) < HSR_TAGLEN + ETH_HLEN)
+	if (skb_headroom(skb) < HSR_HLEN + ETH_HLEN)
 		return -ENOBUFS;
-	skb_push(skb, HSR_TAGLEN);
+	skb_push(skb, HSR_HLEN);
=20
 	/* To allow VLAN/HSR combos we should probably use
-	 * res =3D dev_hard_header(skb, dev, type, daddr, saddr, len + HSR_TA=
GLEN);
+	 * res =3D dev_hard_header(skb, dev, type, daddr, saddr, len + HSR_HL=
EN);
 	 * here instead. It would require other changes too, though - e.g.
 	 * separate headers for each slave etc...
 	 */
-	res =3D eth_header(skb, dev, type, daddr, saddr, len + HSR_TAGLEN);
+	res =3D eth_header(skb, dev, type, daddr, saddr, len + HSR_HLEN);
 	if (res <=3D 0)
 		return res;
 	skb_reset_mac_header(skb);
=20
-	return res + HSR_TAGLEN;
+	return res + HSR_HLEN;
 }
=20
=20
@@ -291,7 +291,7 @@ static const struct header_ops hsr_header_ops =3D {
  */
 static int hsr_pad(int size)
 {
-	const int min_size =3D ETH_ZLEN - HSR_TAGLEN - ETH_HLEN;
+	const int min_size =3D ETH_ZLEN - HSR_HLEN - ETH_HLEN;
=20
 	if (size >=3D min_size)
 		return size;
@@ -300,7 +300,7 @@ static int hsr_pad(int size)
=20
 static void send_hsr_supervision_frame(struct net_device *hsr_dev, u8 =
type)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	struct sk_buff *skb;
 	int hlen, tlen;
 	struct hsr_sup_tag *hsr_stag;
@@ -315,7 +315,7 @@ static void send_hsr_supervision_frame(struct net_d=
evice *hsr_dev, u8 type)
 	if (skb =3D=3D NULL)
 		return;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr =3D netdev_priv(hsr_dev);
=20
 	skb_reserve(skb, hlen);
=20
@@ -324,7 +324,7 @@ static void send_hsr_supervision_frame(struct net_d=
evice *hsr_dev, u8 type)
 	skb->priority =3D TC_PRIO_CONTROL;
=20
 	if (dev_hard_header(skb, skb->dev, ETH_P_PRP,
-			    hsr_priv->sup_multicast_addr,
+			    hsr->sup_multicast_addr,
 			    skb->dev->dev_addr, skb->len) < 0)
 		goto out;
=20
@@ -334,10 +334,10 @@ static void send_hsr_supervision_frame(struct net=
_device *hsr_dev, u8 type)
 	set_hsr_stag_path(hsr_stag, 0xf);
 	set_hsr_stag_HSR_Ver(hsr_stag, 0);
=20
-	spin_lock_irqsave(&hsr_priv->seqnr_lock, irqflags);
-	hsr_stag->sequence_nr =3D htons(hsr_priv->sequence_nr);
-	hsr_priv->sequence_nr++;
-	spin_unlock_irqrestore(&hsr_priv->seqnr_lock, irqflags);
+	spin_lock_irqsave(&hsr->seqnr_lock, irqflags);
+	hsr_stag->sequence_nr =3D htons(hsr->sequence_nr);
+	hsr->sequence_nr++;
+	spin_unlock_irqrestore(&hsr->seqnr_lock, irqflags);
=20
 	hsr_stag->HSR_TLV_Type =3D type;
 	hsr_stag->HSR_TLV_Length =3D 12;
@@ -360,48 +360,48 @@ out:
  */
 static void hsr_announce(unsigned long data)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D (struct hsr_priv *) data;
+	hsr =3D (struct hsr_priv *) data;
=20
-	if (hsr_priv->announce_count < 3) {
-		send_hsr_supervision_frame(hsr_priv->dev, HSR_TLV_ANNOUNCE);
-		hsr_priv->announce_count++;
+	if (hsr->announce_count < 3) {
+		send_hsr_supervision_frame(hsr->dev, HSR_TLV_ANNOUNCE);
+		hsr->announce_count++;
 	} else {
-		send_hsr_supervision_frame(hsr_priv->dev, HSR_TLV_LIFE_CHECK);
+		send_hsr_supervision_frame(hsr->dev, HSR_TLV_LIFE_CHECK);
 	}
=20
-	if (hsr_priv->announce_count < 3)
-		hsr_priv->announce_timer.expires =3D jiffies +
+	if (hsr->announce_count < 3)
+		hsr->announce_timer.expires =3D jiffies +
 				msecs_to_jiffies(HSR_ANNOUNCE_INTERVAL);
 	else
-		hsr_priv->announce_timer.expires =3D jiffies +
+		hsr->announce_timer.expires =3D jiffies +
 				msecs_to_jiffies(HSR_LIFE_CHECK_INTERVAL);
=20
-	if (is_admin_up(hsr_priv->dev))
-		add_timer(&hsr_priv->announce_timer);
+	if (is_admin_up(hsr->dev))
+		add_timer(&hsr->announce_timer);
 }
=20
=20
 static void restore_slaves(struct net_device *hsr_dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	int i;
 	int res;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr =3D netdev_priv(hsr_dev);
=20
 	rtnl_lock();
=20
 	/* Restore promiscuity */
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (!hsr_priv->slave[i])
+		if (!hsr->slave[i])
 			continue;
-		res =3D dev_set_promiscuity(hsr_priv->slave[i], -1);
+		res =3D dev_set_promiscuity(hsr->slave[i], -1);
 		if (res)
 			netdev_info(hsr_dev,
 				    "Cannot restore slave promiscuity (%s, %d)\n",
-				    hsr_priv->slave[i]->name, res);
+				    hsr->slave[i]->name, res);
 	}
=20
 	rtnl_unlock();
@@ -409,10 +409,10 @@ static void restore_slaves(struct net_device *hsr=
_dev)
=20
 static void reclaim_hsr_dev(struct rcu_head *rh)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D container_of(rh, struct hsr_priv, rcu_head);
-	free_netdev(hsr_priv->dev);
+	hsr =3D container_of(rh, struct hsr_priv, rcu_head);
+	free_netdev(hsr->dev);
 }
=20
=20
@@ -421,14 +421,14 @@ static void reclaim_hsr_dev(struct rcu_head *rh)
  */
 static void hsr_dev_destroy(struct net_device *hsr_dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr =3D netdev_priv(hsr_dev);
=20
-	del_timer(&hsr_priv->announce_timer);
-	unregister_hsr_master(hsr_priv);    /* calls list_del_rcu on hsr_priv=
 */
+	del_timer(&hsr->announce_timer);
+	unregister_hsr_master(hsr);    /* calls list_del_rcu on hsr */
 	restore_slaves(hsr_dev);
-	call_rcu(&hsr_priv->rcu_head, reclaim_hsr_dev);   /* reclaim hsr_priv=
 */
+	call_rcu(&hsr->rcu_head, reclaim_hsr_dev);   /* reclaim hsr */
 }
=20
 static const struct net_device_ops hsr_device_ops =3D {
@@ -500,27 +500,27 @@ static const unsigned char def_multicast_addr[ETH=
_ALEN] __aligned(2) =3D {
 int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2],
 		     unsigned char multicast_spec)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	int i;
 	int res;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
-	hsr_priv->dev =3D hsr_dev;
-	INIT_LIST_HEAD(&hsr_priv->node_db);
-	INIT_LIST_HEAD(&hsr_priv->self_node_db);
+	hsr =3D netdev_priv(hsr_dev);
+	hsr->dev =3D hsr_dev;
+	INIT_LIST_HEAD(&hsr->node_db);
+	INIT_LIST_HEAD(&hsr->self_node_db);
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
-		hsr_priv->slave[i] =3D slave[i];
+		hsr->slave[i] =3D slave[i];
=20
-	spin_lock_init(&hsr_priv->seqnr_lock);
+	spin_lock_init(&hsr->seqnr_lock);
 	/* Overflow soon to find bugs easier: */
-	hsr_priv->sequence_nr =3D USHRT_MAX - 1024;
+	hsr->sequence_nr =3D USHRT_MAX - 1024;
=20
-	init_timer(&hsr_priv->announce_timer);
-	hsr_priv->announce_timer.function =3D hsr_announce;
-	hsr_priv->announce_timer.data =3D (unsigned long) hsr_priv;
+	init_timer(&hsr->announce_timer);
+	hsr->announce_timer.function =3D hsr_announce;
+	hsr->announce_timer.data =3D (unsigned long) hsr;
=20
-	ether_addr_copy(hsr_priv->sup_multicast_addr, def_multicast_addr);
-	hsr_priv->sup_multicast_addr[ETH_ALEN - 1] =3D multicast_spec;
+	ether_addr_copy(hsr->sup_multicast_addr, def_multicast_addr);
+	hsr->sup_multicast_addr[ETH_ALEN - 1] =3D multicast_spec;
=20
 /* FIXME: should I modify the value of these?
  *
@@ -547,20 +547,20 @@ int hsr_dev_finalize(struct net_device *hsr_dev, =
struct net_device *slave[2],
 	hsr_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
=20
 	/* Set hsr_dev's MAC address to that of mac_slave1 */
-	ether_addr_copy(hsr_dev->dev_addr, hsr_priv->slave[0]->dev_addr);
+	ether_addr_copy(hsr_dev->dev_addr, hsr->slave[0]->dev_addr);
=20
 	/* Set required header length */
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
-		if (slave[i]->hard_header_len + HSR_TAGLEN >
+		if (slave[i]->hard_header_len + HSR_HLEN >
 						hsr_dev->hard_header_len)
 			hsr_dev->hard_header_len =3D
-					slave[i]->hard_header_len + HSR_TAGLEN;
+					slave[i]->hard_header_len + HSR_HLEN;
 	}
=20
 	/* MTU */
 	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
-		if (slave[i]->mtu - HSR_TAGLEN < hsr_dev->mtu)
-			hsr_dev->mtu =3D slave[i]->mtu - HSR_TAGLEN;
+		if (slave[i]->mtu - HSR_HLEN < hsr_dev->mtu)
+			hsr_dev->mtu =3D slave[i]->mtu - HSR_HLEN;
=20
 	/* Make sure the 1st call to netif_carrier_on() gets through */
 	netif_carrier_off(hsr_dev);
@@ -576,9 +576,8 @@ int hsr_dev_finalize(struct net_device *hsr_dev, st=
ruct net_device *slave[2],
 	}
=20
 	/* Make sure we recognize frames from ourselves in hsr_rcv() */
-	res =3D hsr_create_self_node(&hsr_priv->self_node_db,
-					hsr_dev->dev_addr,
-					hsr_priv->slave[1]->dev_addr);
+	res =3D hsr_create_self_node(&hsr->self_node_db, hsr_dev->dev_addr,
+				   hsr->slave[1]->dev_addr);
 	if (res < 0)
 		goto fail;
=20
@@ -586,7 +585,7 @@ int hsr_dev_finalize(struct net_device *hsr_dev, st=
ruct net_device *slave[2],
 	if (res)
 		goto fail;
=20
-	register_hsr_master(hsr_priv);
+	register_hsr_master(hsr);
=20
 	return 0;
=20
diff --git a/net/hsr/hsr_device.h b/net/hsr/hsr_device.h
index 2c7148e..feb744f 100644
--- a/net/hsr/hsr_device.h
+++ b/net/hsr/hsr_device.h
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  */
=20
 #ifndef __HSR_DEVICE_H
@@ -24,6 +24,6 @@ void hsr_set_carrier(struct net_device *hsr_dev, stru=
ct net_device *slave1,
 		     struct net_device *slave2);
 void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)=
;
 bool is_hsr_master(struct net_device *dev);
-int hsr_get_max_mtu(struct hsr_priv *hsr_priv);
+int hsr_get_max_mtu(struct hsr_priv *hsr);
=20
 #endif /* __HSR_DEVICE_H */
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
index 83e5844..b419edb 100644
--- a/net/hsr/hsr_framereg.c
+++ b/net/hsr/hsr_framereg.c
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  *
  * The HSR spec says never to forward the same frame twice on the same
  * interface. A frame is identified by its source MAC address and its =
HSR
@@ -23,17 +23,17 @@
 #include "hsr_netlink.h"
=20
=20
-struct node_entry {
-	struct list_head mac_list;
-	unsigned char	MacAddressA[ETH_ALEN];
-	unsigned char	MacAddressB[ETH_ALEN];
-	enum hsr_dev_idx   AddrB_if;	/* The local slave through which AddrB
-					 * frames are received from this node
-					 */
-	unsigned long	time_in[HSR_MAX_SLAVE];
-	bool		time_in_stale[HSR_MAX_SLAVE];
-	u16		seq_out[HSR_MAX_DEV];
-	struct rcu_head rcu_head;
+struct hsr_node {
+	struct list_head	mac_list;
+	unsigned char		MacAddressA[ETH_ALEN];
+	unsigned char		MacAddressB[ETH_ALEN];
+	enum hsr_dev_idx	AddrB_if;/* The local slave through which AddrB
+					  * frames are received from this node
+					  */
+	unsigned long		time_in[HSR_MAX_SLAVE];
+	bool			time_in_stale[HSR_MAX_SLAVE];
+	u16			seq_out[HSR_MAX_DEV];
+	struct rcu_head		rcu_head;
 };
=20
 /*	TODO: use hash lists for mac addresses (linux/jhash.h)?    */
@@ -42,10 +42,10 @@ struct node_entry {
=20
 /* Search for mac entry. Caller must hold rcu read lock.
  */
-static struct node_entry *find_node_by_AddrA(struct list_head *node_db=
,
-					     const unsigned char addr[ETH_ALEN])
+static struct hsr_node *find_node_by_AddrA(struct list_head *node_db,
+					   const unsigned char addr[ETH_ALEN])
 {
-	struct node_entry *node;
+	struct hsr_node *node;
=20
 	list_for_each_entry_rcu(node, node_db, mac_list) {
 		if (ether_addr_equal(node->MacAddressA, addr))
@@ -58,10 +58,10 @@ static struct node_entry *find_node_by_AddrA(struct=
 list_head *node_db,
=20
 /* Search for mac entry. Caller must hold rcu read lock.
  */
-static struct node_entry *find_node_by_AddrB(struct list_head *node_db=
,
-					     const unsigned char addr[ETH_ALEN])
+static struct hsr_node *find_node_by_AddrB(struct list_head *node_db,
+					   const unsigned char addr[ETH_ALEN])
 {
-	struct node_entry *node;
+	struct hsr_node *node;
=20
 	list_for_each_entry_rcu(node, node_db, mac_list) {
 		if (ether_addr_equal(node->MacAddressB, addr))
@@ -74,9 +74,9 @@ static struct node_entry *find_node_by_AddrB(struct l=
ist_head *node_db,
=20
 /* Search for mac entry. Caller must hold rcu read lock.
  */
-struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_=
buff *skb)
+struct hsr_node *hsr_find_node(struct list_head *node_db, struct sk_bu=
ff *skb)
 {
-	struct node_entry *node;
+	struct hsr_node *node;
 	struct ethhdr *ethhdr;
=20
 	if (!skb_mac_header_was_set(skb))
@@ -102,7 +102,7 @@ int hsr_create_self_node(struct list_head *self_nod=
e_db,
 			 unsigned char addr_a[ETH_ALEN],
 			 unsigned char addr_b[ETH_ALEN])
 {
-	struct node_entry *node, *oldnode;
+	struct hsr_node *node, *oldnode;
=20
 	node =3D kmalloc(sizeof(*node), GFP_KERNEL);
 	if (!node)
@@ -113,7 +113,7 @@ int hsr_create_self_node(struct list_head *self_nod=
e_db,
=20
 	rcu_read_lock();
 	oldnode =3D list_first_or_null_rcu(self_node_db,
-						struct node_entry, mac_list);
+						struct hsr_node, mac_list);
 	if (oldnode) {
 		list_replace_rcu(&oldnode->mac_list, &node->mac_list);
 		rcu_read_unlock();
@@ -154,10 +154,10 @@ int hsr_create_self_node(struct list_head *self_n=
ode_db,
  * We also need to detect if the sender's SlaveA and SlaveB cables hav=
e been
  * swapped.
  */
-struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
-				  struct node_entry *node,
-				  struct sk_buff *skb,
-				  enum hsr_dev_idx dev_idx)
+struct hsr_node *hsr_merge_node(struct hsr_priv *hsr,
+				struct hsr_node *node,
+				struct sk_buff *skb,
+				enum hsr_dev_idx dev_idx)
 {
 	struct hsr_sup_payload *hsr_sp;
 	struct hsr_ethhdr_sp *hsr_ethsup;
@@ -194,7 +194,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv *=
hsr_priv,
 	if (node)
 		return node;
=20
-	node =3D find_node_by_AddrA(&hsr_priv->node_db, hsr_sp->MacAddressA);
+	node =3D find_node_by_AddrA(&hsr->node_db, hsr_sp->MacAddressA);
 	if (node) {
 		/* Node is known, but frame was received from an unknown
 		 * address. Node is PICS_SUBS capable; merge its AddrB.
@@ -224,7 +224,7 @@ struct node_entry *hsr_merge_node(struct hsr_priv *=
hsr_priv,
 	for (i =3D 0; i < HSR_MAX_DEV; i++)
 		node->seq_out[i] =3D ntohs(hsr_ethsup->hsr_sup.sequence_nr) - 1;
=20
-	list_add_tail_rcu(&node->mac_list, &hsr_priv->node_db);
+	list_add_tail_rcu(&node->mac_list, &hsr->node_db);
=20
 	return node;
 }
@@ -236,10 +236,10 @@ struct node_entry *hsr_merge_node(struct hsr_priv=
 *hsr_priv,
  * address with that node's "official" address (MacAddressA) so that u=
pper
  * layers recognize where it came from.
  */
-void hsr_addr_subst_source(struct hsr_priv *hsr_priv, struct sk_buff *=
skb)
+void hsr_addr_subst_source(struct hsr_priv *hsr, struct sk_buff *skb)
 {
 	struct ethhdr *ethhdr;
-	struct node_entry *node;
+	struct hsr_node *node;
=20
 	if (!skb_mac_header_was_set(skb)) {
 		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
@@ -248,7 +248,7 @@ void hsr_addr_subst_source(struct hsr_priv *hsr_pri=
v, struct sk_buff *skb)
 	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
=20
 	rcu_read_lock();
-	node =3D find_node_by_AddrB(&hsr_priv->node_db, ethhdr->h_source);
+	node =3D find_node_by_AddrB(&hsr->node_db, ethhdr->h_source);
 	if (node)
 		ether_addr_copy(ethhdr->h_source, node->MacAddressA);
 	rcu_read_unlock();
@@ -264,13 +264,13 @@ void hsr_addr_subst_source(struct hsr_priv *hsr_p=
riv, struct sk_buff *skb)
  * This is needed to keep the packets flowing through switches that le=
arn on
  * which "side" the different interfaces are.
  */
-void hsr_addr_subst_dest(struct hsr_priv *hsr_priv, struct ethhdr *eth=
hdr,
+void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
 			 enum hsr_dev_idx dev_idx)
 {
-	struct node_entry *node;
+	struct hsr_node *node;
=20
 	rcu_read_lock();
-	node =3D find_node_by_AddrA(&hsr_priv->node_db, ethhdr->h_dest);
+	node =3D find_node_by_AddrA(&hsr->node_db, ethhdr->h_dest);
 	if (node && (node->AddrB_if =3D=3D dev_idx))
 		ether_addr_copy(ethhdr->h_dest, node->MacAddressB);
 	rcu_read_unlock();
@@ -295,7 +295,7 @@ static bool seq_nr_after(u16 a, u16 b)
 #define seq_nr_before_or_eq(a, b)	(!seq_nr_after((a), (b)))
=20
=20
-void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx d=
ev_idx)
+void hsr_register_frame_in(struct hsr_node *node, enum hsr_dev_idx dev=
_idx)
 {
 	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_SLAVE)) {
 		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
@@ -314,7 +314,7 @@ void hsr_register_frame_in(struct node_entry *node,=
 enum hsr_dev_idx dev_idx)
  *	 0 otherwise, or
  *	 negative error code on error
  */
-int hsr_register_frame_out(struct node_entry *node, enum hsr_dev_idx d=
ev_idx,
+int hsr_register_frame_out(struct hsr_node *node, enum hsr_dev_idx dev=
_idx,
 			   struct sk_buff *skb)
 {
 	struct hsr_ethhdr *hsr_ethhdr;
@@ -340,7 +340,7 @@ int hsr_register_frame_out(struct node_entry *node,=
 enum hsr_dev_idx dev_idx,
=20
=20
=20
-static bool is_late(struct node_entry *node, enum hsr_dev_idx dev_idx)
+static bool is_late(struct hsr_node *node, enum hsr_dev_idx dev_idx)
 {
 	enum hsr_dev_idx other;
=20
@@ -366,14 +366,14 @@ static bool is_late(struct node_entry *node, enum=
 hsr_dev_idx dev_idx)
 /* Remove stale sequence_nr records. Called by timer every
  * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
  */
-void hsr_prune_nodes(struct hsr_priv *hsr_priv)
+void hsr_prune_nodes(struct hsr_priv *hsr)
 {
-	struct node_entry *node;
+	struct hsr_node *node;
 	unsigned long timestamp;
 	unsigned long time_a, time_b;
=20
 	rcu_read_lock();
-	list_for_each_entry_rcu(node, &hsr_priv->node_db, mac_list) {
+	list_for_each_entry_rcu(node, &hsr->node_db, mac_list) {
 		/* Shorthand */
 		time_a =3D node->time_in[HSR_DEV_SLAVE_A];
 		time_b =3D node->time_in[HSR_DEV_SLAVE_B];
@@ -399,17 +399,17 @@ void hsr_prune_nodes(struct hsr_priv *hsr_priv)
 					msecs_to_jiffies(1.5*MAX_SLAVE_DIFF))) {
=20
 			if (is_late(node, HSR_DEV_SLAVE_A))
-				hsr_nl_ringerror(hsr_priv, node->MacAddressA,
+				hsr_nl_ringerror(hsr, node->MacAddressA,
 						 HSR_DEV_SLAVE_A);
 			else if (is_late(node, HSR_DEV_SLAVE_B))
-				hsr_nl_ringerror(hsr_priv, node->MacAddressA,
+				hsr_nl_ringerror(hsr, node->MacAddressA,
 						 HSR_DEV_SLAVE_B);
 		}
=20
 		/* Prune old entries */
 		if (time_is_before_jiffies(timestamp +
 					msecs_to_jiffies(HSR_NODE_FORGET_TIME))) {
-			hsr_nl_nodedown(hsr_priv, node->MacAddressA);
+			hsr_nl_nodedown(hsr, node->MacAddressA);
 			list_del_rcu(&node->mac_list);
 			/* Note that we need to free this entry later: */
 			kfree_rcu(node, rcu_head);
@@ -419,21 +419,21 @@ void hsr_prune_nodes(struct hsr_priv *hsr_priv)
 }
=20
=20
-void *hsr_get_next_node(struct hsr_priv *hsr_priv, void *_pos,
+void *hsr_get_next_node(struct hsr_priv *hsr, void *_pos,
 			unsigned char addr[ETH_ALEN])
 {
-	struct node_entry *node;
+	struct hsr_node *node;
=20
 	if (!_pos) {
-		node =3D list_first_or_null_rcu(&hsr_priv->node_db,
-						struct node_entry, mac_list);
+		node =3D list_first_or_null_rcu(&hsr->node_db,
+					      struct hsr_node, mac_list);
 		if (node)
 			ether_addr_copy(addr, node->MacAddressA);
 		return node;
 	}
=20
 	node =3D _pos;
-	list_for_each_entry_continue_rcu(node, &hsr_priv->node_db, mac_list) =
{
+	list_for_each_entry_continue_rcu(node, &hsr->node_db, mac_list) {
 		ether_addr_copy(addr, node->MacAddressA);
 		return node;
 	}
@@ -442,7 +442,7 @@ void *hsr_get_next_node(struct hsr_priv *hsr_priv, =
void *_pos,
 }
=20
=20
-int hsr_get_node_data(struct hsr_priv *hsr_priv,
+int hsr_get_node_data(struct hsr_priv *hsr,
 		      const unsigned char *addr,
 		      unsigned char addr_b[ETH_ALEN],
 		      unsigned int *addr_b_ifindex,
@@ -451,12 +451,12 @@ int hsr_get_node_data(struct hsr_priv *hsr_priv,
 		      int *if2_age,
 		      u16 *if2_seq)
 {
-	struct node_entry *node;
+	struct hsr_node *node;
 	unsigned long tdiff;
=20
=20
 	rcu_read_lock();
-	node =3D find_node_by_AddrA(&hsr_priv->node_db, addr);
+	node =3D find_node_by_AddrA(&hsr->node_db, addr);
 	if (!node) {
 		rcu_read_unlock();
 		return -ENOENT;	/* No such entry */
@@ -488,8 +488,8 @@ int hsr_get_node_data(struct hsr_priv *hsr_priv,
 	*if1_seq =3D node->seq_out[HSR_DEV_SLAVE_B];
 	*if2_seq =3D node->seq_out[HSR_DEV_SLAVE_A];
=20
-	if ((node->AddrB_if !=3D HSR_DEV_NONE) && hsr_priv->slave[node->AddrB=
_if])
-		*addr_b_ifindex =3D hsr_priv->slave[node->AddrB_if]->ifindex;
+	if ((node->AddrB_if !=3D HSR_DEV_NONE) && hsr->slave[node->AddrB_if])
+		*addr_b_ifindex =3D hsr->slave[node->AddrB_if]->ifindex;
 	else
 		*addr_b_ifindex =3D -1;
=20
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
index e6c4022..3675139 100644
--- a/net/hsr/hsr_framereg.h
+++ b/net/hsr/hsr_framereg.h
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,42 +6,42 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  */
=20
-#ifndef _HSR_FRAMEREG_H
-#define _HSR_FRAMEREG_H
+#ifndef __HSR_FRAMEREG_H
+#define __HSR_FRAMEREG_H
=20
 #include "hsr_main.h"
=20
-struct node_entry;
+struct hsr_node;
=20
-struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_=
buff *skb);
+struct hsr_node *hsr_find_node(struct list_head *node_db, struct sk_bu=
ff *skb);
=20
-struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
-				  struct node_entry *node,
-				  struct sk_buff *skb,
-				  enum hsr_dev_idx dev_idx);
+struct hsr_node *hsr_merge_node(struct hsr_priv *hsr,
+				struct hsr_node *node,
+				struct sk_buff *skb,
+				enum hsr_dev_idx dev_idx);
=20
-void hsr_addr_subst_source(struct hsr_priv *hsr_priv, struct sk_buff *=
skb);
-void hsr_addr_subst_dest(struct hsr_priv *hsr_priv, struct ethhdr *eth=
hdr,
+void hsr_addr_subst_source(struct hsr_priv *hsr, struct sk_buff *skb);
+void hsr_addr_subst_dest(struct hsr_priv *hsr, struct ethhdr *ethhdr,
 			 enum hsr_dev_idx dev_idx);
=20
-void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx d=
ev_idx);
+void hsr_register_frame_in(struct hsr_node *node, enum hsr_dev_idx dev=
_idx);
=20
-int hsr_register_frame_out(struct node_entry *node, enum hsr_dev_idx d=
ev_idx,
+int hsr_register_frame_out(struct hsr_node *node, enum hsr_dev_idx dev=
_idx,
 			   struct sk_buff *skb);
=20
-void hsr_prune_nodes(struct hsr_priv *hsr_priv);
+void hsr_prune_nodes(struct hsr_priv *hsr);
=20
 int hsr_create_self_node(struct list_head *self_node_db,
 			 unsigned char addr_a[ETH_ALEN],
 			 unsigned char addr_b[ETH_ALEN]);
=20
-void *hsr_get_next_node(struct hsr_priv *hsr_priv, void *_pos,
+void *hsr_get_next_node(struct hsr_priv *hsr, void *_pos,
 			unsigned char addr[ETH_ALEN]);
=20
-int hsr_get_node_data(struct hsr_priv *hsr_priv,
+int hsr_get_node_data(struct hsr_priv *hsr,
 		      const unsigned char *addr,
 		      unsigned char addr_b[ETH_ALEN],
 		      unsigned int *addr_b_ifindex,
@@ -50,4 +50,4 @@ int hsr_get_node_data(struct hsr_priv *hsr_priv,
 		      int *if2_age,
 		      u16 *if2_seq);
=20
-#endif /* _HSR_FRAMEREG_H */
+#endif /* __HSR_FRAMEREG_H */
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 3fee521..99b8fc4 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  *
  * In addition to routines for registering and unregistering HSR suppo=
rt, this
  * file also contains the receive routine that handles all incoming fr=
ames with
@@ -26,30 +26,30 @@
 /* List of all registered virtual HSR devices */
 static LIST_HEAD(hsr_list);
=20
-void register_hsr_master(struct hsr_priv *hsr_priv)
+void register_hsr_master(struct hsr_priv *hsr)
 {
-	list_add_tail_rcu(&hsr_priv->hsr_list, &hsr_list);
+	list_add_tail_rcu(&hsr->hsr_list, &hsr_list);
 }
=20
-void unregister_hsr_master(struct hsr_priv *hsr_priv)
+void unregister_hsr_master(struct hsr_priv *hsr)
 {
-	struct hsr_priv *hsr_priv_it;
+	struct hsr_priv *hsr_it;
=20
-	list_for_each_entry(hsr_priv_it, &hsr_list, hsr_list)
-		if (hsr_priv_it =3D=3D hsr_priv) {
-			list_del_rcu(&hsr_priv_it->hsr_list);
+	list_for_each_entry(hsr_it, &hsr_list, hsr_list)
+		if (hsr_it =3D=3D hsr) {
+			list_del_rcu(&hsr_it->hsr_list);
 			return;
 		}
 }
=20
 bool is_hsr_slave(struct net_device *dev)
 {
-	struct hsr_priv *hsr_priv_it;
+	struct hsr_priv *hsr_it;
=20
-	list_for_each_entry_rcu(hsr_priv_it, &hsr_list, hsr_list) {
-		if (dev =3D=3D hsr_priv_it->slave[0])
+	list_for_each_entry_rcu(hsr_it, &hsr_list, hsr_list) {
+		if (dev =3D=3D hsr_it->slave[0])
 			return true;
-		if (dev =3D=3D hsr_priv_it->slave[1])
+		if (dev =3D=3D hsr_it->slave[1])
 			return true;
 	}
=20
@@ -62,14 +62,14 @@ bool is_hsr_slave(struct net_device *dev)
  */
 static struct hsr_priv *get_hsr_master(struct net_device *dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
 	rcu_read_lock();
-	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list)
-		if ((dev =3D=3D hsr_priv->slave[0]) ||
-		    (dev =3D=3D hsr_priv->slave[1])) {
+	list_for_each_entry_rcu(hsr, &hsr_list, hsr_list)
+		if ((dev =3D=3D hsr->slave[0]) ||
+		    (dev =3D=3D hsr->slave[1])) {
 			rcu_read_unlock();
-			return hsr_priv;
+			return hsr;
 		}
=20
 	rcu_read_unlock();
@@ -80,13 +80,13 @@ static struct hsr_priv *get_hsr_master(struct net_d=
evice *dev)
 /* If dev is a HSR slave device, return the other slave device. Return=
 NULL
  * otherwise.
  */
-static struct net_device *get_other_slave(struct hsr_priv *hsr_priv,
+static struct net_device *get_other_slave(struct hsr_priv *hsr,
 					  struct net_device *dev)
 {
-	if (dev =3D=3D hsr_priv->slave[0])
-		return hsr_priv->slave[1];
-	if (dev =3D=3D hsr_priv->slave[1])
-		return hsr_priv->slave[0];
+	if (dev =3D=3D hsr->slave[0])
+		return hsr->slave[1];
+	if (dev =3D=3D hsr->slave[1])
+		return hsr->slave[0];
=20
 	return NULL;
 }
@@ -96,7 +96,7 @@ static int hsr_netdev_notify(struct notifier_block *n=
b, unsigned long event,
 			     void *ptr)
 {
 	struct net_device *slave, *other_slave;
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	int old_operstate;
 	int mtu_max;
 	int res;
@@ -104,68 +104,68 @@ static int hsr_netdev_notify(struct notifier_bloc=
k *nb, unsigned long event,
=20
 	dev =3D netdev_notifier_info_to_dev(ptr);
=20
-	hsr_priv =3D get_hsr_master(dev);
-	if (hsr_priv) {
+	hsr =3D get_hsr_master(dev);
+	if (hsr) {
 		/* dev is a slave device */
 		slave =3D dev;
-		other_slave =3D get_other_slave(hsr_priv, slave);
+		other_slave =3D get_other_slave(hsr, slave);
 	} else {
 		if (!is_hsr_master(dev))
 			return NOTIFY_DONE;
-		hsr_priv =3D netdev_priv(dev);
-		slave =3D hsr_priv->slave[0];
-		other_slave =3D hsr_priv->slave[1];
+		hsr =3D netdev_priv(dev);
+		slave =3D hsr->slave[0];
+		other_slave =3D hsr->slave[1];
 	}
=20
 	switch (event) {
 	case NETDEV_UP:		/* Administrative state DOWN */
 	case NETDEV_DOWN:	/* Administrative state UP */
 	case NETDEV_CHANGE:	/* Link (carrier) state changes */
-		old_operstate =3D hsr_priv->dev->operstate;
-		hsr_set_carrier(hsr_priv->dev, slave, other_slave);
+		old_operstate =3D hsr->dev->operstate;
+		hsr_set_carrier(hsr->dev, slave, other_slave);
 		/* netif_stacked_transfer_operstate() cannot be used here since
 		 * it doesn't set IF_OPER_LOWERLAYERDOWN (?)
 		 */
-		hsr_set_operstate(hsr_priv->dev, slave, other_slave);
-		hsr_check_announce(hsr_priv->dev, old_operstate);
+		hsr_set_operstate(hsr->dev, slave, other_slave);
+		hsr_check_announce(hsr->dev, old_operstate);
 		break;
 	case NETDEV_CHANGEADDR:
=20
 		/* This should not happen since there's no ndo_set_mac_address()
 		 * for HSR devices - i.e. not supported.
 		 */
-		if (dev =3D=3D hsr_priv->dev)
+		if (dev =3D=3D hsr->dev)
 			break;
=20
-		if (dev =3D=3D hsr_priv->slave[0])
-			ether_addr_copy(hsr_priv->dev->dev_addr,
-					hsr_priv->slave[0]->dev_addr);
+		if (dev =3D=3D hsr->slave[0])
+			ether_addr_copy(hsr->dev->dev_addr,
+					hsr->slave[0]->dev_addr);
=20
 		/* Make sure we recognize frames from ourselves in hsr_rcv() */
-		res =3D hsr_create_self_node(&hsr_priv->self_node_db,
-					   hsr_priv->dev->dev_addr,
-					   hsr_priv->slave[1] ?
-						hsr_priv->slave[1]->dev_addr :
-						hsr_priv->dev->dev_addr);
+		res =3D hsr_create_self_node(&hsr->self_node_db,
+					   hsr->dev->dev_addr,
+					   hsr->slave[1] ?
+						hsr->slave[1]->dev_addr :
+						hsr->dev->dev_addr);
 		if (res)
-			netdev_warn(hsr_priv->dev,
+			netdev_warn(hsr->dev,
 				    "Could not update HSR node address.\n");
=20
-		if (dev =3D=3D hsr_priv->slave[0])
-			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr_priv->dev);
+		if (dev =3D=3D hsr->slave[0])
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr->dev);
 		break;
 	case NETDEV_CHANGEMTU:
-		if (dev =3D=3D hsr_priv->dev)
+		if (dev =3D=3D hsr->dev)
 			break; /* Handled in ndo_change_mtu() */
-		mtu_max =3D hsr_get_max_mtu(hsr_priv);
-		if (hsr_priv->dev->mtu > mtu_max)
-			dev_set_mtu(hsr_priv->dev, mtu_max);
+		mtu_max =3D hsr_get_max_mtu(hsr);
+		if (hsr->dev->mtu > mtu_max)
+			dev_set_mtu(hsr->dev, mtu_max);
 		break;
 	case NETDEV_UNREGISTER:
-		if (dev =3D=3D hsr_priv->slave[0])
-			hsr_priv->slave[0] =3D NULL;
-		if (dev =3D=3D hsr_priv->slave[1])
-			hsr_priv->slave[1] =3D NULL;
+		if (dev =3D=3D hsr->slave[0])
+			hsr->slave[0] =3D NULL;
+		if (dev =3D=3D hsr->slave[1])
+			hsr->slave[1] =3D NULL;
=20
 		/* There should really be a way to set a new slave device... */
=20
@@ -185,11 +185,11 @@ static struct timer_list prune_timer;
=20
 static void prune_nodes_all(unsigned long data)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
 	rcu_read_lock();
-	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list)
-		hsr_prune_nodes(hsr_priv);
+	list_for_each_entry_rcu(hsr, &hsr_list, hsr_list)
+		hsr_prune_nodes(hsr);
 	rcu_read_unlock();
=20
 	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
@@ -207,12 +207,12 @@ static struct sk_buff *hsr_pull_tag(struct sk_buf=
f *skb)
 		goto err_free;
 	skb =3D skb2;
=20
-	if (unlikely(!pskb_may_pull(skb, HSR_TAGLEN)))
+	if (unlikely(!pskb_may_pull(skb, HSR_HLEN)))
 		goto err_free;
=20
 	hsr_tag =3D (struct hsr_tag *) skb->data;
 	skb->protocol =3D hsr_tag->encap_proto;
-	skb_pull(skb, HSR_TAGLEN);
+	skb_pull(skb, HSR_HLEN);
=20
 	return skb;
=20
@@ -237,12 +237,12 @@ err_free:
  * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
  *    MacAddressA field.
  */
-static bool is_supervision_frame(struct hsr_priv *hsr_priv, struct sk_=
buff *skb)
+static bool is_supervision_frame(struct hsr_priv *hsr, struct sk_buff =
*skb)
 {
 	struct hsr_sup_tag *hsr_stag;
=20
 	if (!ether_addr_equal(eth_hdr(skb)->h_dest,
-			      hsr_priv->sup_multicast_addr))
+			      hsr->sup_multicast_addr))
 		return false;
=20
 	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
@@ -263,25 +263,25 @@ static bool is_supervision_frame(struct hsr_priv =
*hsr_priv, struct sk_buff *skb)
 static int hsr_rcv(struct sk_buff *skb, struct net_device *dev,
 		   struct packet_type *pt, struct net_device *orig_dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	struct net_device *other_slave;
-	struct node_entry *node;
+	struct hsr_node *node;
 	bool deliver_to_self;
 	struct sk_buff *skb_deliver;
 	enum hsr_dev_idx dev_in_idx, dev_other_idx;
 	bool dup_out;
 	int ret;
=20
-	hsr_priv =3D get_hsr_master(dev);
+	hsr =3D get_hsr_master(dev);
=20
-	if (!hsr_priv) {
+	if (!hsr) {
 		/* Non-HSR-slave device 'dev' is connected to a HSR network */
 		kfree_skb(skb);
 		dev->stats.rx_errors++;
 		return NET_RX_SUCCESS;
 	}
=20
-	if (dev =3D=3D hsr_priv->slave[0]) {
+	if (dev =3D=3D hsr->slave[0]) {
 		dev_in_idx =3D HSR_DEV_SLAVE_A;
 		dev_other_idx =3D HSR_DEV_SLAVE_B;
 	} else {
@@ -289,7 +289,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_=
device *dev,
 		dev_other_idx =3D HSR_DEV_SLAVE_A;
 	}
=20
-	node =3D hsr_find_node(&hsr_priv->self_node_db, skb);
+	node =3D hsr_find_node(&hsr->self_node_db, skb);
 	if (node) {
 		/* Always kill frames sent by ourselves */
 		kfree_skb(skb);
@@ -303,22 +303,22 @@ static int hsr_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
 		deliver_to_self =3D true;
 	else if (ether_addr_equal(eth_hdr(skb)->h_dest,
-				     hsr_priv->dev->dev_addr)) {
+				     hsr->dev->dev_addr)) {
 		skb->pkt_type =3D PACKET_HOST;
 		deliver_to_self =3D true;
 	}
=20
=20
 	rcu_read_lock(); /* node_db */
-	node =3D hsr_find_node(&hsr_priv->node_db, skb);
+	node =3D hsr_find_node(&hsr->node_db, skb);
=20
-	if (is_supervision_frame(hsr_priv, skb)) {
+	if (is_supervision_frame(hsr, skb)) {
 		skb_pull(skb, sizeof(struct hsr_sup_tag));
-		node =3D hsr_merge_node(hsr_priv, node, skb, dev_in_idx);
+		node =3D hsr_merge_node(hsr, node, skb, dev_in_idx);
 		if (!node) {
 			rcu_read_unlock(); /* node_db */
 			kfree_skb(skb);
-			hsr_priv->dev->stats.rx_dropped++;
+			hsr->dev->stats.rx_dropped++;
 			return NET_RX_DROP;
 		}
 		skb_push(skb, sizeof(struct hsr_sup_tag));
@@ -345,7 +345,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_=
device *dev,
=20
 	/* Forward this frame? */
 	if (!dup_out && (skb->pkt_type !=3D PACKET_HOST))
-		other_slave =3D get_other_slave(hsr_priv, dev);
+		other_slave =3D get_other_slave(hsr, dev);
 	else
 		other_slave =3D NULL;
=20
@@ -368,7 +368,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_=
device *dev,
 		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
 		if (!skb_deliver) {
 			deliver_to_self =3D false;
-			hsr_priv->dev->stats.rx_dropped++;
+			hsr->dev->stats.rx_dropped++;
 		}
 	}
=20
@@ -377,7 +377,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_=
device *dev,
=20
 		skb_deliver =3D hsr_pull_tag(skb_deliver);
 		if (!skb_deliver) {
-			hsr_priv->dev->stats.rx_dropped++;
+			hsr->dev->stats.rx_dropped++;
 			goto forward;
 		}
 #if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
@@ -386,7 +386,7 @@ static int hsr_rcv(struct sk_buff *skb, struct net_=
device *dev,
 		 * tag. In practice, this removes/overwrites the HSR tag in
 		 * the header and restores a "standard" packet.
 		 */
-		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
+		memmove(skb_deliver->data - HSR_HLEN, skb_deliver->data,
 			skb_headlen(skb_deliver));
=20
 		/* Adjust skb members so they correspond with the move above.
@@ -397,20 +397,20 @@ static int hsr_rcv(struct sk_buff *skb, struct ne=
t_device *dev,
 		 * the mac header nor the head. So we only need to adjust data
 		 * and tail:
 		 */
-		skb_deliver->data -=3D HSR_TAGLEN;
-		skb_deliver->tail -=3D HSR_TAGLEN;
+		skb_deliver->data -=3D HSR_HLEN;
+		skb_deliver->tail -=3D HSR_HLEN;
 #endif
-		skb_deliver->dev =3D hsr_priv->dev;
-		hsr_addr_subst_source(hsr_priv, skb_deliver);
+		skb_deliver->dev =3D hsr->dev;
+		hsr_addr_subst_source(hsr, skb_deliver);
 		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
 		ret =3D netif_rx(skb_deliver);
 		if (ret =3D=3D NET_RX_DROP) {
-			hsr_priv->dev->stats.rx_dropped++;
+			hsr->dev->stats.rx_dropped++;
 		} else {
-			hsr_priv->dev->stats.rx_packets++;
-			hsr_priv->dev->stats.rx_bytes +=3D skb->len;
+			hsr->dev->stats.rx_packets++;
+			hsr->dev->stats.rx_bytes +=3D skb->len;
 			if (multicast_frame)
-				hsr_priv->dev->stats.multicast++;
+				hsr->dev->stats.multicast++;
 		}
 	}
=20
@@ -439,7 +439,7 @@ static int __init hsr_init(void)
 {
 	int res;
=20
-	BUILD_BUG_ON(sizeof(struct hsr_tag) !=3D HSR_TAGLEN);
+	BUILD_BUG_ON(sizeof(struct hsr_tag) !=3D HSR_HLEN);
=20
 	dev_add_pack(&hsr_pt);
=20
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
index 56fe060..360a49a 100644
--- a/net/hsr/hsr_main.h
+++ b/net/hsr/hsr_main.h
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,11 +6,11 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  */
=20
-#ifndef _HSR_PRIVATE_H
-#define _HSR_PRIVATE_H
+#ifndef __HSR_PRIVATE_H
+#define __HSR_PRIVATE_H
=20
 #include <linux/netdevice.h>
 #include <linux/list.h>
@@ -46,16 +46,16 @@
  * path, LSDU_size, sequence Nr }. But we let eth_header() create { h_=
dest,
  * h_source, h_proto =3D 0x88FB }, and add { path, LSDU_size, sequence=
 Nr,
  * encapsulated protocol } instead.
+ *
+ * Field names as defined in the IEC:2010 standard for HSR.
  */
-#define HSR_TAGLEN	6
-
-/* Field names below as defined in the IEC:2010 standard for HSR. */
 struct hsr_tag {
 	__be16		path_and_LSDU_size;
 	__be16		sequence_nr;
 	__be16		encap_proto;
 } __packed;
=20
+#define HSR_HLEN	6
=20
 /* The helper functions below assumes that 'path' occupies the 4 most
  * significant bits of the 16-bit field shared by 'path' and 'LSDU_siz=
e' (or
@@ -159,8 +159,8 @@ struct hsr_priv {
 	unsigned char		sup_multicast_addr[ETH_ALEN];
 };
=20
-void register_hsr_master(struct hsr_priv *hsr_priv);
-void unregister_hsr_master(struct hsr_priv *hsr_priv);
+void register_hsr_master(struct hsr_priv *hsr);
+void unregister_hsr_master(struct hsr_priv *hsr);
 bool is_hsr_slave(struct net_device *dev);
=20
-#endif /*  _HSR_PRIVATE_H */
+#endif /*  __HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
index 01a5261..bea250e 100644
--- a/net/hsr/hsr_netlink.c
+++ b/net/hsr/hsr_netlink.c
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  *
  * Routines for handling Netlink messages for HSR.
  */
@@ -63,21 +63,21 @@ static int hsr_newlink(struct net *src_net, struct =
net_device *dev,
=20
 static int hsr_fill_info(struct sk_buff *skb, const struct net_device =
*dev)
 {
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
=20
-	hsr_priv =3D netdev_priv(dev);
+	hsr =3D netdev_priv(dev);
=20
-	if (hsr_priv->slave[0])
-		if (nla_put_u32(skb, IFLA_HSR_SLAVE1, hsr_priv->slave[0]->ifindex))
+	if (hsr->slave[0])
+		if (nla_put_u32(skb, IFLA_HSR_SLAVE1, hsr->slave[0]->ifindex))
 			goto nla_put_failure;
=20
-	if (hsr_priv->slave[1])
-		if (nla_put_u32(skb, IFLA_HSR_SLAVE2, hsr_priv->slave[1]->ifindex))
+	if (hsr->slave[1])
+		if (nla_put_u32(skb, IFLA_HSR_SLAVE2, hsr->slave[1]->ifindex))
 			goto nla_put_failure;
=20
 	if (nla_put(skb, IFLA_HSR_SUPERVISION_ADDR, ETH_ALEN,
-		    hsr_priv->sup_multicast_addr) ||
-	    nla_put_u16(skb, IFLA_HSR_SEQ_NR, hsr_priv->sequence_nr))
+		    hsr->sup_multicast_addr) ||
+	    nla_put_u16(skb, IFLA_HSR_SEQ_NR, hsr->sequence_nr))
 		goto nla_put_failure;
=20
 	return 0;
@@ -128,7 +128,7 @@ static const struct genl_multicast_group hsr_mcgrps=
[] =3D {
  * over one of the slave interfaces. This would indicate an open netwo=
rk ring
  * (i.e. a link has failed somewhere).
  */
-void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ET=
H_ALEN],
+void hsr_nl_ringerror(struct hsr_priv *hsr, unsigned char addr[ETH_ALE=
N],
 		      enum hsr_dev_idx dev_idx)
 {
 	struct sk_buff *skb;
@@ -148,8 +148,8 @@ void hsr_nl_ringerror(struct hsr_priv *hsr_priv, un=
signed char addr[ETH_ALEN],
 	if (res < 0)
 		goto nla_put_failure;
=20
-	if (hsr_priv->slave[dev_idx])
-		ifindex =3D hsr_priv->slave[dev_idx]->ifindex;
+	if (hsr->slave[dev_idx])
+		ifindex =3D hsr->slave[dev_idx]->ifindex;
 	else
 		ifindex =3D -1;
 	res =3D nla_put_u32(skb, HSR_A_IFINDEX, ifindex);
@@ -165,13 +165,13 @@ nla_put_failure:
 	kfree_skb(skb);
=20
 fail:
-	netdev_warn(hsr_priv->dev, "Could not send HSR ring error message\n")=
;
+	netdev_warn(hsr->dev, "Could not send HSR ring error message\n");
 }
=20
 /* This is called when we haven't heard from the node with MAC address=
 addr for
  * some time (just before the node is removed from the node table/list=
).
  */
-void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH=
_ALEN])
+void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN=
])
 {
 	struct sk_buff *skb;
 	void *msg_head;
@@ -199,7 +199,7 @@ nla_put_failure:
 	kfree_skb(skb);
=20
 fail:
-	netdev_warn(hsr_priv->dev, "Could not send HSR node down\n");
+	netdev_warn(hsr->dev, "Could not send HSR node down\n");
 }
=20
=20
@@ -220,7 +220,7 @@ static int hsr_get_node_status(struct sk_buff *skb_=
in, struct genl_info *info)
 	/* For sending */
 	struct sk_buff *skb_out;
 	void *msg_head;
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	unsigned char hsr_node_addr_b[ETH_ALEN];
 	int hsr_node_if1_age;
 	u16 hsr_node_if1_seq;
@@ -267,8 +267,8 @@ static int hsr_get_node_status(struct sk_buff *skb_=
in, struct genl_info *info)
 	if (res < 0)
 		goto nla_put_failure;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
-	res =3D hsr_get_node_data(hsr_priv,
+	hsr =3D netdev_priv(hsr_dev);
+	res =3D hsr_get_node_data(hsr,
 			(unsigned char *) nla_data(info->attrs[HSR_A_NODE_ADDR]),
 			hsr_node_addr_b,
 			&addr_b_ifindex,
@@ -301,9 +301,9 @@ static int hsr_get_node_status(struct sk_buff *skb_=
in, struct genl_info *info)
 	res =3D nla_put_u16(skb_out, HSR_A_IF1_SEQ, hsr_node_if1_seq);
 	if (res < 0)
 		goto nla_put_failure;
-	if (hsr_priv->slave[0])
+	if (hsr->slave[0])
 		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX,
-						hsr_priv->slave[0]->ifindex);
+						hsr->slave[0]->ifindex);
 	if (res < 0)
 		goto nla_put_failure;
=20
@@ -313,9 +313,9 @@ static int hsr_get_node_status(struct sk_buff *skb_=
in, struct genl_info *info)
 	res =3D nla_put_u16(skb_out, HSR_A_IF2_SEQ, hsr_node_if2_seq);
 	if (res < 0)
 		goto nla_put_failure;
-	if (hsr_priv->slave[1])
+	if (hsr->slave[1])
 		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX,
-						hsr_priv->slave[1]->ifindex);
+						hsr->slave[1]->ifindex);
=20
 	genlmsg_end(skb_out, msg_head);
 	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
@@ -345,7 +345,7 @@ static int hsr_get_node_list(struct sk_buff *skb_in=
, struct genl_info *info)
 	/* For sending */
 	struct sk_buff *skb_out;
 	void *msg_head;
-	struct hsr_priv *hsr_priv;
+	struct hsr_priv *hsr;
 	void *pos;
 	unsigned char addr[ETH_ALEN];
 	int res;
@@ -385,17 +385,17 @@ static int hsr_get_node_list(struct sk_buff *skb_=
in, struct genl_info *info)
 	if (res < 0)
 		goto nla_put_failure;
=20
-	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr =3D netdev_priv(hsr_dev);
=20
 	rcu_read_lock();
-	pos =3D hsr_get_next_node(hsr_priv, NULL, addr);
+	pos =3D hsr_get_next_node(hsr, NULL, addr);
 	while (pos) {
 		res =3D nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN, addr);
 		if (res < 0) {
 			rcu_read_unlock();
 			goto nla_put_failure;
 		}
-		pos =3D hsr_get_next_node(hsr_priv, pos, addr);
+		pos =3D hsr_get_next_node(hsr, pos, addr);
 	}
 	rcu_read_unlock();
=20
diff --git a/net/hsr/hsr_netlink.h b/net/hsr/hsr_netlink.h
index d4579dc..3047f9c 100644
--- a/net/hsr/hsr_netlink.h
+++ b/net/hsr/hsr_netlink.h
@@ -1,4 +1,4 @@
-/* Copyright 2011-2013 Autronica Fire and Security AS
+/* Copyright 2011-2014 Autronica Fire and Security AS
  *
  * This program is free software; you can redistribute it and/or modif=
y it
  * under the terms of the GNU General Public License as published by t=
he Free
@@ -6,7 +6,7 @@
  * any later version.
  *
  * Author(s):
- *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *	2011-2014 Arvid Brodin, arvid.brodin@alten.se
  */
=20
 #ifndef __HSR_NETLINK_H
@@ -21,9 +21,9 @@ struct hsr_priv;
 int __init hsr_netlink_init(void);
 void __exit hsr_netlink_exit(void);
=20
-void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ET=
H_ALEN],
+void hsr_nl_ringerror(struct hsr_priv *hsr, unsigned char addr[ETH_ALE=
N],
 		      int dev_idx);
-void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH=
_ALEN]);
+void hsr_nl_nodedown(struct hsr_priv *hsr, unsigned char addr[ETH_ALEN=
]);
 void hsr_nl_framedrop(int dropcount, int dev_idx);
 void hsr_nl_linkdown(int dev_idx);
=20
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
