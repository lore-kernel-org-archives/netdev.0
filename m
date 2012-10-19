From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 06/21] staging: Convert is_<foo>_ether_addr uses to eth_addr_<foo>
Date: Thu, 18 Oct 2012 21:14:10 -0700
Message-ID: <cd74e20c3c7e1cd3e7543b226568dcf28463e801.1350618011.git.joe@perches.com>
References: <cover.1350618006.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1350618006.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Convert the old ether_addr tests to eth_addr_<foo>.
Adds api consistency.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/staging/ccg/u_ether.c                      |    6 +++---
 drivers/staging/csr/sme_wext.c                     |    2 +-
 drivers/staging/et131x/et131x.c                    |    4 ++--
 drivers/staging/gdm72xx/gdm_wimax.c                |    2 +-
 drivers/staging/octeon/ethernet.c                  |    2 +-
 drivers/staging/ozwpan/ozcdev.c                    |    2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac.c        |    2 +-
 .../rtl8187se/ieee80211/ieee80211_softmac_wx.c     |    2 +-
 drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c |    2 +-
 drivers/staging/rtl8187se/r8180_core.c             |    2 +-
 drivers/staging/rtl8192e/rtl8192e/rtl_core.c       |    6 +++---
 drivers/staging/rtl8192e/rtl819x_TSProc.c          |    2 +-
 drivers/staging/rtl8192e/rtllib_rx.c               |    8 ++++----
 drivers/staging/rtl8192e/rtllib_softmac.c          |    4 ++--
 drivers/staging/rtl8192e/rtllib_softmac_wx.c       |    4 ++--
 drivers/staging/rtl8192e/rtllib_tx.c               |   12 ++++++------
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c  |    4 ++--
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c |    2 +-
 .../rtl8192u/ieee80211/ieee80211_softmac_wx.c      |    2 +-
 drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c  |   12 ++++++------
 .../staging/rtl8192u/ieee80211/rtl819x_TSProc.c    |    2 +-
 drivers/staging/rtl8192u/r8192U_core.c             |    8 ++++----
 drivers/staging/rtl8712/rtl871x_ioctl_linux.c      |    2 +-
 drivers/staging/rtl8712/rtl871x_ioctl_set.c        |    2 +-
 drivers/staging/rtl8712/rtl871x_mlme.c             |    2 +-
 drivers/staging/rtl8712/rtl871x_recv.c             |    8 ++++----
 drivers/staging/slicoss/slicoss.c                  |    2 +-
 drivers/staging/vt6655/bssdb.c                     |    2 +-
 drivers/staging/vt6655/card.c                      |    2 +-
 drivers/staging/vt6655/device_main.c               |    2 +-
 drivers/staging/vt6655/dpc.c                       |    4 ++--
 drivers/staging/vt6655/hostap.c                    |    4 ++--
 drivers/staging/vt6655/iwctl.c                     |    2 +-
 drivers/staging/vt6655/key.c                       |    2 +-
 drivers/staging/vt6655/mib.c                       |    8 ++++----
 drivers/staging/vt6655/rxtx.c                      |   10 +++++-----
 drivers/staging/vt6655/wpactl.c                    |    4 ++--
 drivers/staging/vt6656/bssdb.c                     |    2 +-
 drivers/staging/vt6656/dpc.c                       |    4 ++--
 drivers/staging/vt6656/hostap.c                    |    4 ++--
 drivers/staging/vt6656/iwctl.c                     |    2 +-
 drivers/staging/vt6656/key.c                       |    2 +-
 drivers/staging/vt6656/rxtx.c                      |   14 +++++++-------
 drivers/staging/vt6656/wpactl.c                    |    2 +-
 drivers/staging/wlags49_h2/wl_wext.c               |    2 +-
 45 files changed, 90 insertions(+), 90 deletions(-)

diff --git a/drivers/staging/ccg/u_ether.c b/drivers/staging/ccg/u_ether.c
index d0dabcf..0f1a1b7 100644
--- a/drivers/staging/ccg/u_ether.c
+++ b/drivers/staging/ccg/u_ether.c
@@ -509,13 +509,13 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *skb,
 	if (!is_promisc(cdc_filter)) {
 		u8		*dest = skb->data;
 
-		if (is_multicast_ether_addr(dest)) {
+		if (eth_addr_multicast(dest)) {
 			u16	type;
 
 			/* ignores USB_CDC_PACKET_TYPE_MULTICAST and host
 			 * SET_ETHERNET_MULTICAST_FILTERS requests
 			 */
-			if (is_broadcast_ether_addr(dest))
+			if (eth_addr_broadcast(dest))
 				type = USB_CDC_PACKET_TYPE_BROADCAST;
 			else
 				type = USB_CDC_PACKET_TYPE_ALL_MULTICAST;
@@ -714,7 +714,7 @@ static int get_ether_addr(const char *str, u8 *dev_addr)
 			num |= hex_to_bin(*str++);
 			dev_addr [i] = num;
 		}
-		if (is_valid_ether_addr(dev_addr))
+		if (eth_addr_valid(dev_addr))
 			return 0;
 	}
 	eth_random_addr(dev_addr);
diff --git a/drivers/staging/csr/sme_wext.c b/drivers/staging/csr/sme_wext.c
index b58c0c6..0aea381 100644
--- a/drivers/staging/csr/sme_wext.c
+++ b/drivers/staging/csr/sme_wext.c
@@ -1211,7 +1211,7 @@ unifi_siwap(struct net_device *dev, struct iw_request_info *info,
 	unifi_trace(priv, UDBG1, "unifi_siwap: asked for %pM\n",
 		wrqu->ap_addr.sa_data);
 
-    if (is_zero_ether_addr(wrqu->ap_addr.sa_data)) {
+    if (eth_addr_zero(wrqu->ap_addr.sa_data)) {
         priv->ignore_bssid_join = FALSE;
         err = sme_mgt_disconnect(priv);
         if (err) {
diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
index 413da0d..90c8e86 100644
--- a/drivers/staging/et131x/et131x.c
+++ b/drivers/staging/et131x/et131x.c
@@ -3955,7 +3955,7 @@ static void et131x_hwaddr_init(struct et131x_adapter *adapter)
 	 * EEPROM then we need to generate the last octet and set it on the
 	 * device
 	 */
-	if (is_zero_ether_addr(adapter->rom_addr)) {
+	if (eth_addr_zero(adapter->rom_addr)) {
 		/*
 		 * We need to randomly generate the last octet so we
 		 * decrease our chances of setting the mac address to
@@ -5156,7 +5156,7 @@ static int et131x_set_mac_addr(struct net_device *netdev, void *new_mac)
 		return -ENODEV;
 
 	/* Make sure the requested MAC is valid */
-	if (!is_valid_ether_addr(address->sa_data))
+	if (!eth_addr_valid(address->sa_data))
 		return -EADDRNOTAVAIL;
 
 	et131x_disable_txrx(netdev);
diff --git a/drivers/staging/gdm72xx/gdm_wimax.c b/drivers/staging/gdm72xx/gdm_wimax.c
index 6cb8107..5a00ff6 100644
--- a/drivers/staging/gdm72xx/gdm_wimax.c
+++ b/drivers/staging/gdm72xx/gdm_wimax.c
@@ -489,7 +489,7 @@ static int gdm_wimax_set_mac_addr(struct net_device *dev, void *p)
 	if (netif_running(dev))
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	__gdm_wimax_set_mac_addr(dev, addr->sa_data);
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 683bedc..496351f 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -453,7 +453,7 @@ int cvm_oct_common_init(struct net_device *dev)
 	if (priv->of_node)
 		mac = of_get_mac_address(priv->of_node);
 
-	if (mac && is_valid_ether_addr(mac)) {
+	if (mac && eth_addr_valid(mac)) {
 		memcpy(dev->dev_addr, mac, ETH_ALEN);
 		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 	} else {
diff --git a/drivers/staging/ozwpan/ozcdev.c b/drivers/staging/ozwpan/ozcdev.c
index 64913ae..b2cf3b4 100644
--- a/drivers/staging/ozwpan/ozcdev.c
+++ b/drivers/staging/ozwpan/ozcdev.c
@@ -214,7 +214,7 @@ static int oz_set_active_pd(u8 *addr)
 		if (old_pd)
 			oz_pd_put(old_pd);
 	} else {
-		if (is_zero_ether_addr(addr)) {
+		if (eth_addr_zero(addr)) {
 			spin_lock_bh(&g_cdev.lock);
 			pd = g_cdev.active_pd;
 			g_cdev.active_pd = 0;
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
index 00f9af0..15fd4f4 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac.c
@@ -2803,7 +2803,7 @@ static int ieee80211_wpa_set_encryption(struct ieee80211_device *ieee,
 			       param->u.crypt.key_len);
 		return -EINVAL;
 	}
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= WEP_KEYS)
 			return -EINVAL;
 		crypt = &ieee->crypt[param->u.crypt.idx];
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac_wx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac_wx.c
index 1ef8fd6..ad23eb5 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac_wx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_softmac_wx.c
@@ -162,7 +162,7 @@ int ieee80211_wx_set_wap(struct ieee80211_device *ieee,
 	spin_lock_irqsave(&ieee->lock, flags);
 
 	memcpy(ieee->current_network.bssid, temp->sa_data, ETH_ALEN);
-	ieee->wap_set = !is_zero_ether_addr(temp->sa_data);
+	ieee->wap_set = !eth_addr_zero(temp->sa_data);
 	//printk(" %x:%x:%x:%x:%x:%x\n", ieee->current_network.bssid[0],ieee->current_network.bssid[1],ieee->current_network.bssid[2],ieee->current_network.bssid[3],ieee->current_network.bssid[4],ieee->current_network.bssid[5]);
 
 	spin_unlock_irqrestore(&ieee->lock, flags);
diff --git a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
index 89ed86e..b281c8d 100644
--- a/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8187se/ieee80211/ieee80211_tx.c
@@ -413,7 +413,7 @@ int ieee80211_rtl_xmit(struct sk_buff *skb,
 
 		/* Determine fragmentation size based on destination (multicast
 		* and broadcast are not fragmented) */
-		if (is_multicast_ether_addr(header.addr1)) {
+		if (eth_addr_multicast(header.addr1)) {
 			frag_size = MAX_FRAG_THRESHOLD;
 			qos_ctl = QOS_CTL_NOTCONTAIN_ACK;
 		}
diff --git a/drivers/staging/rtl8187se/r8180_core.c b/drivers/staging/rtl8187se/r8180_core.c
index 20e5fb5..b439dd5 100644
--- a/drivers/staging/rtl8187se/r8180_core.c
+++ b/drivers/staging/rtl8187se/r8180_core.c
@@ -2003,7 +2003,7 @@ short rtl8180_tx(struct net_device *dev, u8* txbuf, int len, int priority,
 	}
 
 		memcpy(&dest, frag_hdr->addr1, ETH_ALEN);
-		if (is_multicast_ether_addr(dest)) {
+		if (eth_addr_multicast(dest)) {
 			Duration = 0;
 			RtsDur = 0;
 			bRTSEnable = 0;
diff --git a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
index 81134d3..8da56f4 100644
--- a/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl8192e/rtl_core.c
@@ -2023,9 +2023,9 @@ short rtl8192_tx(struct net_device *dev, struct sk_buff *skb)
 	stype = WLAN_FC_GET_STYPE(fc);
 	pda_addr = header->addr1;
 
-	if (is_broadcast_ether_addr(pda_addr))
+	if (eth_addr_broadcast(pda_addr))
 		broad_addr = true;
-	else if (is_multicast_ether_addr(pda_addr))
+	else if (eth_addr_multicast(pda_addr))
 		multi_addr = true;
 	else
 		uni_addr = true;
@@ -2357,7 +2357,7 @@ static void rtl8192_rx_normal(struct net_device *dev)
 				stats.RxBufShift);
 			skb_trim(skb, skb->len - 4/*sCrcLng*/);
 			rtllib_hdr = (struct rtllib_hdr_1addr *)skb->data;
-			if (!is_multicast_ether_addr(rtllib_hdr->addr1)) {
+			if (!eth_addr_multicast(rtllib_hdr->addr1)) {
 				/* unicast packet */
 				unicast_packet = true;
 			}
diff --git a/drivers/staging/rtl8192e/rtl819x_TSProc.c b/drivers/staging/rtl8192e/rtl819x_TSProc.c
index 658e875..ebd3349 100644
--- a/drivers/staging/rtl8192e/rtl819x_TSProc.c
+++ b/drivers/staging/rtl8192e/rtl819x_TSProc.c
@@ -310,7 +310,7 @@ bool GetTs(struct rtllib_device *ieee, struct ts_common_info **ppTS,
 	   u8 *Addr, u8 TID, enum tr_select TxRxSelect, bool bAddNewTs)
 {
 	u8	UP = 0;
-	if (is_multicast_ether_addr(Addr)) {
+	if (eth_addr_multicast(Addr)) {
 		RTLLIB_DEBUG(RTLLIB_DL_ERR, "ERR! get TS for Broadcast or "
 			     "Multicast\n");
 		return false;
diff --git a/drivers/staging/rtl8192e/rtllib_rx.c b/drivers/staging/rtl8192e/rtllib_rx.c
index 8b8a5c6..8d13ace 100644
--- a/drivers/staging/rtl8192e/rtllib_rx.c
+++ b/drivers/staging/rtl8192e/rtllib_rx.c
@@ -1000,7 +1000,7 @@ static int rtllib_rx_data_filter(struct rtllib_device *ieee, u16 fc,
 			return -1;
 
 		/* {broad,multi}cast packets to our BSS go through */
-		if (is_multicast_ether_addr(dst)) {
+		if (eth_addr_multicast(dst)) {
 			if (memcmp(bssid, ieee->current_network.bssid, ETH_ALEN))
 				return -1;
 		}
@@ -1230,7 +1230,7 @@ static void rtllib_rx_indicate_pkt_legacy(struct rtllib_device *ieee,
 			ieee->stats.rx_packets++;
 			ieee->stats.rx_bytes += sub_skb->len;
 
-			if (is_multicast_ether_addr(dst))
+			if (eth_addr_multicast(dst))
 				ieee->stats.multicast++;
 
 			/* Indicate the packets to upper layer */
@@ -1269,7 +1269,7 @@ static int rtllib_rx_InfraAdhoc(struct rtllib_device *ieee, struct sk_buff *skb,
 	sc = le16_to_cpu(hdr->seq_ctl);
 
 	/*Filter pkt not to me*/
-	multicast = is_multicast_ether_addr(hdr->addr1);
+	multicast = eth_addr_multicast(hdr->addr1);
 	unicast = !multicast;
 	if (unicast && (compare_ether_addr(dev->dev_addr, hdr->addr1) != 0)) {
 		if (ieee->bNetPromiscuousMode)
@@ -1350,7 +1350,7 @@ static int rtllib_rx_InfraAdhoc(struct rtllib_device *ieee, struct sk_buff *skb,
 	/* Get TS for Rx Reorder  */
 	hdr = (struct rtllib_hdr_4addr *) skb->data;
 	if (ieee->current_network.qos_data.active && IsQoSDataFrame(skb->data)
-		&& !is_multicast_ether_addr(hdr->addr1)
+		&& !eth_addr_multicast(hdr->addr1)
 		&& (!bToOtherSTA)) {
 		TID = Frame_QoSTID(skb->data);
 		SeqNum = WLAN_GET_SEQ_SEQ(sc);
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index 4feecec..a8d0931 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -1844,7 +1844,7 @@ static short probe_rq_parse(struct rtllib_device *ieee, struct sk_buff *skb,
 
 	bssid_match =
 	  (memcmp(header->addr3, ieee->current_network.bssid, ETH_ALEN) != 0) &&
-	  (!is_broadcast_ether_addr(header->addr3));
+	  (!eth_addr_broadcast(header->addr3));
 	if (bssid_match)
 		return -1;
 
@@ -3356,7 +3356,7 @@ static int rtllib_wpa_set_encryption(struct rtllib_device *ieee,
 			       param->u.crypt.key_len);
 		return -EINVAL;
 	}
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= NUM_WEP_KEYS)
 			return -EINVAL;
 		crypt = &ieee->crypt_info.crypt[param->u.crypt.idx];
diff --git a/drivers/staging/rtl8192e/rtllib_softmac_wx.c b/drivers/staging/rtl8192e/rtllib_softmac_wx.c
index 740cf85..b870df5 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac_wx.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac_wx.c
@@ -158,7 +158,7 @@ int rtllib_wx_set_wap(struct rtllib_device *ieee,
 		goto out;
 	}
 
-	if (is_zero_ether_addr(temp->sa_data)) {
+	if (eth_addr_zero(temp->sa_data)) {
 		spin_lock_irqsave(&ieee->lock, flags);
 		memcpy(ieee->current_network.bssid, temp->sa_data, ETH_ALEN);
 		ieee->wap_set = 0;
@@ -178,7 +178,7 @@ int rtllib_wx_set_wap(struct rtllib_device *ieee,
 
 	ieee->cannot_notify = false;
 	memcpy(ieee->current_network.bssid, temp->sa_data, ETH_ALEN);
-	ieee->wap_set = !is_zero_ether_addr(temp->sa_data);
+	ieee->wap_set = !eth_addr_zero(temp->sa_data);
 
 	spin_unlock_irqrestore(&ieee->lock, flags);
 
diff --git a/drivers/staging/rtl8192e/rtllib_tx.c b/drivers/staging/rtl8192e/rtllib_tx.c
index 42900ee..a843560 100644
--- a/drivers/staging/rtl8192e/rtllib_tx.c
+++ b/drivers/staging/rtl8192e/rtllib_tx.c
@@ -296,7 +296,7 @@ static void rtllib_tx_query_agg_cap(struct rtllib_device *ieee,
 		return;
 	if (!IsQoSDataFrame(skb->data))
 		return;
-	if (is_multicast_ether_addr(hdr->addr1))
+	if (eth_addr_multicast(hdr->addr1))
 		return;
 
 	if (tcb_desc->bdhcp || ieee->CntAfterLink < 2)
@@ -423,7 +423,7 @@ static void rtllib_query_protectionmode(struct rtllib_device *ieee,
 	if (tcb_desc->bBroadcast || tcb_desc->bMulticast)
 		return;
 
-	if (is_broadcast_ether_addr(skb->data+16))
+	if (eth_addr_broadcast(skb->data+16))
 		return;
 
 	if (ieee->mode < IEEE_N_24G) {
@@ -514,7 +514,7 @@ u16 rtllib_query_seqnum(struct rtllib_device *ieee, struct sk_buff *skb,
 {
 	u16 seqnum = 0;
 
-	if (is_multicast_ether_addr(dst))
+	if (eth_addr_multicast(dst))
 		return 0;
 	if (IsQoSDataFrame(skb->data)) {
 		struct tx_ts_record *pTS = NULL;
@@ -697,7 +697,7 @@ int rtllib_xmit_inter(struct sk_buff *skb, struct net_device *dev)
 			       ETH_ALEN);
 		}
 
-		bIsMulticast = is_multicast_ether_addr(header.addr1);
+		bIsMulticast = eth_addr_multicast(header.addr1);
 
 		header.frame_ctl = cpu_to_le16(fc);
 
@@ -897,9 +897,9 @@ int rtllib_xmit_inter(struct sk_buff *skb, struct net_device *dev)
 			tcb_desc->RATRIndex = 7;
 			tcb_desc->bTxUseDriverAssingedRate = 1;
 		} else {
-			if (is_multicast_ether_addr(header.addr1))
+			if (eth_addr_multicast(header.addr1))
 				tcb_desc->bMulticast = 1;
-			if (is_broadcast_ether_addr(header.addr1))
+			if (eth_addr_broadcast(header.addr1))
 				tcb_desc->bBroadcast = 1;
 			rtllib_txrate_selectmode(ieee, tcb_desc);
 			if (tcb_desc->bMulticast ||  tcb_desc->bBroadcast)
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index e3cf7a4..5b89789 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -1285,7 +1285,7 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 */
 //added by amy for reorder
 	if(ieee->current_network.qos_data.active && IsQoSDataFrame(skb->data)
-		&& !is_multicast_ether_addr(hdr->addr1))
+		&& !eth_addr_multicast(hdr->addr1))
 	{
 		TID = Frame_QoSTID(skb->data);
 		SeqNum = WLAN_GET_SEQ_SEQ(sc);
@@ -1346,7 +1346,7 @@ int ieee80211_rx(struct ieee80211_device *ieee, struct sk_buff *skb,
 
 				stats->rx_packets++;
 				stats->rx_bytes += sub_skb->len;
-				if(is_multicast_ether_addr(dst)) {
+				if(eth_addr_multicast(dst)) {
 					stats->multicast++;
 				}
 
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index 7a07078..7c74ce39 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -2965,7 +2965,7 @@ static int ieee80211_wpa_set_encryption(struct ieee80211_device *ieee,
 			       param->u.crypt.key_len);
 		return -EINVAL;
 	}
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= WEP_KEYS)
 			return -EINVAL;
 		crypt = &ieee->crypt[param->u.crypt.idx];
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac_wx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac_wx.c
index 421da8a..c1f92b8 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac_wx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac_wx.c
@@ -166,7 +166,7 @@ int ieee80211_wx_set_wap(struct ieee80211_device *ieee,
 	spin_lock_irqsave(&ieee->lock, flags);
 
 	memcpy(ieee->current_network.bssid, temp->sa_data, ETH_ALEN);
-	ieee->wap_set = !is_zero_ether_addr(temp->sa_data);
+	ieee->wap_set = !eth_addr_zero(temp->sa_data);
 
 	spin_unlock_irqrestore(&ieee->lock, flags);
 
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
index 3f5ceeb..0c11c99 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_tx.c
@@ -314,7 +314,7 @@ void ieee80211_tx_query_agg_cap(struct ieee80211_device* ieee, struct sk_buff* s
 	if (!IsQoSDataFrame(skb->data))
 		return;
 
-	if (is_multicast_ether_addr(hdr->addr1))
+	if (eth_addr_multicast(hdr->addr1))
 		return;
 	//check packet and mode later
 #ifdef TO_DO_LIST
@@ -444,7 +444,7 @@ void ieee80211_query_protectionmode(struct ieee80211_device* ieee, cb_desc* tcb_
 	if(tcb_desc->bBroadcast || tcb_desc->bMulticast)//only unicast frame will use rts/cts
 		return;
 
-	if (is_broadcast_ether_addr(skb->data+16))  //check addr3 as infrastructure add3 is DA.
+	if (eth_addr_broadcast(skb->data+16))  //check addr3 as infrastructure add3 is DA.
 		return;
 
 	if (ieee->mode < IEEE_N_24G) //b, g mode
@@ -575,7 +575,7 @@ void ieee80211_txrate_selectmode(struct ieee80211_device* ieee, cb_desc* tcb_des
 
 void ieee80211_query_seqnum(struct ieee80211_device*ieee, struct sk_buff* skb, u8* dst)
 {
-	if (is_multicast_ether_addr(dst))
+	if (eth_addr_multicast(dst))
 		return;
 	if (IsQoSDataFrame(skb->data)) //we deal qos data only
 	{
@@ -693,7 +693,7 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 
 		/* Determine fragmentation size based on destination (multicast
 		* and broadcast are not fragmented) */
-		if (is_multicast_ether_addr(header.addr1)) {
+		if (eth_addr_multicast(header.addr1)) {
 			frag_size = MAX_FRAG_THRESHOLD;
 			qos_ctl |= QOS_CTL_NOTCONTAIN_ACK;
 		}
@@ -863,9 +863,9 @@ int ieee80211_xmit(struct sk_buff *skb, struct net_device *dev)
 	{
 		cb_desc *tcb_desc = (cb_desc *)(txb->fragments[0]->cb + MAX_DEV_ADDR_SIZE);
 		tcb_desc->bTxEnableFwCalcDur = 1;
-		if (is_multicast_ether_addr(header.addr1))
+		if (eth_addr_multicast(header.addr1))
 			tcb_desc->bMulticast = 1;
-		if (is_broadcast_ether_addr(header.addr1))
+		if (eth_addr_broadcast(header.addr1))
 			tcb_desc->bBroadcast = 1;
 		ieee80211_txrate_selectmode(ieee, tcb_desc);
 		if ( tcb_desc->bMulticast ||  tcb_desc->bBroadcast)
diff --git a/drivers/staging/rtl8192u/ieee80211/rtl819x_TSProc.c b/drivers/staging/rtl8192u/ieee80211/rtl819x_TSProc.c
index 06a9824..cde11e9 100644
--- a/drivers/staging/rtl8192u/ieee80211/rtl819x_TSProc.c
+++ b/drivers/staging/rtl8192u/ieee80211/rtl819x_TSProc.c
@@ -350,7 +350,7 @@ bool GetTs(
 	// We do not build any TS for Broadcast or Multicast stream.
 	// So reject these kinds of search here.
 	//
-	if (is_multicast_ether_addr(Addr))
+	if (eth_addr_multicast(Addr))
 	{
 		IEEE80211_DEBUG(IEEE80211_DL_ERR, "get TS for Broadcast or Multicast\n");
 		return false;
diff --git a/drivers/staging/rtl8192u/r8192U_core.c b/drivers/staging/rtl8192u/r8192U_core.c
index 5a2fab9..74797dc 100644
--- a/drivers/staging/rtl8192u/r8192U_core.c
+++ b/drivers/staging/rtl8192u/r8192U_core.c
@@ -5475,9 +5475,9 @@ void rtl8192_rx_nomal(struct sk_buff* skb)
 		rx_pkt_len = skb->len;
 		ieee80211_hdr = (struct ieee80211_hdr_1addr *)skb->data;
 		unicast_packet = false;
-		if(is_broadcast_ether_addr(ieee80211_hdr->addr1)) {
+		if(eth_addr_broadcast(ieee80211_hdr->addr1)) {
 			//TODO
-		}else if(is_multicast_ether_addr(ieee80211_hdr->addr1)){
+		}else if(eth_addr_multicast(ieee80211_hdr->addr1)){
 			//TODO
 		}else {
 			/* unicast packet */
@@ -5535,9 +5535,9 @@ void rtl8192_rx_nomal(struct sk_buff* skb)
 				rx_pkt_len = skb->len;
 				ieee80211_hdr = (struct ieee80211_hdr_1addr *)skb->data;
 				unicast_packet = false;
-				if(is_broadcast_ether_addr(ieee80211_hdr->addr1)) {
+				if(eth_addr_broadcast(ieee80211_hdr->addr1)) {
 					//TODO
-				}else if(is_multicast_ether_addr(ieee80211_hdr->addr1)){
+				}else if(eth_addr_multicast(ieee80211_hdr->addr1)){
 					//TODO
 				}else {
 					/* unicast packet */
diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
index c9a6a7f..703e545 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_linux.c
@@ -407,7 +407,7 @@ static int wpa_set_encryption(struct net_device *dev, struct ieee_param *param,
 	if (param_len != (u32)((u8 *) param->u.crypt.key - (u8 *)param) +
 			 param->u.crypt.key_len)
 		return -EINVAL;
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= WEP_KEYS) {
 			/* for large key indices, set the default (0) */
 			param->u.crypt.idx = 0;
diff --git a/drivers/staging/rtl8712/rtl871x_ioctl_set.c b/drivers/staging/rtl8712/rtl871x_ioctl_set.c
index d3ab24e..6a9aab6 100644
--- a/drivers/staging/rtl8712/rtl871x_ioctl_set.c
+++ b/drivers/staging/rtl8712/rtl871x_ioctl_set.c
@@ -131,7 +131,7 @@ u8 r8712_set_802_11_bssid(struct _adapter *padapter, u8 *bssid)
 	u8 status = true;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
-	if (is_zero_ether_addr(bssid) || is_broadcast_ether_addr(bssid)) {
+	if (eth_addr_zero(bssid) || eth_addr_broadcast(bssid)) {
 		status = false;
 		return status;
 	}
diff --git a/drivers/staging/rtl8712/rtl871x_mlme.c b/drivers/staging/rtl8712/rtl871x_mlme.c
index c51ad9e..5c4d550 100644
--- a/drivers/staging/rtl8712/rtl871x_mlme.c
+++ b/drivers/staging/rtl8712/rtl871x_mlme.c
@@ -149,7 +149,7 @@ static struct wlan_network *_r8712_find_network(struct  __queue *scanned_queue,
 	struct list_head *phead, *plist;
 	struct wlan_network *pnetwork = NULL;
 
-	if (is_zero_ether_addr(addr))
+	if (eth_addr_zero(addr))
 		return NULL;
 	spin_lock_irqsave(&scanned_queue->lock, irqL);
 	phead = get_list_head(scanned_queue);
diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
index 23ec684..37702e3 100644
--- a/drivers/staging/rtl8712/rtl871x_recv.c
+++ b/drivers/staging/rtl8712/rtl871x_recv.c
@@ -332,8 +332,8 @@ static sint sta2sta_data_frame(struct _adapter *adapter,
 			return _FAIL;
 		if ((memcmp(myhwaddr, pattrib->dst, ETH_ALEN)) && (!bmcast))
 			return _FAIL;
-		if (is_zero_ether_addr(pattrib->bssid) ||
-		    is_zero_ether_addr(mybssid) ||
+		if (eth_addr_zero(pattrib->bssid) ||
+		    eth_addr_zero(mybssid) ||
 		    (memcmp(pattrib->bssid, mybssid, ETH_ALEN)))
 			return _FAIL;
 		sta_addr = pattrib->src;
@@ -410,8 +410,8 @@ static sint ap2sta_data_frame(struct _adapter *adapter,
 		if ((memcmp(myhwaddr, pattrib->dst, ETH_ALEN)) && (!bmcast))
 			return _FAIL;
 		/* check BSSID */
-		if (is_zero_ether_addr(pattrib->bssid) ||
-		     is_zero_ether_addr(mybssid) ||
+		if (eth_addr_zero(pattrib->bssid) ||
+		     eth_addr_zero(mybssid) ||
 		     (memcmp(pattrib->bssid, mybssid, ETH_ALEN)))
 			return _FAIL;
 		if (bmcast)
diff --git a/drivers/staging/slicoss/slicoss.c b/drivers/staging/slicoss/slicoss.c
index cd920da..4cc972d 100644
--- a/drivers/staging/slicoss/slicoss.c
+++ b/drivers/staging/slicoss/slicoss.c
@@ -918,7 +918,7 @@ static int slic_mac_set_address(struct net_device *dev, void *ptr)
 	if (!adapter)
 		return -EBUSY;
 
-	if (!is_valid_ether_addr(addr->sa_data))
+	if (!eth_addr_valid(addr->sa_data))
 		return -EINVAL;
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
diff --git a/drivers/staging/vt6655/bssdb.c b/drivers/staging/vt6655/bssdb.c
index fe57fb8..4e44851 100644
--- a/drivers/staging/vt6655/bssdb.c
+++ b/drivers/staging/vt6655/bssdb.c
@@ -143,7 +143,7 @@ BSSpSearchBSSList(
     if (pbyDesireBSSID != NULL) {
 		DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO
 			"BSSpSearchBSSList BSSID[%pM]\n", pbyDesireBSSID);
-        if ((!is_broadcast_ether_addr(pbyDesireBSSID)) &&
+        if ((!eth_addr_broadcast(pbyDesireBSSID)) &&
 	     (memcmp(pbyDesireBSSID, ZeroBSSID, 6)!= 0)){
             pbyBSSID = pbyDesireBSSID;
         }
diff --git a/drivers/staging/vt6655/card.c b/drivers/staging/vt6655/card.c
index 319ca48..12b31ce 100644
--- a/drivers/staging/vt6655/card.c
+++ b/drivers/staging/vt6655/card.c
@@ -835,7 +835,7 @@ bool CARDbSetBSSID(void *pDeviceHandler, unsigned char *pbyBSSID, CARD_OP_MODE e
         pDevice->byRxMode &= ~RCR_BSSID;
         DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO "wcmd: rx_mode = %x\n", pDevice->byRxMode );
     } else {
-        if (is_zero_ether_addr(pDevice->abyBSSID) == false) {
+        if (eth_addr_zero(pDevice->abyBSSID) == false) {
             MACvRegBitsOn(pDevice->PortOffset, MAC_REG_RCR, RCR_BSSID);
             pDevice->bBSSIDFilter = true;
             pDevice->byRxMode |= RCR_BSSID;
diff --git a/drivers/staging/vt6655/device_main.c b/drivers/staging/vt6655/device_main.c
index 9e3b3f2b..b47d31a 100644
--- a/drivers/staging/vt6655/device_main.c
+++ b/drivers/staging/vt6655/device_main.c
@@ -2275,7 +2275,7 @@ static int  device_xmit(struct sk_buff *skb, struct net_device *dev) {
             spin_unlock_irq(&pDevice->lock);
             return 0;
         }
-        if (is_multicast_ether_addr((unsigned char *)(skb->data))) {
+        if (eth_addr_multicast((unsigned char *)(skb->data))) {
             uNodeIndex = 0;
             bNodeExist = true;
             if (pMgmt->sNodeDBTable[0].bPSEnable) {
diff --git a/drivers/staging/vt6655/dpc.c b/drivers/staging/vt6655/dpc.c
index 373e9e4..de96dfa 100644
--- a/drivers/staging/vt6655/dpc.c
+++ b/drivers/staging/vt6655/dpc.c
@@ -442,7 +442,7 @@ device_receive_frame (
         return false;
     }
 
-    if (!is_multicast_ether_addr(pbyFrame)) {
+    if (!eth_addr_multicast(pbyFrame)) {
         if (WCTLbIsDuplicate(&(pDevice->sDupRxCache), (PS802_11Header) (skb->data + 4))) {
             pDevice->s802_11Counter.FrameDuplicateCount++;
             return false;
@@ -1421,7 +1421,7 @@ static bool s_bAPModeRxData (
     if (FrameSize > CB_MAX_BUF_SIZE)
         return false;
     // check DA
-    if(is_multicast_ether_addr((unsigned char *)(skb->data+cbHeaderOffset))) {
+    if(eth_addr_multicast((unsigned char *)(skb->data+cbHeaderOffset))) {
        if (pMgmt->sNodeDBTable[0].bPSEnable) {
 
            skbcpy = dev_alloc_skb((int)pDevice->rx_buf_sz);
diff --git a/drivers/staging/vt6655/hostap.c b/drivers/staging/vt6655/hostap.c
index 67b1b88..5076547 100644
--- a/drivers/staging/vt6655/hostap.c
+++ b/drivers/staging/vt6655/hostap.c
@@ -495,7 +495,7 @@ static int hostap_set_encryption(PSDevice pDevice,
 		return -EINVAL;
 	}
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= MAX_GROUP_KEY)
 			return -EINVAL;
         iNodeIndex = 0;
@@ -714,7 +714,7 @@ static int hostap_get_encryption(PSDevice pDevice,
 
 	param->u.crypt.err = 0;
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
         iNodeIndex = 0;
 	} else {
 	    if (BSSDBbIsSTAInNodeDB(pMgmt, param->sta_addr, &iNodeIndex) == false) {
diff --git a/drivers/staging/vt6655/iwctl.c b/drivers/staging/vt6655/iwctl.c
index 5cdda8d..94d96bd 100644
--- a/drivers/staging/vt6655/iwctl.c
+++ b/drivers/staging/vt6655/iwctl.c
@@ -676,7 +676,7 @@ if (pMgmt->eScanState ==  WMAC_IS_SCANNING) {
 			return rc;
 			}
 	//mike :add
-	 if ((is_broadcast_ether_addr(pMgmt->abyDesireBSSID)) ||
+	 if ((eth_addr_broadcast(pMgmt->abyDesireBSSID)) ||
 	     (memcmp(pMgmt->abyDesireBSSID, ZeroBSSID, 6) == 0)){
 	      PRINT_K("SIOCSIWAP:invalid desired BSSID return!\n");
                return rc;
diff --git a/drivers/staging/vt6655/key.c b/drivers/staging/vt6655/key.c
index 194fedc..03affe48 100644
--- a/drivers/staging/vt6655/key.c
+++ b/drivers/staging/vt6655/key.c
@@ -371,7 +371,7 @@ bool KeybRemoveKey (
 {
     int  i;
 
-    if (is_broadcast_ether_addr(pbyBSSID)) {
+    if (eth_addr_broadcast(pbyBSSID)) {
         // delete all keys
         if ((dwKeyIndex & PAIRWISE_KEY) != 0) {
             for (i=0;i<MAX_KEY_TABLE;i++) {
diff --git a/drivers/staging/vt6655/mib.c b/drivers/staging/vt6655/mib.c
index 63ae4ad..28157f6 100644
--- a/drivers/staging/vt6655/mib.c
+++ b/drivers/staging/vt6655/mib.c
@@ -471,11 +471,11 @@ STAvUpdateTDStatCounter (
         pStatistic->CustomStat.ullTsrAllOK =
             (pStatistic->ullTsrOK[TYPE_AC0DMA] + pStatistic->ullTsrOK[TYPE_TXDMA0]);
         // update counters in case that successful transmit
-        if (is_broadcast_ether_addr(pbyDestAddr)) {
+        if (eth_addr_broadcast(pbyDestAddr)) {
             pStatistic->ullTxBroadcastFrames[uIdx]++;
             pStatistic->ullTxBroadcastBytes[uIdx] += (unsigned long long) cbFrameLength;
         }
-        else if (is_multicast_ether_addr(pbyDestAddr)) {
+        else if (eth_addr_multicast(pbyDestAddr)) {
             pStatistic->ullTxMulticastFrames[uIdx]++;
             pStatistic->ullTxMulticastBytes[uIdx] += (unsigned long long) cbFrameLength;
         }
@@ -495,9 +495,9 @@ STAvUpdateTDStatCounter (
             pStatistic->dwTsrACKData[uIdx]++;
     }
 
-    if (is_broadcast_ether_addr(pbyDestAddr))
+    if (eth_addr_broadcast(pbyDestAddr))
         pStatistic->dwTsrBroadcast[uIdx]++;
-    else if (is_multicast_ether_addr(pbyDestAddr))
+    else if (eth_addr_multicast(pbyDestAddr))
         pStatistic->dwTsrMulticast[uIdx]++;
     else
         pStatistic->dwTsrDirected[uIdx]++;
diff --git a/drivers/staging/vt6655/rxtx.c b/drivers/staging/vt6655/rxtx.c
index 4972e57..5189415 100644
--- a/drivers/staging/vt6655/rxtx.c
+++ b/drivers/staging/vt6655/rxtx.c
@@ -1372,7 +1372,7 @@ s_cbFillTxBufHead(PSDevice pDevice, unsigned char byPktType, unsigned char *pbyT
     if ((pDevice->eOPMode == OP_MODE_ADHOC) ||
         (pDevice->eOPMode == OP_MODE_AP)) {
 
-	if (is_multicast_ether_addr(&(psEthHeader->abyDstAddr[0])))
+	if (eth_addr_multicast(&(psEthHeader->abyDstAddr[0])))
 		bNeedACK = false;
         else
             bNeedACK = true;
@@ -2088,7 +2088,7 @@ vGenerateFIFOHeader(PSDevice pDevice, unsigned char byPktType, unsigned char *pb
 
     if ((pDevice->eOPMode == OP_MODE_ADHOC) ||
         (pDevice->eOPMode == OP_MODE_AP)) {
-        if (is_multicast_ether_addr(&(psEthHeader->abyDstAddr[0]))) {
+        if (eth_addr_multicast(&(psEthHeader->abyDstAddr[0]))) {
             bNeedACK = false;
             pTxBufHead->wFIFOCtl = pTxBufHead->wFIFOCtl & (~FIFOCTL_NEEDACK);
         }
@@ -2388,7 +2388,7 @@ CMD_STATUS csMgmt_xmit(PSDevice pDevice, PSTxMgmtPacket pPacket) {
     pTxBufHead->wTimeStamp = cpu_to_le16(DEFAULT_MGN_LIFETIME_RES_64us);
 
 
-    if (is_multicast_ether_addr(&(pPacket->p80211Header->sA3.abyAddr1[0])))
+    if (eth_addr_multicast(&(pPacket->p80211Header->sA3.abyAddr1[0])))
         bNeedACK = false;
     else {
         bNeedACK = true;
@@ -2722,7 +2722,7 @@ cbGetFragCount (
 
     if ((pDevice->eOPMode == OP_MODE_ADHOC) ||
         (pDevice->eOPMode == OP_MODE_AP)) {
-        if (is_multicast_ether_addr(&(psEthHeader->abyDstAddr[0])))
+        if (eth_addr_multicast(&(psEthHeader->abyDstAddr[0])))
             bNeedACK = false;
         else
             bNeedACK = true;
@@ -2897,7 +2897,7 @@ vDMA0_tx_80211(PSDevice  pDevice, struct sk_buff *skb, unsigned char *pbMPDU, un
     pTxBufHead->wTimeStamp = cpu_to_le16(DEFAULT_MGN_LIFETIME_RES_64us);
 
 
-    if (is_multicast_ether_addr(&(p80211Header->sA3.abyAddr1[0]))) {
+    if (eth_addr_multicast(&(p80211Header->sA3.abyAddr1[0]))) {
         bNeedACK = false;
         if (pDevice->bEnableHostWEP) {
             uNodeIndex = 0;
diff --git a/drivers/staging/vt6655/wpactl.c b/drivers/staging/vt6655/wpactl.c
index 2b6ae1e..e7a00f2 100644
--- a/drivers/staging/vt6655/wpactl.c
+++ b/drivers/staging/vt6655/wpactl.c
@@ -353,8 +353,8 @@ spin_lock_irq(&pDevice->lock);
     }
 
    // spin_lock_irq(&pDevice->lock);
-    if (is_broadcast_ether_addr(&param->addr[0]) || (param->addr == NULL)) {
-        // If is_broadcast_ether_addr, set the key as every key entry's group key.
+    if (eth_addr_broadcast(&param->addr[0]) || (param->addr == NULL)) {
+        // If eth_addr_broadcast, set the key as every key entry's group key.
         DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO "Groupe Key Assign.\n");
 
         if ((KeybSetAllGroupKey(&(pDevice->sKey),
diff --git a/drivers/staging/vt6656/bssdb.c b/drivers/staging/vt6656/bssdb.c
index 2ac066d..db8d7ed 100644
--- a/drivers/staging/vt6656/bssdb.c
+++ b/drivers/staging/vt6656/bssdb.c
@@ -131,7 +131,7 @@ PKnownBSS BSSpSearchBSSList(void *hDeviceContext,
     if (pbyDesireBSSID != NULL) {
 		DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO
 			"BSSpSearchBSSList BSSID[%pM]\n", pbyDesireBSSID);
-	if ((!is_broadcast_ether_addr(pbyDesireBSSID)) &&
+	if ((!eth_addr_broadcast(pbyDesireBSSID)) &&
 	     (memcmp(pbyDesireBSSID, ZeroBSSID, 6)!= 0)){
             pbyBSSID = pbyDesireBSSID;
         }
diff --git a/drivers/staging/vt6656/dpc.c b/drivers/staging/vt6656/dpc.c
index 28edf9e..cea9fbf 100644
--- a/drivers/staging/vt6656/dpc.c
+++ b/drivers/staging/vt6656/dpc.c
@@ -452,7 +452,7 @@ RXbBulkInProcessData (
        }
     }
 
-    if (!is_multicast_ether_addr(pMACHeader->abyAddr1)) {
+    if (!eth_addr_multicast(pMACHeader->abyAddr1)) {
         if ( WCTLbIsDuplicate(&(pDevice->sDupRxCache), (PS802_11Header) pbyFrame) ) {
             pDevice->s802_11Counter.FrameDuplicateCount++;
             return FALSE;
@@ -1424,7 +1424,7 @@ static BOOL s_bAPModeRxData (
     if (FrameSize > CB_MAX_BUF_SIZE)
         return FALSE;
     // check DA
-    if (is_multicast_ether_addr((PBYTE)(skb->data+cbHeaderOffset))) {
+    if (eth_addr_multicast((PBYTE)(skb->data+cbHeaderOffset))) {
        if (pMgmt->sNodeDBTable[0].bPSEnable) {
 
            skbcpy = dev_alloc_skb((int)pDevice->rx_buf_sz);
diff --git a/drivers/staging/vt6656/hostap.c b/drivers/staging/vt6656/hostap.c
index 0a73d40..f5fa4ba 100644
--- a/drivers/staging/vt6656/hostap.c
+++ b/drivers/staging/vt6656/hostap.c
@@ -439,7 +439,7 @@ static int hostap_set_encryption(PSDevice pDevice,
 		return -EINVAL;
 	}
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
 		if (param->u.crypt.idx >= MAX_GROUP_KEY)
 			return -EINVAL;
         iNodeIndex = 0;
@@ -661,7 +661,7 @@ static int hostap_get_encryption(PSDevice pDevice,
 
 	param->u.crypt.err = 0;
 
-	if (is_broadcast_ether_addr(param->sta_addr)) {
+	if (eth_addr_broadcast(param->sta_addr)) {
         iNodeIndex = 0;
 	} else {
 	    if (BSSbIsSTAInNodeDB(pDevice, param->sta_addr, &iNodeIndex) == FALSE) {
diff --git a/drivers/staging/vt6656/iwctl.c b/drivers/staging/vt6656/iwctl.c
index 8f19874..43c03e2 100644
--- a/drivers/staging/vt6656/iwctl.c
+++ b/drivers/staging/vt6656/iwctl.c
@@ -582,7 +582,7 @@ int iwctl_siwap(struct net_device *dev, struct iw_request_info *info,
 	} else {
 		memcpy(pMgmt->abyDesireBSSID, wrq->sa_data, 6);
 		// mike: add
-		if ((is_broadcast_ether_addr(pMgmt->abyDesireBSSID)) ||
+		if ((eth_addr_broadcast(pMgmt->abyDesireBSSID)) ||
 			(memcmp(pMgmt->abyDesireBSSID, ZeroBSSID, 6) == 0)) {
 			PRINT_K("SIOCSIWAP:invalid desired BSSID return!\n");
 			return rc;
diff --git a/drivers/staging/vt6656/key.c b/drivers/staging/vt6656/key.c
index a61fcb9..4d2a170 100644
--- a/drivers/staging/vt6656/key.c
+++ b/drivers/staging/vt6656/key.c
@@ -402,7 +402,7 @@ BOOL KeybRemoveKey(
     int     i;
     BOOL    bReturnValue = FALSE;
 
-    if (is_broadcast_ether_addr(pbyBSSID)) {
+    if (eth_addr_broadcast(pbyBSSID)) {
         // delete all keys
         if ((dwKeyIndex & PAIRWISE_KEY) != 0) {
             for (i=0;i<MAX_KEY_TABLE;i++) {
diff --git a/drivers/staging/vt6656/rxtx.c b/drivers/staging/vt6656/rxtx.c
index 3390838..ed2edd2 100644
--- a/drivers/staging/vt6656/rxtx.c
+++ b/drivers/staging/vt6656/rxtx.c
@@ -298,9 +298,9 @@ s_vSaveTxPktInfo(PSDevice pDevice, BYTE byPktNum, PBYTE pbyDestAddr, WORD wPktLe
 {
     PSStatCounter           pStatistic=&(pDevice->scStatistic);
 
-    if (is_broadcast_ether_addr(pbyDestAddr))
+    if (eth_addr_broadcast(pbyDestAddr))
         pStatistic->abyTxPktInfo[byPktNum].byBroadMultiUni = TX_PKT_BROAD;
-    else if (is_multicast_ether_addr(pbyDestAddr))
+    else if (eth_addr_multicast(pbyDestAddr))
         pStatistic->abyTxPktInfo[byPktNum].byBroadMultiUni = TX_PKT_MULTI;
     else
         pStatistic->abyTxPktInfo[byPktNum].byBroadMultiUni = TX_PKT_UNI;
@@ -1484,7 +1484,7 @@ s_bPacketToWirelessUsb(
     } else { //if (pDevice->dwDiagRefCount != 0) {
 	if ((pDevice->eOPMode == OP_MODE_ADHOC) ||
 	    (pDevice->eOPMode == OP_MODE_AP)) {
-		if (is_multicast_ether_addr(psEthHeader->abyDstAddr)) {
+		if (eth_addr_multicast(psEthHeader->abyDstAddr)) {
 			bNeedACK = FALSE;
 			pTxBufHead->wFIFOCtl =
 				pTxBufHead->wFIFOCtl & (~FIFOCTL_NEEDACK);
@@ -2027,7 +2027,7 @@ CMD_STATUS csMgmt_xmit(
     pTxBufHead->wFIFOCtl |= FIFOCTL_TMOEN;
     pTxBufHead->wTimeStamp = cpu_to_le16(DEFAULT_MGN_LIFETIME_RES_64us);
 
-    if (is_multicast_ether_addr(pPacket->p80211Header->sA3.abyAddr1)) {
+    if (eth_addr_multicast(pPacket->p80211Header->sA3.abyAddr1)) {
         bNeedACK = FALSE;
     }
     else {
@@ -2434,7 +2434,7 @@ vDMA0_tx_80211(PSDevice  pDevice, struct sk_buff *skb) {
     pTxBufHead->wFIFOCtl |= FIFOCTL_TMOEN;
     pTxBufHead->wTimeStamp = cpu_to_le16(DEFAULT_MGN_LIFETIME_RES_64us);
 
-    if (is_multicast_ether_addr(p80211Header->sA3.abyAddr1)) {
+    if (eth_addr_multicast(p80211Header->sA3.abyAddr1)) {
         bNeedACK = FALSE;
         if (pDevice->bEnableHostWEP) {
             uNodeIndex = 0;
@@ -2759,7 +2759,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
             return 0;
         }
 
-	if (is_multicast_ether_addr((PBYTE)(skb->data))) {
+	if (eth_addr_multicast((PBYTE)(skb->data))) {
             uNodeIndex = 0;
             bNodeExist = TRUE;
             if (pMgmt->sNodeDBTable[0].bPSEnable) {
@@ -2952,7 +2952,7 @@ int nsDMA_tx_packet(PSDevice pDevice, unsigned int uDMAIdx, struct sk_buff *skb)
     else {
         if (pDevice->eOPMode == OP_MODE_ADHOC) {
             // Adhoc Tx rate decided from node DB
-	    if (is_multicast_ether_addr(pDevice->sTxEthHeader.abyDstAddr)) {
+	    if (eth_addr_multicast(pDevice->sTxEthHeader.abyDstAddr)) {
                 // Multicast use highest data rate
                 pDevice->wCurrentRate = pMgmt->sNodeDBTable[0].wTxDataRate;
                 // preamble type
diff --git a/drivers/staging/vt6656/wpactl.c b/drivers/staging/vt6656/wpactl.c
index 3e65aa1..534a7c8 100644
--- a/drivers/staging/vt6656/wpactl.c
+++ b/drivers/staging/vt6656/wpactl.c
@@ -337,7 +337,7 @@ int wpa_set_wpadev(PSDevice pDevice, int val)
 		return -EINVAL;
 	}
 
-	if (is_broadcast_ether_addr(&param->addr[0]) || (param->addr == NULL)) {
+	if (eth_addr_broadcast(&param->addr[0]) || (param->addr == NULL)) {
 		/* if broadcast, set the key as every key entry's group key */
 		DBG_PRT(MSG_LEVEL_DEBUG, KERN_INFO "Groupe Key Assign.\n");
 
diff --git a/drivers/staging/wlags49_h2/wl_wext.c b/drivers/staging/wlags49_h2/wl_wext.c
index f553366..8263409 100644
--- a/drivers/staging/wlags49_h2/wl_wext.c
+++ b/drivers/staging/wlags49_h2/wl_wext.c
@@ -174,7 +174,7 @@ static int hermes_clear_tkip_keys(ltv_t *ltv, u16 key_idx, u8 *addr)
 
 	switch (key_idx) {
 	case 0:
-		if (!is_broadcast_ether_addr(addr)) {
+		if (!eth_addr_broadcast(addr)) {
 			ltv->len = 7;
 			ltv->typ = CFG_REMOVE_TKIP_MAPPED_KEY;
 			memcpy(&ltv->u.u8[0], addr, ETH_ALEN);
-- 
1.7.8.111.gad25c.dirty
