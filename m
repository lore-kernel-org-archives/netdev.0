From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 4/5] d80211: Switch d80211 to IEEE80211_ style names
Date: Tue,  1 Aug 2006 21:16:59 +0200 (CEST)
Message-ID: <20060801191659.59FED483A8@silver.suse.cz>
References: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50392 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751820AbWHATQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Wu <flamingice@sourmilk.net>

This patch switches the WLAN_ definitions in d80211.h to IEEE80211_ style
definitions found in ieee80211.h. It also switches to MAC_ARG and MAC_FMT.

Signed-off-by: Michael Wu <flamingice@sourmilk.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 include/net/d80211.h         |  125 +++++++++--------
 net/d80211/ieee80211.c       |  317 +++++++++++++++++++++---------------------
 net/d80211/ieee80211_i.h     |    3 
 net/d80211/ieee80211_ioctl.c |   16 +-
 net/d80211/ieee80211_scan.c  |    2 
 net/d80211/ieee80211_sta.c   |  217 ++++++++++++++---------------
 net/d80211/ieee80211_sysfs.c |    2 
 net/d80211/rate_control.c    |   10 +
 net/d80211/sta_info.c        |   16 +-
 net/d80211/tkip.c            |    8 +
 net/d80211/wep.c             |    8 +
 net/d80211/wme.c             |    8 +
 net/d80211/wpa.c             |   72 +++++-----
 13 files changed, 408 insertions(+), 396 deletions(-)

6884184d15ad8a0c5f4255e1219c170655a9610d
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 3a8f6d5..ba5cb4c 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -898,67 +898,73 @@ void ieee80211_rx_led(int state, struct 
 
 #define FCS_LEN 4
 
-#define WLAN_FC_PVER		0x0003
-#define WLAN_FC_TODS		0x0100
-#define WLAN_FC_FROMDS		0x0200
-#define WLAN_FC_MOREFRAG	0x0400
-#define WLAN_FC_RETRY		0x0800
-#define WLAN_FC_PWRMGT		0x1000
-#define WLAN_FC_MOREDATA	0x2000
-#define WLAN_FC_ISWEP		0x4000
-#define WLAN_FC_ORDER		0x8000
-
-#define WLAN_FC_GET_TYPE(fc)	(((fc) & 0x000c) >> 2)
-#define WLAN_FC_GET_STYPE(fc)	(((fc) & 0x00f0) >> 4)
-
-#define WLAN_GET_SEQ_FRAG(seq)	((seq) & 0x000f)
-#define WLAN_GET_SEQ_SEQ(seq)	((seq) >> 4)
-
-#define WLAN_FC_DATA_PRESENT(fc) (((fc) & 0x4c) == 0x08)
-
-#define WLAN_FC_TYPE_MGMT	0
-#define WLAN_FC_TYPE_CTRL	1
-#define WLAN_FC_TYPE_DATA	2
+#define IEEE80211_DATA_LEN              2304
+/* Maximum size for the MA-UNITDATA primitive, 802.11 standard section
+   6.2.1.1.2.
+
+   The figure in section 7.1.2 suggests a body size of up to 2312
+   bytes is allowed, which is a bit confusing, I suspect this
+   represents the 2304 bytes of real data, plus a possible 8 bytes of
+   WEP IV and ICV. (this interpretation suggested by Ramiro Barreiro) */
+
+#define IEEE80211_FCTL_VERS		0x0003
+#define IEEE80211_FCTL_FTYPE		0x000c
+#define IEEE80211_FCTL_STYPE		0x00f0
+#define IEEE80211_FCTL_TODS		0x0100
+#define IEEE80211_FCTL_FROMDS		0x0200
+#define IEEE80211_FCTL_MOREFRAGS	0x0400
+#define IEEE80211_FCTL_RETRY		0x0800
+#define IEEE80211_FCTL_PM		0x1000
+#define IEEE80211_FCTL_MOREDATA		0x2000
+#define IEEE80211_FCTL_PROTECTED	0x4000
+#define IEEE80211_FCTL_ORDER		0x8000
+
+#define IEEE80211_SCTL_FRAG		0x000F
+#define IEEE80211_SCTL_SEQ		0xFFF0
+
+#define IEEE80211_FTYPE_MGMT		0x0000
+#define IEEE80211_FTYPE_CTL		0x0004
+#define IEEE80211_FTYPE_DATA		0x0008
 
 /* management */
-#define WLAN_FC_STYPE_ASSOC_REQ		0
-#define WLAN_FC_STYPE_ASSOC_RESP	1
-#define WLAN_FC_STYPE_REASSOC_REQ	2
-#define WLAN_FC_STYPE_REASSOC_RESP	3
-#define WLAN_FC_STYPE_PROBE_REQ		4
-#define WLAN_FC_STYPE_PROBE_RESP	5
-#define WLAN_FC_STYPE_BEACON		8
-#define WLAN_FC_STYPE_ATIM		9
-#define WLAN_FC_STYPE_DISASSOC		10
-#define WLAN_FC_STYPE_AUTH		11
-#define WLAN_FC_STYPE_DEAUTH		12
-#define WLAN_FC_STYPE_ACTION		13
+#define IEEE80211_STYPE_ASSOC_REQ	0x0000
+#define IEEE80211_STYPE_ASSOC_RESP	0x0010
+#define IEEE80211_STYPE_REASSOC_REQ	0x0020
+#define IEEE80211_STYPE_REASSOC_RESP	0x0030
+#define IEEE80211_STYPE_PROBE_REQ	0x0040
+#define IEEE80211_STYPE_PROBE_RESP	0x0050
+#define IEEE80211_STYPE_BEACON		0x0080
+#define IEEE80211_STYPE_ATIM		0x0090
+#define IEEE80211_STYPE_DISASSOC	0x00A0
+#define IEEE80211_STYPE_AUTH		0x00B0
+#define IEEE80211_STYPE_DEAUTH		0x00C0
+#define IEEE80211_STYPE_ACTION		0x00D0
 
 /* control */
-#define WLAN_FC_STYPE_PSPOLL		10
-#define WLAN_FC_STYPE_RTS		11
-#define WLAN_FC_STYPE_CTS		12
-#define WLAN_FC_STYPE_ACK		13
-#define WLAN_FC_STYPE_CFEND		14
-#define WLAN_FC_STYPE_CFENDACK		15
+#define IEEE80211_STYPE_PSPOLL		0x00A0
+#define IEEE80211_STYPE_RTS		0x00B0
+#define IEEE80211_STYPE_CTS		0x00C0
+#define IEEE80211_STYPE_ACK		0x00D0
+#define IEEE80211_STYPE_CFEND		0x00E0
+#define IEEE80211_STYPE_CFENDACK	0x00F0
 
 /* data */
-#define WLAN_FC_STYPE_DATA		0
-#define WLAN_FC_STYPE_DATA_CFACK	1
-#define WLAN_FC_STYPE_DATA_CFPOLL	2
-#define WLAN_FC_STYPE_DATA_CFACKPOLL	3
-#define WLAN_FC_STYPE_NULLFUNC		4
-#define WLAN_FC_STYPE_CFACK		5
-#define WLAN_FC_STYPE_CFPOLL		6
-#define WLAN_FC_STYPE_CFACKPOLL		7
-#define WLAN_FC_STYPE_QOS_DATA		8
-#define WLAN_FC_STYPE_QOS_DATA_CFACK	9
-#define WLAN_FC_STYPE_QOS_DATA_CFPOLL	10
-#define WLAN_FC_STYPE_QOS_DATA_CFACKPOLL 11
-#define WLAN_FC_STYPE_QOS_NULLFUNC	12
-#define WLAN_FC_STYPE_QOS_CFACK		13
-#define WLAN_FC_STYPE_QOS_CFPOLL	14
-#define WLAN_FC_STYPE_QOS_CFACKPOLL	15
+#define IEEE80211_STYPE_DATA			0x0000
+#define IEEE80211_STYPE_DATA_CFACK		0x0010
+#define IEEE80211_STYPE_DATA_CFPOLL		0x0020
+#define IEEE80211_STYPE_DATA_CFACKPOLL		0x0030
+#define IEEE80211_STYPE_NULLFUNC		0x0040
+#define IEEE80211_STYPE_CFACK			0x0050
+#define IEEE80211_STYPE_CFPOLL			0x0060
+#define IEEE80211_STYPE_CFACKPOLL		0x0070
+#define IEEE80211_STYPE_QOS_DATA		0x0080
+#define IEEE80211_STYPE_QOS_DATA_CFACK		0x0090
+#define IEEE80211_STYPE_QOS_DATA_CFPOLL		0x00A0
+#define IEEE80211_STYPE_QOS_DATA_CFACKPOLL	0x00B0
+#define IEEE80211_STYPE_QOS_NULLFUNC		0x00C0
+#define IEEE80211_STYPE_QOS_CFACK		0x00D0
+#define IEEE80211_STYPE_QOS_CFPOLL		0x00E0
+#define IEEE80211_STYPE_QOS_CFACKPOLL		0x00F0
 
 
 #define IEEE80211_MAX_FRAG_THRESHOLD 2346
@@ -1002,11 +1008,12 @@ static inline u8 *ieee80211_get_DA(struc
 
 static inline int ieee80211_get_morefrag(struct ieee80211_hdr *hdr)
 {
-	return (le16_to_cpu(hdr->frame_control) & WLAN_FC_MOREFRAG) != 0;
+	return (le16_to_cpu(hdr->frame_control) &
+		IEEE80211_FCTL_MOREFRAGS) != 0;
 }
 
-#define MAC2STR(a) ((a)[0] & 0xff), ((a)[1] & 0xff), ((a)[2] & 0xff), \
-		   ((a)[3] & 0xff), ((a)[4] & 0xff), ((a)[5] & 0xff)
-#define MACSTR "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_FMT "%02x:%02x:%02x:%02x:%02x:%02x"
+#define MAC_ARG(x) ((u8*)(x))[0], ((u8*)(x))[1], ((u8*)(x))[2], \
+		   ((u8*)(x))[3], ((u8*)(x))[4], ((u8*)(x))[5]
 
 #endif /* D80211_H */
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 41c292b..60eca90 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -246,17 +246,17 @@ int ieee80211_get_hdrlen(u16 fc)
 {
 	int hdrlen = 24;
 
-	switch (WLAN_FC_GET_TYPE(fc)) {
-	case WLAN_FC_TYPE_DATA:
-		if ((fc & WLAN_FC_FROMDS) && (fc & WLAN_FC_TODS))
+	switch (fc & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_DATA:
+		if ((fc & IEEE80211_FCTL_FROMDS) && (fc & IEEE80211_FCTL_TODS))
 			hdrlen = 30; /* Addr4 */
-		if (WLAN_FC_GET_STYPE(fc) & 0x08)
+		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_QOS_DATA)
 			hdrlen += 2; /* QoS Control Field */
 		break;
-	case WLAN_FC_TYPE_CTRL:
-		switch (WLAN_FC_GET_STYPE(fc)) {
-		case WLAN_FC_STYPE_CTS:
-		case WLAN_FC_STYPE_ACK:
+	case IEEE80211_FTYPE_CTL:
+		switch (fc & IEEE80211_FCTL_STYPE) {
+		case IEEE80211_STYPE_CTS:
+		case IEEE80211_STYPE_ACK:
 			hdrlen = 10;
 			break;
 		default:
@@ -306,13 +306,13 @@ static void ieee80211_dump_frame(const c
 		printk(" FC=0x%04x DUR=0x%04x",
 		       fc, le16_to_cpu(hdr->duration_id));
 	if (hdrlen >= 10)
-		printk(" A1=" MACSTR, MAC2STR(hdr->addr1));
+		printk(" A1=" MAC_FMT, MAC_ARG(hdr->addr1));
 	if (hdrlen >= 16)
-		printk(" A2=" MACSTR, MAC2STR(hdr->addr2));
+		printk(" A2=" MAC_FMT, MAC_ARG(hdr->addr2));
 	if (hdrlen >= 24)
-		printk(" A3=" MACSTR, MAC2STR(hdr->addr3));
+		printk(" A3=" MAC_FMT, MAC_ARG(hdr->addr3));
 	if (hdrlen >= 30)
-		printk(" A4=" MACSTR, MAC2STR(hdr->addr4));
+		printk(" A4=" MAC_FMT, MAC_ARG(hdr->addr4));
 	printk("\n");
 }
 #else /* IEEE80211_VERBOSE_DEBUG_FRAME_DUMP */
@@ -460,7 +460,7 @@ ieee80211_tx_h_fragment(struct ieee80211
 		goto fail;
 	memset(frags, 0, num_fragm * sizeof(struct sk_buff *));
 
-	hdr->frame_control |= cpu_to_le16(WLAN_FC_MOREFRAG);
+	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREFRAGS);
 	pos = first->data + hdrlen + per_fragm;
 	left = payload_len - per_fragm;
 	for (i = 0; i < num_fragm - 1; i++) {
@@ -487,7 +487,7 @@ #define IEEE80211_ENCRYPT_TAILROOM 12
 		fhdr = (struct ieee80211_hdr *) skb_put(frag, hdrlen);
 		memcpy(fhdr, first->data, hdrlen);
 		if (i == num_fragm - 2)
-			fhdr->frame_control &= cpu_to_le16(~WLAN_FC_MOREFRAG);
+			fhdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREFRAGS);
 		fhdr->seq_ctrl = cpu_to_le16(i + 1);
 		copylen = left > per_fragm ? per_fragm : left;
 		memcpy(skb_put(frag, copylen), pos, copylen);
@@ -536,14 +536,14 @@ void ieee80211_tx_set_iswep(struct ieee8
 {
 	struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) tx->skb->data;
 
-	hdr->frame_control |= cpu_to_le16(WLAN_FC_ISWEP);
+	hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 	if (tx->u.tx.extra_frag) {
 		struct ieee80211_hdr *fhdr;
 		int i;
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			fhdr = (struct ieee80211_hdr *)
 				tx->u.tx.extra_frag[i]->data;
-			fhdr->frame_control |= cpu_to_le16(WLAN_FC_ISWEP);
+			fhdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 		}
 	}
 }
@@ -558,9 +558,9 @@ ieee80211_tx_h_wep_encrypt(struct ieee80
         fc = le16_to_cpu(hdr->frame_control);
 
 	if (!tx->key || tx->key->alg != ALG_WEP ||
-	    (WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_DATA &&
-	     (WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_MGMT ||
-	      WLAN_FC_GET_STYPE(fc) != WLAN_FC_STYPE_AUTH)))
+	    ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA &&
+	     ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
+	      (fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_AUTH)))
 		return TXRX_CONTINUE;
 
 	tx->u.tx.control->iv_len = WEP_IV_LEN;
@@ -676,7 +676,7 @@ static u16 ieee80211_duration(struct iee
 	 *   BSSBasicRateSet
 	 */
 
-	if (WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_CTRL) {
+	if ((tx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) {
 		/* TODO: These control frames are not currently sent by
 		 * 80211.o, but should they be implemented, this function
 		 * needs to be updated to support duration field calculation.
@@ -887,8 +887,8 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	u32 sta_flags;
 
 	if (unlikely(tx->local->sta_scanning != 0) &&
-	    (WLAN_FC_GET_TYPE(tx->fc) != WLAN_FC_TYPE_MGMT ||
-	     WLAN_FC_GET_STYPE(tx->fc) != WLAN_FC_STYPE_PROBE_REQ))
+	    ((tx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
+	     (tx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PROBE_REQ))
 		return TXRX_DROP;
 
 	if (tx->u.tx.ps_buffered)
@@ -899,17 +899,17 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 	if (likely(tx->u.tx.unicast)) {
 		if (unlikely(!(sta_flags & WLAN_STA_ASSOC) &&
 			     tx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
-			     WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA)) {
+			     (tx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 			printk(KERN_DEBUG "%s: dropped data frame to not "
-			       "associated station " MACSTR "\n",
-			       tx->dev->name, MAC2STR(hdr->addr1));
+			       "associated station " MAC_FMT "\n",
+			       tx->dev->name, MAC_ARG(hdr->addr1));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			I802_DEBUG_INC(tx->local->tx_handlers_drop_not_assoc);
 			return TXRX_DROP;
 		}
 	} else {
-		if (unlikely(WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_DATA &&
+		if (unlikely((tx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
 			     tx->local->num_sta == 0 &&
 			     !tx->local->allow_broadcast_always &&
 			     tx->sdata->type != IEEE80211_IF_TYPE_IBSS)) {
@@ -927,9 +927,9 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 #ifdef CONFIG_D80211_DEBUG
 		struct ieee80211_hdr *hdr =
 			(struct ieee80211_hdr *) tx->skb->data;
-		printk(KERN_DEBUG "%s: dropped frame to " MACSTR
+		printk(KERN_DEBUG "%s: dropped frame to " MAC_FMT
 		       " (unauthorized port)\n", tx->dev->name,
-		       MAC2STR(hdr->addr1));
+		       MAC_ARG(hdr->addr1));
 #endif
 		I802_DEBUG_INC(tx->local->tx_handlers_drop_unauth_port);
 		return TXRX_DROP;
@@ -995,7 +995,7 @@ ieee80211_tx_h_multicast_ps_buf(struct i
 	if (tx->local->hw->host_broadcast_ps_buffering &&
 	    tx->sdata->type != IEEE80211_IF_TYPE_WDS &&
 	    tx->sdata->bss && atomic_read(&tx->sdata->bss->num_sta_ps) &&
-	    !(tx->fc & WLAN_FC_ORDER)) {
+	    !(tx->fc & IEEE80211_FCTL_ORDER)) {
 		if (tx->local->total_ps_buffered >= TOTAL_MAX_TX_BUFFER)
 			purge_old_ps_buffers(tx->local);
 		if (skb_queue_len(&tx->sdata->bss->ps_bc_buf) >=
@@ -1022,16 +1022,16 @@ ieee80211_tx_h_unicast_ps_buf(struct iee
 	struct sta_info *sta = tx->sta;
 
 	if (unlikely(!sta ||
-		     (WLAN_FC_GET_TYPE(tx->fc) == WLAN_FC_TYPE_MGMT &&
-		      WLAN_FC_GET_STYPE(tx->fc) == WLAN_FC_STYPE_PROBE_RESP)))
+		     ((tx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+		      (tx->fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)))
 		return TXRX_CONTINUE;
 
 	if (unlikely((sta->flags & WLAN_STA_PS) && !sta->pspoll)) {
 		struct ieee80211_tx_packet_data *pkt_data;
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
-		printk(KERN_DEBUG "STA " MACSTR " aid %d: PS buffer (entries "
+		printk(KERN_DEBUG "STA " MAC_FMT " aid %d: PS buffer (entries "
 		       "before %d)\n",
-		       MAC2STR(sta->addr), sta->aid,
+		       MAC_ARG(sta->addr), sta->aid,
 		       skb_queue_len(&sta->ps_tx_buf));
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 		sta->flags |= WLAN_STA_TIM;
@@ -1040,9 +1040,9 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 		if (skb_queue_len(&sta->ps_tx_buf) >= STA_MAX_TX_BUFFER) {
 			struct sk_buff *old = skb_dequeue(&sta->ps_tx_buf);
 			if (net_ratelimit()) {
-				printk(KERN_DEBUG "%s: STA " MACSTR " TX "
+				printk(KERN_DEBUG "%s: STA " MAC_FMT " TX "
 				       "buffer full - dropping oldest frame\n",
-				       tx->dev->name, MAC2STR(sta->addr));
+				       tx->dev->name, MAC_ARG(sta->addr));
 			}
 			dev_kfree_skb(old);
 		} else
@@ -1057,9 +1057,9 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 	}
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
 	else if (unlikely(sta->flags & WLAN_STA_PS)) {
-		printk(KERN_DEBUG "%s: STA " MACSTR " in PS mode, but pspoll "
+		printk(KERN_DEBUG "%s: STA " MAC_FMT " in PS mode, but pspoll "
 		       "set -> send frame\n", tx->dev->name,
-		       MAC2STR(sta->addr));
+		       MAC_ARG(sta->addr));
 	}
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 	sta->pspoll = 0;
@@ -1479,18 +1479,18 @@ static int ieee80211_subif_start_xmit(st
 	 * operation mode) */
 	ethertype = (skb->data[12] << 8) | skb->data[13];
 	/* TODO: handling for 802.1x authorized/unauthorized port */
-	fc = (WLAN_FC_TYPE_DATA << 2) | (WLAN_FC_STYPE_DATA << 4);
+	fc = IEEE80211_FTYPE_DATA | IEEE80211_STYPE_DATA;
 
 	if (likely(sdata->type == IEEE80211_IF_TYPE_AP ||
 		   sdata->type == IEEE80211_IF_TYPE_VLAN)) {
-		fc |= WLAN_FC_FROMDS;
+		fc |= IEEE80211_FCTL_FROMDS;
 		/* DA BSSID SA */
 		memcpy(hdr.addr1, skb->data, ETH_ALEN);
 		memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
 		memcpy(hdr.addr3, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 24;
         } else if (sdata->type == IEEE80211_IF_TYPE_WDS) {
-                fc |= WLAN_FC_FROMDS | WLAN_FC_TODS;
+		fc |= IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS;
 		/* RA TA DA SA */
                 memcpy(hdr.addr1, sdata->u.wds.remote_addr, ETH_ALEN);
                 memcpy(hdr.addr2, dev->dev_addr, ETH_ALEN);
@@ -1498,7 +1498,7 @@ static int ieee80211_subif_start_xmit(st
                 memcpy(hdr.addr4, skb->data + ETH_ALEN, ETH_ALEN);
                 hdrlen = 30;
         } else if (sdata->type == IEEE80211_IF_TYPE_STA) {
-		fc |= WLAN_FC_TODS;
+		fc |= IEEE80211_FCTL_TODS;
 		/* BSSID SA DA */
 		memcpy(hdr.addr1, sdata->u.sta.bssid, ETH_ALEN);
 		memcpy(hdr.addr2, skb->data + ETH_ALEN, ETH_ALEN);
@@ -1519,7 +1519,7 @@ static int ieee80211_subif_start_xmit(st
 	sta = sta_info_get(local, hdr.addr1);
 	if (sta) {
 		if (sta->flags & WLAN_STA_WME) {
-			fc |= WLAN_FC_STYPE_QOS_DATA << 4;
+			fc |= IEEE80211_STYPE_QOS_DATA << 4;
 			hdrlen += 2;
 		}
 		sta_info_put(sta);
@@ -1654,8 +1654,8 @@ ieee80211_mgmt_start_xmit(struct sk_buff
         pkt_data->ifindex = sdata->dev->ifindex;
 	pkt_data->mgmt_iface = (sdata->type == IEEE80211_IF_TYPE_MGMT);
 
-	if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_MGMT &&
-	    WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_PROBE_RESP)
+	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+	    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP)
 		pkt_data->pkt_probe_resp = 1;
 
 	skb->priority = 20; /* use hardcoded priority for mgmt TX queue */
@@ -1671,7 +1671,7 @@ ieee80211_mgmt_start_xmit(struct sk_buff
 		hdr->frame_control = cpu_to_le16(fc);
 	}
 
-	pkt_data->do_not_encrypt = !(fc & WLAN_FC_ISWEP);
+	pkt_data->do_not_encrypt = !(fc & IEEE80211_FCTL_PROTECTED);
 
 	sdata->stats.tx_packets++;
         sdata->stats.tx_bytes += skb->len;
@@ -1870,7 +1870,7 @@ ieee80211_get_buffered_bc(struct net_dev
 		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 		/* more buffered multicast/broadcast frames ==> set MoreData
 		 * flag in IEEE 802.11 header to inform PS STAs */
-		hdr->frame_control |= cpu_to_le16(WLAN_FC_MOREDATA);
+		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 	}
 
 	ieee80211_tx_prepare(&tx, skb, dev, control);
@@ -1989,7 +1989,7 @@ static int ieee80211_change_mtu(struct n
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.3 frames. */
-	if (new_mtu < 256 || new_mtu > 2304 - 24 - 6) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN - 24 - 6) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;
@@ -2007,7 +2007,7 @@ static int ieee80211_change_mtu_apdev(st
 {
 	/* FIX: what would be proper limits for MTU?
 	 * This interface uses 802.11 frames. */
-	if (new_mtu < 256 || new_mtu > 2304) {
+	if (new_mtu < 256 || new_mtu > IEEE80211_DATA_LEN) {
 		printk(KERN_WARNING "%s: invalid MTU %d\n",
 		       dev->name, new_mtu);
 		return -EINVAL;
@@ -2356,7 +2356,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
         struct ieee80211_sub_if_data *sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	fc = rx->fc;
-	if (unlikely(WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_DATA))
+	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA))
 		return TXRX_CONTINUE;
 
 	if (unlikely(!WLAN_FC_DATA_PRESENT(fc)))
@@ -2374,36 +2374,36 @@ ieee80211_rx_h_data(struct ieee80211_txr
 	 *   1     1   RA    TA    DA    SA
 	 */
 
-	switch (fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) {
-	case WLAN_FC_TODS:
+	switch (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
+	case IEEE80211_FCTL_TODS:
 		/* BSSID SA DA */
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr2, ETH_ALEN);
 
 		if (unlikely(sdata->type != IEEE80211_IF_TYPE_AP)) {
 			printk(KERN_DEBUG "%s: dropped ToDS frame (BSSID="
-			       MACSTR " SA=" MACSTR " DA=" MACSTR ")\n",
-			       dev->name, MAC2STR(hdr->addr1),
-			       MAC2STR(hdr->addr2), MAC2STR(hdr->addr3));
+			       MAC_FMT " SA=" MAC_FMT " DA=" MAC_FMT ")\n",
+			       dev->name, MAC_ARG(hdr->addr1),
+			       MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr3));
 			return TXRX_DROP;
 		}
 		break;
-	case (WLAN_FC_TODS | WLAN_FC_FROMDS):
+	case (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
 		/* RA TA DA SA */
 		memcpy(dst, hdr->addr3, ETH_ALEN);
 		memcpy(src, hdr->addr4, ETH_ALEN);
 
 		if (unlikely(sdata->type != IEEE80211_IF_TYPE_WDS)) {
 			printk(KERN_DEBUG "%s: dropped FromDS&ToDS frame (RA="
-			       MACSTR " TA=" MACSTR " DA=" MACSTR " SA="
-			       MACSTR ")\n",
-			       rx->dev->name, MAC2STR(hdr->addr1),
-			       MAC2STR(hdr->addr2), MAC2STR(hdr->addr3),
-			       MAC2STR(hdr->addr4));
+			       MAC_FMT " TA=" MAC_FMT " DA=" MAC_FMT " SA="
+			       MAC_FMT ")\n",
+			       rx->dev->name, MAC_ARG(hdr->addr1),
+			       MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr3),
+			       MAC_ARG(hdr->addr4));
 			return TXRX_DROP;
 		}
 		break;
-	case WLAN_FC_FROMDS:
+	case IEEE80211_FCTL_FROMDS:
 		/* DA BSSID SA */
 		memcpy(dst, hdr->addr1, ETH_ALEN);
 		memcpy(src, hdr->addr3, ETH_ALEN);
@@ -2420,11 +2420,11 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		if (sdata->type != IEEE80211_IF_TYPE_IBSS) {
 			if (net_ratelimit()) {
 				printk(KERN_DEBUG "%s: dropped IBSS frame (DA="
-				       MACSTR " SA=" MACSTR " BSSID=" MACSTR
+				       MAC_FMT " SA=" MAC_FMT " BSSID=" MAC_FMT
 				       ")\n",
-				       dev->name, MAC2STR(hdr->addr1),
-				       MAC2STR(hdr->addr2),
-				       MAC2STR(hdr->addr3));
+				       dev->name, MAC_ARG(hdr->addr1),
+				       MAC_ARG(hdr->addr2),
+				       MAC_ARG(hdr->addr3));
 			}
 			return TXRX_DROP;
 		}
@@ -2696,8 +2696,8 @@ static void ap_sta_ps_start(struct net_d
 	sta->flags |= WLAN_STA_PS;
 	sta->pspoll = 0;
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
-	printk(KERN_DEBUG "%s: STA " MACSTR " aid %d enters power "
-	       "save mode\n", dev->name, MAC2STR(sta->addr), sta->aid);
+	printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d enters power "
+	       "save mode\n", dev->name, MAC_ARG(sta->addr), sta->aid);
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 }
 
@@ -2718,8 +2718,8 @@ static int ap_sta_ps_end(struct net_devi
 	if (!skb_queue_empty(&sta->ps_tx_buf) && local->hw->set_tim)
 		local->hw->set_tim(dev, sta->aid, 0);
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
-	printk(KERN_DEBUG "%s: STA " MACSTR " aid %d exits power "
-	       "save mode\n", dev->name, MAC2STR(sta->addr), sta->aid);
+	printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d exits power "
+	       "save mode\n", dev->name, MAC_ARG(sta->addr), sta->aid);
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 	/* Send all buffered frames to the station */
 	while ((skb = skb_dequeue(&sta->tx_filtered)) != NULL) {
@@ -2733,9 +2733,9 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 		local->total_ps_buffered--;
 		sent++;
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
-		printk(KERN_DEBUG "%s: STA " MACSTR " aid %d send PS frame "
+		printk(KERN_DEBUG "%s: STA " MAC_FMT " aid %d send PS frame "
 		       "since STA not sleeping anymore\n", dev->name,
-		       MAC2STR(sta->addr), sta->aid);
+		       MAC_ARG(sta->addr), sta->aid);
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 		pkt_data->requeue = 1;
 		dev_queue_xmit(skb);
@@ -2751,8 +2751,9 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 	struct sk_buff *skb;
 	int no_pending_pkts;
 
-	if (likely(!rx->sta || WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_CTRL ||
-		   WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_PSPOLL ||
+	if (likely(!rx->sta ||
+		   (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_CTL ||
+		   (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_PSPOLL ||
 		   !rx->u.rx.ra_match))
 		return TXRX_CONTINUE;
 
@@ -2774,19 +2775,19 @@ ieee80211_rx_h_ps_poll(struct ieee80211_
 		rx->sta->pspoll = 1;
 
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
-		printk(KERN_DEBUG "STA " MACSTR " aid %d: PS Poll (entries "
+		printk(KERN_DEBUG "STA " MAC_FMT " aid %d: PS Poll (entries "
 		       "after %d)\n",
-		       MAC2STR(rx->sta->addr), rx->sta->aid,
+		       MAC_ARG(rx->sta->addr), rx->sta->aid,
 		       skb_queue_len(&rx->sta->ps_tx_buf));
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 
 		/* Use MoreData flag to indicate whether there are more
 		 * buffered frames for this STA */
 		if (no_pending_pkts) {
-			hdr->frame_control &= cpu_to_le16(~WLAN_FC_MOREDATA);
+			hdr->frame_control &= cpu_to_le16(~IEEE80211_FCTL_MOREDATA);
 			rx->sta->flags &= ~WLAN_STA_TIM;
 		} else
-			hdr->frame_control |= cpu_to_le16(WLAN_FC_MOREDATA);
+			hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_MOREDATA);
 
 		dev_queue_xmit(skb);
 
@@ -2794,9 +2795,9 @@ #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 			rx->local->hw->set_tim(rx->dev, rx->sta->aid, 0);
 #ifdef IEEE80211_VERBOSE_DEBUG_PS
 	} else if (!rx->u.rx.sent_ps_buffered) {
-		printk(KERN_DEBUG "%s: STA " MACSTR " sent PS Poll even "
+		printk(KERN_DEBUG "%s: STA " MAC_FMT " sent PS Poll even "
 		       "though there is no buffered frames for it\n",
-		       rx->dev->name, MAC2STR(rx->sta->addr));
+		       rx->dev->name, MAC_ARG(rx->sta->addr));
 #endif /* IEEE80211_VERBOSE_DEBUG_PS */
 
 	}
@@ -2828,11 +2829,11 @@ #ifdef CONFIG_D80211_DEBUG
 			(struct ieee80211_hdr *) entry->skb_list.next->data;
 		printk(KERN_DEBUG "%s: RX reassembly removed oldest "
 		       "fragment entry (idx=%d age=%lu seq=%d last_frag=%d "
-		       "addr1=" MACSTR " addr2=" MACSTR "\n",
+		       "addr1=" MAC_FMT " addr2=" MAC_FMT "\n",
 		       sdata->dev->name, idx,
 		       jiffies - entry->first_frag_time, entry->seq,
-		       entry->last_frag, MAC2STR(hdr->addr1),
-		       MAC2STR(hdr->addr2));
+		       entry->last_frag, MAC_ARG(hdr->addr1),
+		       MAC_ARG(hdr->addr2));
 #endif /* CONFIG_D80211_DEBUG */
 		__skb_queue_purge(&entry->skb_list);
 	}
@@ -2876,7 +2877,7 @@ ieee80211_reassemble_find(struct ieee802
 		f_hdr = (struct ieee80211_hdr *) entry->skb_list.next->data;
 		f_fc = le16_to_cpu(f_hdr->frame_control);
 
-		if (WLAN_FC_GET_TYPE(fc) != WLAN_FC_GET_TYPE(f_fc) ||
+		if ((fc & IEEE80211_FCTL_FTYPE) != (f_fc & IEEE80211_FCTL_FTYPE) ||
 		    memcmp(hdr->addr1, f_hdr->addr1, ETH_ALEN) != 0 ||
 		    memcmp(hdr->addr2, f_hdr->addr2, ETH_ALEN) != 0)
 			continue;
@@ -2903,9 +2904,9 @@ ieee80211_rx_h_defragment(struct ieee802
 
 	hdr = (struct ieee80211_hdr *) rx->skb->data;
 	sc = le16_to_cpu(hdr->seq_ctrl);
-	frag = WLAN_GET_SEQ_FRAG(sc);
+	frag = sc & IEEE80211_SCTL_FRAG;
 
-	if (likely((!(rx->fc & WLAN_FC_MOREFRAG) && frag == 0) ||
+	if (likely((!(rx->fc & IEEE80211_FCTL_MOREFRAGS) && frag == 0) ||
 		   (rx->skb)->len < 24 ||
 		   is_multicast_ether_addr(hdr->addr1))) {
 		/* not fragmented */
@@ -2913,14 +2914,14 @@ ieee80211_rx_h_defragment(struct ieee802
 	}
 	I802_DEBUG_INC(rx->local->rx_handlers_fragments);
 
-	seq = WLAN_GET_SEQ_SEQ(sc);
+	seq = (sc & IEEE80211_SCTL_SEQ) >> 4;
 
 	if (frag == 0) {
 		/* This is the first fragment of a new frame. */
 		entry = ieee80211_reassemble_add(rx->sdata, frag, seq,
 						 rx->u.rx.queue, &(rx->skb));
 		if (rx->key && rx->key->alg == ALG_CCMP &&
-		    (rx->fc & WLAN_FC_ISWEP)) {
+		    (rx->fc & IEEE80211_FCTL_PROTECTED)) {
 			/* Store CCMP PN so that we can verify that the next
 			 * fragment has a sequential PN value. */
 			entry->ccmp = 1;
@@ -2957,9 +2958,9 @@ ieee80211_rx_h_defragment(struct ieee802
 		rpn = rx->key->u.ccmp.rx_pn[rx->u.rx.queue];
 		if (memcmp(pn, rpn, CCMP_PN_LEN) != 0) {
 			printk(KERN_DEBUG "%s: defrag: CCMP PN not sequential"
-			       " A2=" MACSTR " PN=%02x%02x%02x%02x%02x%02x "
+			       " A2=" MAC_FMT " PN=%02x%02x%02x%02x%02x%02x "
 			       "(expected %02x%02x%02x%02x%02x%02x)\n",
-			       rx->dev->name, MAC2STR(hdr->addr2),
+			       rx->dev->name, MAC_ARG(hdr->addr2),
 			       rpn[0], rpn[1], rpn[2], rpn[3], rpn[4], rpn[5],
 			       pn[0], pn[1], pn[2], pn[3], pn[4], pn[5]);
 			return TXRX_DROP;
@@ -2971,7 +2972,7 @@ ieee80211_rx_h_defragment(struct ieee802
 	__skb_queue_tail(&entry->skb_list, rx->skb);
 	entry->last_frag = frag;
 	entry->extra_len += rx->skb->len;
-	if (rx->fc & WLAN_FC_MOREFRAG) {
+	if (rx->fc & IEEE80211_FCTL_MOREFRAGS) {
 		rx->skb = NULL;
 		return TXRX_QUEUED;
 	}
@@ -3027,7 +3028,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 
 	/* Drop duplicate 802.11 retransmissions (IEEE 802.11 Chap. 9.2.9) */
 	if (rx->sta && !is_multicast_ether_addr(hdr->addr1)) {
-		if (unlikely(rx->fc & WLAN_FC_RETRY &&
+		if (unlikely(rx->fc & IEEE80211_FCTL_RETRY &&
 			     rx->sta->last_seq_ctrl[rx->u.rx.queue] ==
 			     hdr->seq_ctrl)) {
 			if (rx->u.rx.ra_match) {
@@ -3067,12 +3068,13 @@ ieee80211_rx_h_check(struct ieee80211_tx
 	 * deauth/disassoc frames when needed. In addition, hostapd is
 	 * responsible for filtering on both auth and assoc states.
 	 */
-	if (unlikely((WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA ||
-		      (WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_CTRL &&
-		       WLAN_FC_GET_STYPE(rx->fc) == WLAN_FC_STYPE_PSPOLL)) &&
+	if (unlikely(((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA ||
+		      ((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL &&
+		       (rx->fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)) &&
 		     rx->sdata->type != IEEE80211_IF_TYPE_IBSS &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_ASSOC)))) {
-		if ((!(rx->fc & WLAN_FC_FROMDS) && !(rx->fc & WLAN_FC_TODS)) ||
+		if ((!(rx->fc & IEEE80211_FCTL_FROMDS) &&
+		     !(rx->fc & IEEE80211_FCTL_TODS)) ||
 		    !rx->u.rx.ra_match) {
 			/* Drop IBSS frames and frames for other hosts
 			 * silently. */
@@ -3098,7 +3100,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 			rx->key = rx->sdata->default_key;
 
 		if (rx->local->hw->wep_include_iv &&
-		    rx->fc & WLAN_FC_ISWEP) {
+		    rx->fc & IEEE80211_FCTL_PROTECTED) {
 			int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 
 			if (keyidx >= 0 && keyidx < NUM_DEFAULT_KEYS &&
@@ -3110,12 +3112,12 @@ ieee80211_rx_h_check(struct ieee80211_tx
 				if (!rx->u.rx.ra_match)
 					return TXRX_DROP;
 				printk(KERN_DEBUG "%s: RX WEP frame with "
-				       "unknown keyidx %d (A1=" MACSTR " A2="
-				       MACSTR " A3=" MACSTR ")\n",
+				       "unknown keyidx %d (A1=" MAC_FMT " A2="
+				       MAC_FMT " A3=" MAC_FMT ")\n",
 				       rx->dev->name, keyidx,
-				       MAC2STR(hdr->addr1),
-				       MAC2STR(hdr->addr2),
-				       MAC2STR(hdr->addr3));
+				       MAC_ARG(hdr->addr1),
+				       MAC_ARG(hdr->addr2),
+				       MAC_ARG(hdr->addr3));
 				ieee80211_rx_mgmt(
 					rx->dev, rx->skb, rx->u.rx.status,
 					ieee80211_msg_wep_frame_unknown_key);
@@ -3124,7 +3126,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		}
         }
 
-	if (rx->fc & WLAN_FC_ISWEP && rx->key && rx->u.rx.ra_match) {
+	if (rx->fc & IEEE80211_FCTL_PROTECTED && rx->key && rx->u.rx.ra_match) {
 		rx->key->tx_rx_count++;
 		if (unlikely(rx->local->key_tx_rx_threshold &&
 			     rx->key->tx_rx_count >
@@ -3172,20 +3174,20 @@ ieee80211_rx_h_sta_process(struct ieee80
 	sta->rx_bytes += rx->skb->len;
 	sta->last_rssi = rx->u.rx.status->ssi;
 
-	if (!(rx->fc & WLAN_FC_MOREFRAG)) {
+	if (!(rx->fc & IEEE80211_FCTL_MOREFRAGS)) {
 		/* Change STA power saving mode only in the end of a frame
 		 * exchange sequence */
-		if ((sta->flags & WLAN_STA_PS) && !(rx->fc & WLAN_FC_PWRMGT))
+		if ((sta->flags & WLAN_STA_PS) && !(rx->fc & IEEE80211_FCTL_PM))
 			rx->u.rx.sent_ps_buffered += ap_sta_ps_end(dev, sta);
 		else if (!(sta->flags & WLAN_STA_PS) &&
-			 (rx->fc & WLAN_FC_PWRMGT))
+			 (rx->fc & IEEE80211_FCTL_PM))
 			ap_sta_ps_start(dev, sta);
 	}
 
 	/* Drop data::nullfunc frames silently, since they are used only to
 	 * control station power saving mode. */
-	if (WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA &&
-	    WLAN_FC_GET_STYPE(rx->fc) == WLAN_FC_STYPE_NULLFUNC) {
+	if ((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
+	    (rx->fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_NULLFUNC) {
 		I802_DEBUG_INC(rx->local->rx_handlers_drop_nullfunc);
 		/* Update counter and free packet here to avoid counting this
 		 * as a dropped packed. */
@@ -3201,9 +3203,9 @@ ieee80211_rx_h_sta_process(struct ieee80
 static ieee80211_txrx_result
 ieee80211_rx_h_wep_weak_iv_detection(struct ieee80211_txrx_data *rx)
 {
-	if (!rx->sta || !(rx->fc & WLAN_FC_ISWEP) ||
-	    WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA || !rx->key ||
-	    rx->key->alg != ALG_WEP || !rx->u.rx.ra_match)
+	if (!rx->sta || !(rx->fc & IEEE80211_FCTL_PROTECTED) ||
+	    (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
+	    !rx->key || rx->key->alg != ALG_WEP || !rx->u.rx.ra_match)
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
@@ -3227,10 +3229,10 @@ ieee80211_rx_h_wep_decrypt(struct ieee80
 		return TXRX_CONTINUE;
 
 	if ((rx->key && rx->key->alg != ALG_WEP) ||
-	    !(rx->fc & WLAN_FC_ISWEP) ||
-	    (WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA &&
-	     (WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_MGMT ||
-	      WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_AUTH)))
+	    !(rx->fc & IEEE80211_FCTL_PROTECTED) ||
+	    ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA &&
+	     ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
+	      (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_AUTH)))
 		return TXRX_CONTINUE;
 
 	if (!rx->key) {
@@ -3269,16 +3271,16 @@ ieee80211_rx_h_802_1x_pae(struct ieee802
 	}
 
 	if (unlikely(rx->sdata->ieee802_1x &&
-		     WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA &&
-		     WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_NULLFUNC &&
+		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
+		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
 		     (!rx->sta || !(rx->sta->flags & WLAN_STA_AUTHORIZED)) &&
 		     !ieee80211_is_eapol(rx->skb))) {
 #ifdef CONFIG_D80211_DEBUG
 		struct ieee80211_hdr *hdr =
 			(struct ieee80211_hdr *) rx->skb->data;
-		printk(KERN_DEBUG "%s: dropped frame from " MACSTR
+		printk(KERN_DEBUG "%s: dropped frame from " MAC_FMT
 		       " (unauthorized port)\n", rx->dev->name,
-		       MAC2STR(hdr->addr2));
+		       MAC_ARG(hdr->addr2));
 #endif /* CONFIG_D80211_DEBUG */
 		return TXRX_DROP;
 	}
@@ -3295,9 +3297,9 @@ ieee80211_rx_h_drop_unencrypted(struct i
 		return TXRX_CONTINUE;
 
 	/* Drop unencrypted frames if key is set. */
-	if (unlikely(!(rx->fc & WLAN_FC_ISWEP) &&
-		     WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA &&
-		     WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_NULLFUNC &&
+	if (unlikely(!(rx->fc & IEEE80211_FCTL_PROTECTED) &&
+		     (rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
+		     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_NULLFUNC &&
 		     (rx->key || rx->sdata->drop_unencrypted) &&
 		     (rx->sdata->eapol == 0 ||
 		      !ieee80211_is_eapol(rx->skb)))) {
@@ -3342,7 +3344,7 @@ ieee80211_rx_h_passive_scan(struct ieee8
 		return TXRX_QUEUED;
 	}
 
-	if (WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_DATA)
+	if ((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA)
 		local->scan.txrx_count++;
         if (unlikely(local->scan.in_scan != 0 &&
 		     rx->u.rx.status->freq == local->scan.freq)) {
@@ -3354,8 +3356,8 @@ ieee80211_rx_h_passive_scan(struct ieee8
                 hdr = (struct ieee80211_hdr *) skb->data;
                 fc = le16_to_cpu(hdr->frame_control);
 
-                if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_MGMT &&
-		    WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_BEACON &&
+		if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT &&
+		    (fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_BEACON &&
 		    rx->dev == local->mdev) {
 			local->scan.rx_beacon++;
 			/* Need to trim FCS here because it is normally
@@ -3392,23 +3394,23 @@ static u8 * ieee80211_get_bssid(struct i
 
 	fc = le16_to_cpu(hdr->frame_control);
 
-	switch (WLAN_FC_GET_TYPE(fc)) {
-	case WLAN_FC_TYPE_DATA:
-		switch (fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) {
-		case WLAN_FC_TODS:
+	switch (fc & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_DATA:
+		switch (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) {
+		case IEEE80211_FCTL_TODS:
 			return hdr->addr1;
-		case (WLAN_FC_TODS | WLAN_FC_FROMDS):
+		case (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS):
 			return NULL;
-		case WLAN_FC_FROMDS:
+		case IEEE80211_FCTL_FROMDS:
 			return hdr->addr2;
 		case 0:
 			return hdr->addr3;
 		}
 		break;
-	case WLAN_FC_TYPE_MGMT:
+	case IEEE80211_FTYPE_MGMT:
 		return hdr->addr3;
-	case WLAN_FC_TYPE_CTRL:
-		if (WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_PSPOLL)
+	case IEEE80211_FTYPE_CTL:
+		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)
 			return hdr->addr1;
 		else
 			return NULL;
@@ -3433,23 +3435,23 @@ static void ieee80211_rx_michael_mic_rep
 	/* TODO: verify that this is not triggered by fragmented
 	 * frames (hw does not verify MIC for them). */
 	printk(KERN_DEBUG "%s: TKIP hwaccel reported Michael MIC "
-	       "failure from " MACSTR " to " MACSTR " keyidx=%d\n",
-	       dev->name, MAC2STR(hdr->addr2), MAC2STR(hdr->addr1), keyidx);
+	       "failure from " MAC_FMT " to " MAC_FMT " keyidx=%d\n",
+	       dev->name, MAC_ARG(hdr->addr2), MAC_ARG(hdr->addr1), keyidx);
 
 	if (sta == NULL) {
 		/* Some hardware versions seem to generate incorrect
 		 * Michael MIC reports; ignore them to avoid triggering
 		 * countermeasures. */
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
-		       "error for unknown address " MACSTR "\n",
-		       dev->name, MAC2STR(hdr->addr2));
+		       "error for unknown address " MAC_FMT "\n",
+		       dev->name, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
-	if (!(rx->fc & WLAN_FC_ISWEP)) {
+	if (!(rx->fc & IEEE80211_FCTL_PROTECTED)) {
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 		       "error for a frame with no ISWEP flag (src "
-		       MACSTR ")\n", dev->name, MAC2STR(hdr->addr2));
+		       MAC_FMT ")\n", dev->name, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3462,19 +3464,19 @@ static void ieee80211_rx_michael_mic_rep
 		 * frames in BSS. */
 		if (keyidx) {
 			printk(KERN_DEBUG "%s: ignored Michael MIC error for "
-			       "a frame with non-zero keyidx (%d) (src " MACSTR
-			       ")\n", dev->name, keyidx, MAC2STR(hdr->addr2));
+			       "a frame with non-zero keyidx (%d) (src " MAC_FMT
+			       ")\n", dev->name, keyidx, MAC_ARG(hdr->addr2));
 			goto ignore;
 		}
 	}
 
-	if (WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA &&
-	    (WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_MGMT ||
-	     WLAN_FC_GET_STYPE(rx->fc) != WLAN_FC_STYPE_AUTH)) {
+	if ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA &&
+	    ((rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_MGMT ||
+	     (rx->fc & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_AUTH)) {
 		printk(KERN_DEBUG "%s: ignored spurious Michael MIC "
 		       "error for a frame that cannot be encrypted "
-		       "(fc=0x%04x) (src " MACSTR ")\n",
-		       dev->name, rx->fc, MAC2STR(hdr->addr2));
+		       "(fc=0x%04x) (src " MAC_FMT ")\n",
+		       dev->name, rx->fc, MAC_ARG(hdr->addr2));
 		goto ignore;
 	}
 
@@ -3486,9 +3488,9 @@ static void ieee80211_rx_michael_mic_rep
 
 		/* TODO: needed parameters: count, key type, TSC */
 		sprintf(buf, "MLME-MICHAELMICFAILURE.indication("
-			"keyid=%d %scast addr=" MACSTR ")",
+			"keyid=%d %scast addr=" MAC_FMT ")",
 			keyidx, hdr->addr1[0] & 0x01 ? "broad" : "uni",
-			MAC2STR(hdr->addr2));
+			MAC_ARG(hdr->addr2));
 		memset(&wrqu, 0, sizeof(wrqu));
 		wrqu.data.length = strlen(buf);
 		wireless_send_event(rx->dev, IWEVCUSTOM, &wrqu, buf);
@@ -3568,8 +3570,8 @@ void __ieee80211_rx(struct net_device *d
 
 	rx.u.rx.status = status;
 	rx.fc = skb->len >= 2 ? le16_to_cpu(hdr->frame_control) : 0;
-	type = WLAN_FC_GET_TYPE(rx.fc);
-	if (type == WLAN_FC_TYPE_DATA || type == WLAN_FC_TYPE_MGMT)
+	type = rx.fc & IEEE80211_FCTL_FTYPE;
+	if (type == IEEE80211_FTYPE_DATA || type == IEEE80211_FTYPE_MGMT)
 		local->dot11ReceivedFragmentCount++;
 	multicast = is_multicast_ether_addr(hdr->addr1);
 
@@ -3662,7 +3664,7 @@ void __ieee80211_rx(struct net_device *d
 				break;
 			case IEEE80211_IF_TYPE_WDS:
 				if (bssid ||
-				    WLAN_FC_GET_TYPE(rx.fc) != WLAN_FC_TYPE_DATA)
+				    (rx.fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA)
 					continue;
 				if (memcmp(sdata->u.wds.remote_addr,
 					   hdr->addr2, ETH_ALEN) != 0)
@@ -4007,7 +4009,7 @@ static void ieee80211_remove_tx_extra(st
 		struct ieee80211_hdr *hdr = (struct ieee80211_hdr *) skb->data;
 		u16 fc = le16_to_cpu(hdr->frame_control);
 		if ((fc & 0x8C) == 0x88) /* QoS Control Field */ {
-			fc &= ~(WLAN_FC_STYPE_QOS_DATA << 4);
+			fc &= ~(IEEE80211_STYPE_QOS_DATA << 4);
 			hdr->frame_control = cpu_to_le16(fc);
 			memmove(skb->data + 2, skb->data, hdrlen - 2);
 			skb_pull(skb, 2);
@@ -4110,8 +4112,8 @@ #endif /* IEEE80211_LEDS */
 	 * are actually fragments, not frames. Update frame counters only for
 	 * the first fragment of the frame. */
 
-	frag = WLAN_GET_SEQ_FRAG(le16_to_cpu(hdr->seq_ctrl));
-	type = WLAN_FC_GET_TYPE(le16_to_cpu(hdr->frame_control));
+	frag = le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG;
+	type = le16_to_cpu(hdr->frame_control) & IEEE80211_FCTL_FTYPE;
 
         if (status->ack) {
 		if (frag == 0) {
@@ -4129,7 +4131,8 @@ #endif /* IEEE80211_LEDS */
 		 * with a multicast address in the address 1 field of type Data
 		 * or Management. */
 		if (!is_multicast_ether_addr(hdr->addr1) ||
-		    type == WLAN_FC_TYPE_DATA || type == WLAN_FC_TYPE_MGMT)
+		    type == IEEE80211_FTYPE_DATA ||
+		    type == IEEE80211_FTYPE_MGMT)
 			local->dot11TransmittedFragmentCount++;
         } else {
 		if (frag == 0)
@@ -4228,8 +4231,8 @@ int ieee80211_if_update_wds(struct net_d
 		sta_info_free(sta, 0);
 	} else {
 		printk(KERN_DEBUG "%s: could not find STA entry for WDS link "
-		       "peer " MACSTR "\n",
-		       dev->name, MAC2STR(sdata->u.wds.remote_addr));
+		       "peer " MAC_FMT "\n",
+		       dev->name, MAC_ARG(sdata->u.wds.remote_addr));
 	}
 
 	/* Update WDS link data */
diff --git a/net/d80211/ieee80211_i.h b/net/d80211/ieee80211_i.h
index 5a2c6e8..7e021ec 100644
--- a/net/d80211/ieee80211_i.h
+++ b/net/d80211/ieee80211_i.h
@@ -30,13 +30,14 @@ #endif /* ETH_P_PAE */
 
 #define IEEE80211_MAX_SSID_LEN 32
 
+#define WLAN_FC_DATA_PRESENT(fc) (((fc) & 0x4c) == 0x08)
+
 struct ieee80211_local;
 
 #define BIT(x) (1 << (x))
 
 #define IEEE80211_ALIGN32_PAD(a) ((4 - ((a) & 3)) & 3)
 
-
 /* Maximum number of broadcast/multicast frames to buffer when some of the
  * associated stations are using power saving. */
 #define AP_MAX_BC_BUFFER 128
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index e43e3b0..dd52555 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -413,14 +413,14 @@ static int ieee80211_ioctl_set_flags_sta
 		    (param->u.set_flags_sta.flags_or & WLAN_STA_AUTHORIZED) &&
 		    local->hw->set_port_auth(local->mdev, sta->addr, 1))
 			printk(KERN_DEBUG "%s: failed to set low-level driver "
-			       "PAE state (authorized) for " MACSTR "\n",
-			       dev->name, MAC2STR(sta->addr));
+			       "PAE state (authorized) for " MAC_FMT "\n",
+			       dev->name, MAC_ARG(sta->addr));
 		if (local->hw->set_port_auth &&
 		    !(param->u.set_flags_sta.flags_and & WLAN_STA_AUTHORIZED)
 		    && local->hw->set_port_auth(local->mdev, sta->addr, 0))
 			printk(KERN_DEBUG "%s: failed to set low-level driver "
-			       "PAE state (unauthorized) for " MACSTR "\n",
-			       dev->name, MAC2STR(sta->addr));
+			       "PAE state (unauthorized) for " MAC_FMT "\n",
+			       dev->name, MAC_ARG(sta->addr));
 		sta_info_put(sta);
 	}
 
@@ -518,8 +518,8 @@ static int ieee80211_set_encryption(stru
 				*err = HOSTAP_CRYPT_ERR_UNKNOWN_ADDR;
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
 			printk(KERN_DEBUG "%s: set_encrypt - unknown addr "
-			       MACSTR "\n",
-			       dev->name, MAC2STR(sta_addr));
+			       MAC_FMT "\n",
+			       dev->name, MAC_ARG(sta_addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 			return -ENOENT;
@@ -1164,8 +1164,8 @@ static int ieee80211_ioctl_set_sta_vlan(
 			dev_get_by_name(param->u.set_sta_vlan.vlan_name);
                 if (new_vlan_dev) {
 #if 0
-                        printk("%s: Station " MACSTR " moved to vlan: %s\n",
-                               dev->name, MAC2STR(param->sta_addr),
+			printk("%s: Station " MAC_FMT " moved to vlan: %s\n",
+			       dev->name, MAC_ARG(param->sta_addr),
                                new_vlan_dev->name);
 #endif
                         sta->dev = new_vlan_dev;
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index 4184abf..445509e 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -319,7 +319,7 @@ void ieee80211_init_scan(struct net_devi
 		return;
 	}
 
-	fc = (WLAN_FC_TYPE_CTRL << 2) | (WLAN_FC_STYPE_CTS << 4);
+	fc = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_CTS;
 	hdr.frame_control = cpu_to_le16(fc);
 	hdr.duration_id =
 		cpu_to_le16(2 * local->hw->channel_change_time +
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index 13dcdae..8caf352 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -56,7 +56,7 @@ #define IEEE80211_IBSS_INACTIVITY_LIMIT 
 #define IEEE80211_IBSS_MAX_STA_ENTRIES 128
 
 
-#define IEEE80211_FC(type, stype) cpu_to_le16((type << 2) | (stype << 4))
+#define IEEE80211_FC(type, stype) cpu_to_le16(type | stype)
 
 #define ERP_INFO_USE_PROTECTION BIT(1)
 
@@ -426,10 +426,10 @@ static void ieee80211_send_auth(struct n
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
 	memset(mgmt, 0, 24 + 6);
-	mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-					   WLAN_FC_STYPE_AUTH);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_AUTH);
 	if (encrypt)
-		mgmt->frame_control |= cpu_to_le16(WLAN_FC_ISWEP);
+		mgmt->frame_control |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
 	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
@@ -449,15 +449,15 @@ static void ieee80211_authenticate(struc
 {
 	ifsta->auth_tries++;
 	if (ifsta->auth_tries > IEEE80211_AUTH_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: authentication with AP " MACSTR
+		printk(KERN_DEBUG "%s: authentication with AP " MAC_FMT
 		       " timed out\n",
-		       dev->name, MAC2STR(ifsta->bssid));
+		       dev->name, MAC_ARG(ifsta->bssid));
 		return;
 	}
 
 	ifsta->state = IEEE80211_AUTHENTICATE;
-	printk(KERN_DEBUG "%s: authenticate with AP " MACSTR "\n",
-	       dev->name, MAC2STR(ifsta->bssid));
+	printk(KERN_DEBUG "%s: authenticate with AP " MAC_FMT "\n",
+	       dev->name, MAC_ARG(ifsta->bssid));
 
 	ieee80211_send_auth(dev, ifsta, 1, NULL, 0, 0);
 
@@ -508,16 +508,16 @@ static void ieee80211_send_assoc(struct 
 
 	if (ifsta->prev_bssid_set) {
 		skb_put(skb, 10);
-		mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-						   WLAN_FC_STYPE_REASSOC_REQ);
+		mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+						   IEEE80211_STYPE_REASSOC_REQ);
 		mgmt->u.reassoc_req.capab_info = cpu_to_le16(capab);
 		mgmt->u.reassoc_req.listen_interval = cpu_to_le16(1);
 		memcpy(mgmt->u.reassoc_req.current_ap, ifsta->prev_bssid,
 		       ETH_ALEN);
 	} else {
 		skb_put(skb, 4);
-		mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-						   WLAN_FC_STYPE_ASSOC_REQ);
+		mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+						   IEEE80211_STYPE_ASSOC_REQ);
 		mgmt->u.assoc_req.capab_info = cpu_to_le16(capab);
 		mgmt->u.assoc_req.listen_interval = cpu_to_le16(1);
 	}
@@ -599,8 +599,8 @@ static void ieee80211_send_deauth(struct
 	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
-	mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-					   WLAN_FC_STYPE_DEAUTH);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_DEAUTH);
 	skb_put(skb, 2);
 	mgmt->u.deauth.reason_code = cpu_to_le16(reason);
 
@@ -626,8 +626,8 @@ static void ieee80211_send_disassoc(stru
 	memcpy(mgmt->da, ifsta->bssid, ETH_ALEN);
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 	memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
-	mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-					   WLAN_FC_STYPE_DISASSOC);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_DISASSOC);
 	skb_put(skb, 2);
 	mgmt->u.disassoc.reason_code = cpu_to_le16(reason);
 
@@ -664,15 +664,15 @@ static void ieee80211_associate(struct n
 {
 	ifsta->assoc_tries++;
 	if (ifsta->assoc_tries > IEEE80211_ASSOC_MAX_TRIES) {
-		printk(KERN_DEBUG "%s: association with AP " MACSTR
+		printk(KERN_DEBUG "%s: association with AP " MAC_FMT
 		       " timed out\n",
-		       dev->name, MAC2STR(ifsta->bssid));
+		       dev->name, MAC_ARG(ifsta->bssid));
 		return;
 	}
 
 	ifsta->state = IEEE80211_ASSOCIATE;
-	printk(KERN_DEBUG "%s: associate with AP " MACSTR "\n",
-	       dev->name, MAC2STR(ifsta->bssid));
+	printk(KERN_DEBUG "%s: associate with AP " MAC_FMT "\n",
+	       dev->name, MAC_ARG(ifsta->bssid));
 	if (ieee80211_privacy_mismatch(dev, ifsta)) {
 		printk(KERN_DEBUG "%s: mismatch in privacy configuration and "
 		       "mixed-cell disabled - abort association\n", dev->name);
@@ -701,8 +701,8 @@ static void ieee80211_associated(struct 
 
 	sta = sta_info_get(local, ifsta->bssid);
 	if (sta == NULL) {
-		printk(KERN_DEBUG "%s: No STA entry for own AP " MACSTR "\n",
-		       dev->name, MAC2STR(ifsta->bssid));
+		printk(KERN_DEBUG "%s: No STA entry for own AP " MAC_FMT "\n",
+		       dev->name, MAC_ARG(ifsta->bssid));
 		disassoc = 1;
 	} else {
 		disassoc = 0;
@@ -710,9 +710,9 @@ static void ieee80211_associated(struct 
 			       sta->last_rx + IEEE80211_MONITORING_INTERVAL)) {
 			if (ifsta->probereq_poll) {
 				printk(KERN_DEBUG "%s: No ProbeResp from "
-				       "current AP " MACSTR " - assume out of "
+				       "current AP " MAC_FMT " - assume out of "
 				       "range\n",
-				       dev->name, MAC2STR(ifsta->bssid));
+				       dev->name, MAC_ARG(ifsta->bssid));
 				disassoc = 1;
 			} else {
 				ieee80211_send_probe_req(dev, ifsta->bssid,
@@ -764,8 +764,8 @@ static void ieee80211_send_probe_req(str
 
 	mgmt = (struct ieee80211_mgmt *) skb_put(skb, 24);
 	memset(mgmt, 0, 24);
-	mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-					   WLAN_FC_STYPE_PROBE_REQ);
+	mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					   IEEE80211_STYPE_PROBE_REQ);
 	memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 	if (dst) {
 		memcpy(mgmt->da, dst, ETH_ALEN);
@@ -866,33 +866,33 @@ static void ieee80211_rx_mgmt_auth(struc
 	if (ifsta->state != IEEE80211_AUTHENTICATE &&
 	    sdata->type != IEEE80211_IF_TYPE_IBSS) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
-		       MACSTR ", but not in authenticate state - ignored\n",
-		       dev->name, MAC2STR(mgmt->sa));
+		       MAC_FMT ", but not in authenticate state - ignored\n",
+		       dev->name, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (len < 24 + 6) {
 		printk(KERN_DEBUG "%s: too short (%zd) authentication frame "
-		       "received from " MACSTR " - ignored\n",
-		       dev->name, len, MAC2STR(mgmt->sa));
+		       "received from " MAC_FMT " - ignored\n",
+		       dev->name, len, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (sdata->type != IEEE80211_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
-		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
-		       "ignored\n", dev->name, MAC2STR(mgmt->sa),
-		       MAC2STR(mgmt->bssid));
+		       "unknown AP (SA=" MAC_FMT " BSSID=" MAC_FMT ") - "
+		       "ignored\n", dev->name, MAC_ARG(mgmt->sa),
+		       MAC_ARG(mgmt->bssid));
 		return;
 	}
 
 	if (sdata->type != IEEE80211_IF_TYPE_IBSS &&
 	    memcmp(ifsta->bssid, mgmt->bssid, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: authentication frame received from "
-		       "unknown BSSID (SA=" MACSTR " BSSID=" MACSTR ") - "
-		       "ignored\n", dev->name, MAC2STR(mgmt->sa),
-		       MAC2STR(mgmt->bssid));
+		       "unknown BSSID (SA=" MAC_FMT " BSSID=" MAC_FMT ") - "
+		       "ignored\n", dev->name, MAC_ARG(mgmt->sa),
+		       MAC_ARG(mgmt->bssid));
 		return;
 	}
 
@@ -900,9 +900,9 @@ static void ieee80211_rx_mgmt_auth(struc
 	auth_transaction = le16_to_cpu(mgmt->u.auth.auth_transaction);
 	status_code = le16_to_cpu(mgmt->u.auth.status_code);
 
-	printk(KERN_DEBUG "%s: RX authentication from " MACSTR " (alg=%d "
+	printk(KERN_DEBUG "%s: RX authentication from " MAC_FMT " (alg=%d "
 	       "transaction=%d status=%d)\n",
-	       dev->name, MAC2STR(mgmt->sa), auth_alg,
+	       dev->name, MAC_ARG(mgmt->sa), auth_alg,
 	       auth_transaction, status_code);
 
 	if (sdata->type == IEEE80211_IF_TYPE_IBSS) {
@@ -994,24 +994,24 @@ static void ieee80211_rx_mgmt_deauth(str
 
 	if (len < 24 + 2) {
 		printk(KERN_DEBUG "%s: too short (%zd) deauthentication frame "
-		       "received from " MACSTR " - ignored\n",
-		       dev->name, len, MAC2STR(mgmt->sa));
+		       "received from " MAC_FMT " - ignored\n",
+		       dev->name, len, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: deauthentication frame received from "
-		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
-		       "ignored\n", dev->name, MAC2STR(mgmt->sa),
-		       MAC2STR(mgmt->bssid));
+		       "unknown AP (SA=" MAC_FMT " BSSID=" MAC_FMT ") - "
+		       "ignored\n", dev->name, MAC_ARG(mgmt->sa),
+		       MAC_ARG(mgmt->bssid));
 		return;
 	}
 
 	reason_code = le16_to_cpu(mgmt->u.deauth.reason_code);
 
-	printk(KERN_DEBUG "%s: RX deauthentication from " MACSTR
+	printk(KERN_DEBUG "%s: RX deauthentication from " MAC_FMT
 	       " (reason=%d)\n",
-	       dev->name, MAC2STR(mgmt->sa), reason_code);
+	       dev->name, MAC_ARG(mgmt->sa), reason_code);
 
 	if (ifsta->authenticated) {
 		printk(KERN_DEBUG "%s: deauthenticated\n", dev->name);
@@ -1040,24 +1040,24 @@ static void ieee80211_rx_mgmt_disassoc(s
 
 	if (len < 24 + 2) {
 		printk(KERN_DEBUG "%s: too short (%zd) disassociation frame "
-		       "received from " MACSTR " - ignored\n",
-		       dev->name, len, MAC2STR(mgmt->sa));
+		       "received from " MAC_FMT " - ignored\n",
+		       dev->name, len, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: disassociation frame received from "
-		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
-		       "ignored\n", dev->name, MAC2STR(mgmt->sa),
-		       MAC2STR(mgmt->bssid));
+		       "unknown AP (SA=" MAC_FMT " BSSID=" MAC_FMT ") - "
+		       "ignored\n", dev->name, MAC_ARG(mgmt->sa),
+		       MAC_ARG(mgmt->bssid));
 		return;
 	}
 
 	reason_code = le16_to_cpu(mgmt->u.disassoc.reason_code);
 
-	printk(KERN_DEBUG "%s: RX disassociation from " MACSTR
+	printk(KERN_DEBUG "%s: RX disassociation from " MAC_FMT
 	       " (reason=%d)\n",
-	       dev->name, MAC2STR(mgmt->sa), reason_code);
+	       dev->name, MAC_ARG(mgmt->sa), reason_code);
 
 	if (ifsta->associated)
 		printk(KERN_DEBUG "%s: disassociated\n", dev->name);
@@ -1092,23 +1092,23 @@ static void ieee80211_rx_mgmt_assoc_resp
 
 	if (ifsta->state != IEEE80211_ASSOCIATE) {
 		printk(KERN_DEBUG "%s: association frame received from "
-		       MACSTR ", but not in associate state - ignored\n",
-		       dev->name, MAC2STR(mgmt->sa));
+		       MAC_FMT ", but not in associate state - ignored\n",
+		       dev->name, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (len < 24 + 6) {
 		printk(KERN_DEBUG "%s: too short (%zd) association frame "
-		       "received from " MACSTR " - ignored\n",
-		       dev->name, len, MAC2STR(mgmt->sa));
+		       "received from " MAC_FMT " - ignored\n",
+		       dev->name, len, MAC_ARG(mgmt->sa));
 		return;
 	}
 
 	if (memcmp(ifsta->bssid, mgmt->sa, ETH_ALEN) != 0) {
 		printk(KERN_DEBUG "%s: association frame received from "
-		       "unknown AP (SA=" MACSTR " BSSID=" MACSTR ") - "
-		       "ignored\n", dev->name, MAC2STR(mgmt->sa),
-		       MAC2STR(mgmt->bssid));
+		       "unknown AP (SA=" MAC_FMT " BSSID=" MAC_FMT ") - "
+		       "ignored\n", dev->name, MAC_ARG(mgmt->sa),
+		       MAC_ARG(mgmt->bssid));
 		return;
 	}
 
@@ -1120,9 +1120,9 @@ static void ieee80211_rx_mgmt_assoc_resp
 		       "set\n", dev->name, aid);
 	aid &= ~(BIT(15) | BIT(14));
 
-	printk(KERN_DEBUG "%s: RX %sssocResp from " MACSTR " (capab=0x%x "
+	printk(KERN_DEBUG "%s: RX %sssocResp from " MAC_FMT " (capab=0x%x "
 	       "status=%d aid=%d)\n",
-	       dev->name, reassoc ? "Rea" : "A", MAC2STR(mgmt->sa),
+	       dev->name, reassoc ? "Rea" : "A", MAC_ARG(mgmt->sa),
 	       capab_info, status_code, aid);
 
 	if (status_code != WLAN_STATUS_SUCCESS) {
@@ -1349,9 +1349,9 @@ static void ieee80211_rx_bss_info(struct
 		return; /* ignore ProbeResp to foreign address */
 
 #if 0
-	printk(KERN_DEBUG "%s: RX %s from " MACSTR " to " MACSTR "\n",
+	printk(KERN_DEBUG "%s: RX %s from " MAC_FMT " to " MAC_FMT "\n",
 	       dev->name, beacon ? "Beacon" : "Probe Response",
-	       MAC2STR(mgmt->sa), MAC2STR(mgmt->da));
+	       MAC_ARG(mgmt->sa), MAC_ARG(mgmt->da));
 #endif
 
 	baselen = (u8 *) mgmt->u.beacon.variable - (u8 *) mgmt;
@@ -1370,10 +1370,10 @@ #ifdef IEEE80211_IBSS_DEBUG
 		else
 			tsf = -1LLU;
 		if (time_after(jiffies, last_tsf_debug + 5 * HZ)) {
-			printk(KERN_DEBUG "RX beacon SA=" MACSTR " BSSID="
-			       MACSTR " TSF=0x%llx BCN=0x%llx diff=%lld "
+			printk(KERN_DEBUG "RX beacon SA=" MAC_FMT " BSSID="
+			       MAC_FMT " TSF=0x%llx BCN=0x%llx diff=%lld "
 			       "@%ld\n",
-			       MAC2STR(mgmt->sa), MAC2STR(mgmt->bssid),
+			       MAC_ARG(mgmt->sa), MAC_ARG(mgmt->bssid),
 			       tsf, timestamp, tsf - timestamp, jiffies);
 			last_tsf_debug = jiffies;
 		}
@@ -1433,9 +1433,9 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		}
 		if (sta->supp_rates != prev_rates) {
 			printk(KERN_DEBUG "%s: updated supp_rates set for "
-			       MACSTR " based on beacon info (0x%x & 0x%x -> "
+			       MAC_FMT " based on beacon info (0x%x & 0x%x -> "
 			       "0x%x)\n",
-			       dev->name, MAC2STR(sta->addr), prev_rates,
+			       dev->name, MAC_ARG(sta->addr), prev_rates,
 			       supp_rates, sta->supp_rates);
 		}
 		sta_info_put(sta);
@@ -1618,10 +1618,10 @@ static void ieee80211_rx_mgmt_beacon(str
 	if (use_protection != !!ifsta->use_protection) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: CTS protection %s (BSSID="
-			       MACSTR ")\n",
+			       MAC_FMT ")\n",
 			       dev->name,
 			       use_protection ? "enabled" : "disabled",
-			       MAC2STR(ifsta->bssid));
+			       MAC_ARG(ifsta->bssid));
 		}
 		ifsta->use_protection = use_protection ? 1 : 0;
 		local->cts_protect_erp_frames = use_protection;
@@ -1658,10 +1658,10 @@ static void ieee80211_rx_mgmt_probe_req(
 		tx_last_beacon = 1;
 
 #ifdef IEEE80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: RX ProbeReq SA=" MACSTR " DA=" MACSTR " BSSID="
-	       MACSTR " (tx_last_beacon=%d)\n",
-	       dev->name, MAC2STR(mgmt->sa), MAC2STR(mgmt->da),
-	       MAC2STR(mgmt->bssid), tx_last_beacon);
+	printk(KERN_DEBUG "%s: RX ProbeReq SA=" MAC_FMT " DA=" MAC_FMT " BSSID="
+	       MAC_FMT " (tx_last_beacon=%d)\n",
+	       dev->name, MAC_ARG(mgmt->sa), MAC_ARG(mgmt->da),
+	       MAC_ARG(mgmt->bssid), tx_last_beacon);
 #endif /* IEEE80211_IBSS_DEBUG */
 
 	if (!tx_last_beacon)
@@ -1677,8 +1677,8 @@ #endif /* IEEE80211_IBSS_DEBUG */
 	    pos + 2 + pos[1] > end) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: Invalid SSID IE in ProbeReq "
-			       "from " MACSTR "\n",
-			       dev->name, MAC2STR(mgmt->sa));
+			       "from " MAC_FMT "\n",
+			       dev->name, MAC_ARG(mgmt->sa));
 		}
 		return;
 	}
@@ -1697,8 +1697,8 @@ #endif /* IEEE80211_IBSS_DEBUG */
 	resp = (struct ieee80211_mgmt *) skb->data;
 	memcpy(resp->da, mgmt->sa, ETH_ALEN);
 #ifdef IEEE80211_IBSS_DEBUG
-	printk(KERN_DEBUG "%s: Sending ProbeResp to " MACSTR "\n",
-	       dev->name, MAC2STR(resp->da));
+	printk(KERN_DEBUG "%s: Sending ProbeResp to " MAC_FMT "\n",
+	       dev->name, MAC_ARG(resp->da));
 #endif /* IEEE80211_IBSS_DEBUG */
 	ieee80211_sta_tx(dev, skb, 0, 1);
 }
@@ -1726,39 +1726,40 @@ void ieee80211_sta_rx_mgmt(struct net_de
 	mgmt = (struct ieee80211_mgmt *) skb->data;
 	fc = le16_to_cpu(mgmt->frame_control);
 
-	switch (WLAN_FC_GET_STYPE(fc)) {
-	case WLAN_FC_STYPE_PROBE_REQ:
+	switch (fc & IEEE80211_FCTL_STYPE) {
+	case IEEE80211_STYPE_PROBE_REQ:
 		ieee80211_rx_mgmt_probe_req(dev, ifsta, mgmt, skb->len,
 					    rx_status);
 		break;
-	case WLAN_FC_STYPE_PROBE_RESP:
+	case IEEE80211_STYPE_PROBE_RESP:
 		ieee80211_rx_mgmt_probe_resp(dev, mgmt, skb->len, rx_status);
 		break;
-	case WLAN_FC_STYPE_BEACON:
+	case IEEE80211_STYPE_BEACON:
 		ieee80211_rx_mgmt_beacon(dev, mgmt, skb->len, rx_status);
 		break;
-	case WLAN_FC_STYPE_AUTH:
+	case IEEE80211_STYPE_AUTH:
 		ieee80211_rx_mgmt_auth(dev, ifsta, mgmt, skb->len, rx_status);
 		break;
-	case WLAN_FC_STYPE_ASSOC_RESP:
+	case IEEE80211_STYPE_ASSOC_RESP:
 		ieee80211_rx_mgmt_assoc_resp(dev, ifsta, mgmt, skb->len,
 					     rx_status, 0);
 		break;
-	case WLAN_FC_STYPE_REASSOC_RESP:
+	case IEEE80211_STYPE_REASSOC_RESP:
 		ieee80211_rx_mgmt_assoc_resp(dev, ifsta, mgmt, skb->len,
 					     rx_status, 1);
 		break;
-	case WLAN_FC_STYPE_DEAUTH:
+	case IEEE80211_STYPE_DEAUTH:
 		ieee80211_rx_mgmt_deauth(dev, ifsta, mgmt, skb->len,
 					 rx_status);
 		break;
-	case WLAN_FC_STYPE_DISASSOC:
+	case IEEE80211_STYPE_DISASSOC:
 		ieee80211_rx_mgmt_disassoc(dev, ifsta, mgmt, skb->len,
 					   rx_status);
 		break;
 	default:
 		printk(KERN_DEBUG "%s: received unknown management frame - "
-		       "stype=%d\n", dev->name, WLAN_FC_GET_STYPE(fc));
+		       "stype=%d\n", dev->name,
+		       (fc & IEEE80211_FCTL_STYPE) >> 4);
 		break;
 	}
 
@@ -1781,11 +1782,11 @@ void ieee80211_sta_rx_scan(struct net_de
 	mgmt = (struct ieee80211_mgmt *) skb->data;
 	fc = le16_to_cpu(mgmt->frame_control);
 
-	if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_MGMT) {
-		if (WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_PROBE_RESP) {
+	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT) {
+		if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PROBE_RESP) {
 			ieee80211_rx_mgmt_probe_resp(dev, mgmt,
 						     skb->len, rx_status);
-		} else if (WLAN_FC_GET_STYPE(fc) == WLAN_FC_STYPE_BEACON) {
+		} else if ((fc & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_BEACON) {
 			ieee80211_rx_mgmt_beacon(dev, mgmt, skb->len,
 						 rx_status);
 		}
@@ -1829,8 +1830,8 @@ static void ieee80211_sta_expire(struct 
 		sta = list_entry(ptr, struct sta_info, list);
 		if (time_after(jiffies, sta->last_rx +
 			       IEEE80211_IBSS_INACTIVITY_LIMIT)) {
-			printk(KERN_DEBUG "%s: expiring inactive STA " MACSTR
-			       "\n", dev->name, MAC2STR(sta->addr));
+			printk(KERN_DEBUG "%s: expiring inactive STA " MAC_FMT
+			       "\n", dev->name, MAC_ARG(sta->addr));
 			sta_info_free(sta, 1);
 		}
 	}
@@ -2017,8 +2018,8 @@ static int ieee80211_sta_join_ibss(struc
 		mgmt = (struct ieee80211_mgmt *)
 			skb_put(skb, 24 + sizeof(mgmt->u.beacon));
 		memset(mgmt, 0, 24 + sizeof(mgmt->u.beacon));
-		mgmt->frame_control = IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-						   WLAN_FC_STYPE_BEACON);
+		mgmt->frame_control = IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+						   IEEE80211_STYPE_BEACON);
 		memset(mgmt->da, 0xff, ETH_ALEN);
 		memcpy(mgmt->sa, dev->dev_addr, ETH_ALEN);
 		memcpy(mgmt->bssid, ifsta->bssid, ETH_ALEN);
@@ -2083,8 +2084,8 @@ static int ieee80211_sta_join_ibss(struc
 			mgmt = (struct ieee80211_mgmt *)
 				ifsta->probe_resp->data;
 			mgmt->frame_control =
-				IEEE80211_FC(WLAN_FC_TYPE_MGMT,
-					     WLAN_FC_STYPE_PROBE_RESP);
+				IEEE80211_FC(IEEE80211_FTYPE_MGMT,
+					     IEEE80211_STYPE_PROBE_RESP);
 		} else {
 			printk(KERN_DEBUG "%s: Could not allocate ProbeResp "
 			       "template for IBSS\n", dev->name);
@@ -2147,8 +2148,8 @@ #else
 	bssid[0] |= 0x02;
 #endif
 
-	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID " MACSTR "\n",
-	       dev->name, MAC2STR(bssid));
+	printk(KERN_DEBUG "%s: Creating new IBSS network, BSSID " MAC_FMT "\n",
+	       dev->name, MAC_ARG(bssid));
 
 	bss = ieee80211_rx_bss_add(dev, bssid);
 	if (bss == NULL)
@@ -2207,8 +2208,8 @@ #endif /* IEEE80211_IBSS_DEBUG */
 		    || !(bss->capability & WLAN_CAPABILITY_IBSS))
 			continue;
 #ifdef IEEE80211_IBSS_DEBUG
-		printk(KERN_DEBUG "   bssid=" MACSTR " found\n",
-		       MAC2STR(bss->bssid));
+		printk(KERN_DEBUG "   bssid=" MAC_FMT " found\n",
+		       MAC_ARG(bss->bssid));
 #endif /* IEEE80211_IBSS_DEBUG */
 		memcpy(bssid, bss->bssid, ETH_ALEN);
 		found = 1;
@@ -2218,14 +2219,14 @@ #endif /* IEEE80211_IBSS_DEBUG */
 	spin_unlock_bh(&local->sta_bss_lock);
 
 #ifdef IEEE80211_IBSS_DEBUG
-	printk(KERN_DEBUG "   sta_find_ibss: selected " MACSTR " current "
-	       MACSTR "\n", MAC2STR(bssid), MAC2STR(ifsta->bssid));
+	printk(KERN_DEBUG "   sta_find_ibss: selected " MAC_FMT " current "
+	       MAC_FMT "\n", MAC_ARG(bssid), MAC_ARG(ifsta->bssid));
 #endif /* IEEE80211_IBSS_DEBUG */
 	if (found && memcmp(ifsta->bssid, bssid, ETH_ALEN) != 0 &&
 	    (bss = ieee80211_rx_bss_get(dev, bssid))) {
-		printk(KERN_DEBUG "%s: Selected IBSS BSSID " MACSTR
+		printk(KERN_DEBUG "%s: Selected IBSS BSSID " MAC_FMT
 		       " based on configured SSID\n",
-		       dev->name, MAC2STR(bssid));
+		       dev->name, MAC_ARG(bssid));
 		return ieee80211_sta_join_ibss(dev, ifsta, bss);
 	}
 #ifdef IEEE80211_IBSS_DEBUG
@@ -2799,7 +2800,7 @@ struct sta_info * ieee80211_ibss_add_sta
 	if (local->num_sta >= IEEE80211_IBSS_MAX_STA_ENTRIES) {
 		if (net_ratelimit()) {
 			printk(KERN_DEBUG "%s: No room for a new IBSS STA "
-			       "entry " MACSTR "\n", dev->name, MAC2STR(addr));
+			       "entry " MAC_FMT "\n", dev->name, MAC_ARG(addr));
 		}
 		return NULL;
 	}
@@ -2818,8 +2819,8 @@ struct sta_info * ieee80211_ibss_add_sta
 	if (sta_dev == NULL)
 		return NULL;
 
-	printk(KERN_DEBUG "%s: Adding new IBSS station " MACSTR " (dev=%s)\n",
-	       dev->name, MAC2STR(addr), sta_dev->name);
+	printk(KERN_DEBUG "%s: Adding new IBSS station " MAC_FMT " (dev=%s)\n",
+	       dev->name, MAC_ARG(addr), sta_dev->name);
 
 	sta = sta_info_add(local, dev, addr);
 	if (sta == NULL) {
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index fb1c6b5..9974668 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -420,7 +420,7 @@ #define IEEE80211_IF_FMT_MAC(name, field
 static ssize_t ieee80211_if_fmt_##name(const struct			\
 			ieee80211_sub_if_data *sdata, char *buf)	\
 {									\
-	return sprintf(buf, MACSTR "\n", MAC2STR(sdata->field));	\
+	return sprintf(buf, MAC_FMT "\n", MAC_ARG(sdata->field));	\
 }
 
 #define __IEEE80211_IF_SHOW(name)					\
diff --git a/net/d80211/rate_control.c b/net/d80211/rate_control.c
index bf797ec..1d40e88 100644
--- a/net/d80211/rate_control.c
+++ b/net/d80211/rate_control.c
@@ -141,9 +141,9 @@ static void rate_control_simple_tx_statu
 	if (status->excessive_retries) {
 		sta->antenna_sel = sta->antenna_sel == 1 ? 2 : 1;
 		if (local->sta_antenna_sel == STA_ANTENNA_SEL_SW_CTRL_DEBUG) {
-			printk(KERN_DEBUG "%s: " MACSTR " TX antenna --> %d "
+			printk(KERN_DEBUG "%s: " MAC_FMT " TX antenna --> %d "
 			       "(@%lu)\n",
-			       dev->name, MAC2STR(hdr->addr1),
+			       dev->name, MAC_ARG(hdr->addr1),
 			       sta->antenna_sel, jiffies);
 		}
 		srctrl->tx_num_failures++;
@@ -196,9 +196,9 @@ #endif
 		srctrl->avg_rate_update = jiffies;
 		if (srctrl->tx_avg_rate_num > 0) {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-			printk(KERN_DEBUG "%s: STA " MACSTR " Average rate: "
+			printk(KERN_DEBUG "%s: STA " MAC_FMT " Average rate: "
 			       "%d (%d/%d)\n",
-                               dev->name, MAC2STR(sta->addr),
+			       dev->name, MAC_ARG(sta->addr),
 			       srctrl->tx_avg_rate_sum /
 			       srctrl->tx_avg_rate_num,
 			       srctrl->tx_avg_rate_sum,
@@ -227,7 +227,7 @@ rate_control_simple_get_rate(struct net_
 	memset(extra, 0, sizeof(*extra));
 
 	fc = le16_to_cpu(hdr->frame_control);
-	if (WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_DATA ||
+	if ((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA ||
 	    (hdr->addr1[0] & 0x01)) {
 		/* Send management frames and broadcast/multicast data using
 		 * lowest rate. */
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index d3b4b42..7f5febe 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -51,8 +51,8 @@ static void sta_info_hash_del(struct iee
 	if (s->hnext != NULL)
 		s->hnext = s->hnext->hnext;
 	else
-		printk(KERN_ERR "%s: could not remove STA " MACSTR " from "
-		       "hash table\n", local->mdev->name, MAC2STR(sta->addr));
+		printk(KERN_ERR "%s: could not remove STA " MAC_FMT " from "
+		       "hash table\n", local->mdev->name, MAC_ARG(sta->addr));
 }
 
 static inline struct sta_info *__sta_info_get(struct sta_info *sta)
@@ -139,7 +139,7 @@ struct sta_info * sta_info_add(struct ie
 
 	memset(sta, 0, sizeof(*sta));
 
-	if (kobject_set_name(&sta->kobj, MACSTR, MAC2STR(addr))) {
+	if (kobject_set_name(&sta->kobj, MAC_FMT, MAC_ARG(addr))) {
 		kfree(sta);
 		return NULL;
 	}
@@ -170,8 +170,8 @@ struct sta_info * sta_info_add(struct ie
 	sta->key_idx_compression = HW_KEY_IDX_INVALID;
 
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Added STA " MACSTR "\n",
-	       local->mdev->name, MAC2STR(addr));
+	printk(KERN_DEBUG "%s: Added STA " MAC_FMT "\n",
+	       local->mdev->name, MAC_ARG(addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	if (!in_interrupt()) {
@@ -193,8 +193,8 @@ static void finish_sta_info_free(struct 
 				 struct sta_info *sta)
 {
 #ifdef CONFIG_D80211_VERBOSE_DEBUG
-	printk(KERN_DEBUG "%s: Removed STA " MACSTR "\n",
-	       local->mdev->name, MAC2STR(sta->addr));
+	printk(KERN_DEBUG "%s: Removed STA " MAC_FMT "\n",
+	       local->mdev->name, MAC_ARG(sta->addr));
 #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 
 	rate_control_remove_sta_attrs(local, sta->rate_ctrl_priv, &sta->kobj);
@@ -301,7 +301,7 @@ static void sta_info_cleanup_expire_buff
 		if (skb) {
 			local->total_ps_buffered--;
 			printk(KERN_DEBUG "Buffered frame expired (STA "
-			       MACSTR ")\n", MAC2STR(sta->addr));
+			       MAC_FMT ")\n", MAC_ARG(sta->addr));
 			dev_kfree_skb(skb);
 		} else
 			break;
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index 337e31a..3f0cf57 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -276,8 +276,8 @@ #endif /* CONFIG_TKIP_DEBUG */
 	      iv16 <= key->u.tkip.iv16_rx[queue]))) {
 #ifdef CONFIG_TKIP_DEBUG
 		printk(KERN_DEBUG "TKIP replay detected for RX frame from "
-		       MACSTR " (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
-		       MAC2STR(ta),
+		       MAC_FMT " (RX IV (%04x,%02x) <= prev. IV (%04x,%02x)\n",
+		       MAC_ARG(ta),
 		       iv32, iv16, key->u.tkip.iv32_rx[queue],
 		       key->u.tkip.iv16_rx[queue]);
 #endif /* CONFIG_TKIP_DEBUG */
@@ -298,8 +298,8 @@ #endif /* CONFIG_TKIP_DEBUG */
 #ifdef CONFIG_TKIP_DEBUG
 		{
 			int i;
-			printk(KERN_DEBUG "TKIP decrypt: Phase1 TA=" MACSTR
-			       " TK=", MAC2STR(ta));
+			printk(KERN_DEBUG "TKIP decrypt: Phase1 TA=" MAC_FMT
+			       " TK=", MAC_ARG(ta));
 			for (i = 0; i < 16; i++)
 				printk("%02x ",
 				       key->key[ALG_TKIP_TEMP_ENCR_KEY + i]);
diff --git a/net/d80211/wep.c b/net/d80211/wep.c
index f60e449..0473f3c 100644
--- a/net/d80211/wep.c
+++ b/net/d80211/wep.c
@@ -81,7 +81,7 @@ u8 * ieee80211_wep_add_iv(struct ieee802
 	u8 *newhdr;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	fc |= WLAN_FC_ISWEP;
+	fc |= IEEE80211_FCTL_PROTECTED;
 	hdr->frame_control = cpu_to_le16(fc);
 
 	if ((skb_headroom(skb) < WEP_IV_LEN ||
@@ -227,7 +227,7 @@ int ieee80211_wep_decrypt(struct ieee802
 	int ret = 0;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	if (!(fc & WLAN_FC_ISWEP))
+	if (!(fc & IEEE80211_FCTL_PROTECTED))
 		return -1;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
@@ -281,7 +281,7 @@ int ieee80211_wep_get_keyidx(struct sk_b
 	int hdrlen;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	if (!(fc & WLAN_FC_ISWEP))
+	if (!(fc & IEEE80211_FCTL_PROTECTED))
 		return -1;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
@@ -302,7 +302,7 @@ u8 * ieee80211_wep_is_weak_iv(struct sk_
 	u32 iv;
 
 	fc = le16_to_cpu(hdr->frame_control);
-	if (!(fc & WLAN_FC_ISWEP))
+	if (!(fc & IEEE80211_FCTL_PROTECTED))
 		return NULL;
 
 	hdrlen = ieee80211_get_hdrlen(fc);
diff --git a/net/d80211/wme.c b/net/d80211/wme.c
index 76de062..c3c961d 100644
--- a/net/d80211/wme.c
+++ b/net/d80211/wme.c
@@ -38,7 +38,7 @@ ieee80211_rx_h_parse_qos(struct ieee8021
 		/* frame has qos control */
 		tid = qc[0] & QOS_CONTROL_TID_MASK;
 	} else {
-		if (unlikely(WLAN_FC_GET_TYPE(rx->fc) == WLAN_FC_TYPE_MGMT)) {
+		if (unlikely((rx->fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_MGMT)) {
 			/* Separate TID for management frames */
 			tid = NUM_RX_DATA_QUEUES - 1;
 		} else {
@@ -76,7 +76,7 @@ ieee80211_rx_h_remove_qos_control(struct
 	memmove(data + 2, data, ieee80211_get_hdrlen(fc) - 2);
 	hdr = (struct ieee80211_hdr *) skb_pull(rx->skb, 2);
 	/* change frame type to non QOS */
-	rx->fc = fc &= ~(WLAN_FC_STYPE_QOS_DATA << 4);
+	rx->fc = fc &= ~(IEEE80211_STYPE_QOS_DATA << 4);
 	hdr->frame_control = cpu_to_le16(fc);
 
 	return TXRX_CONTINUE;
@@ -184,7 +184,7 @@ static inline int classify80211(struct s
 	const int ieee802_1d_to_ac[8] = { 2, 3, 3, 2, 1, 1, 0, 0 };
 
 	/* see if frame is data or non data frame */
-	if (unlikely(WLAN_FC_GET_TYPE(fc) != WLAN_FC_TYPE_DATA)) {
+	if (unlikely((fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA)) {
 		/* management frames go on AC_VO queue, but are sent
 		* without QoS control fields */
 		return IEEE80211_TX_QUEUE_DATA0;
@@ -199,7 +199,7 @@ static inline int classify80211(struct s
 	}
 
 	/* is this a QoS frame? */
-	qos = fc & (WLAN_FC_STYPE_QOS_DATA << 4);
+	qos = fc & (IEEE80211_STYPE_QOS_DATA << 4);
 
 	if (!qos) {
 		skb->priority = 0; /* required for correct WPA/11i MIC */
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 811a107..7919620 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -45,15 +45,15 @@ int ieee80211_get_hdr_info(const struct 
 	fc = le16_to_cpu(hdr->frame_control);
 
 	hdrlen = 24;
-	if ((fc & (WLAN_FC_FROMDS | WLAN_FC_TODS)) ==
-	    (WLAN_FC_FROMDS | WLAN_FC_TODS)) {
+	if ((fc & (IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) ==
+	    (IEEE80211_FCTL_FROMDS | IEEE80211_FCTL_TODS)) {
 		hdrlen += ETH_ALEN;
 		*sa = hdr->addr4;
 		*da = hdr->addr3;
-	} else if (fc & WLAN_FC_FROMDS) {
+	} else if (fc & IEEE80211_FCTL_FROMDS) {
 		*sa = hdr->addr3;
 		*da = hdr->addr1;
-	} else if (fc & WLAN_FC_TODS) {
+	} else if (fc & IEEE80211_FCTL_TODS) {
 		*sa = hdr->addr2;
 		*da = hdr->addr3;
 	} else {
@@ -67,10 +67,10 @@ int ieee80211_get_hdr_info(const struct 
 	*data = skb->data + hdrlen;
 	*data_len = skb->len - hdrlen;
 
-	a4_included = (fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) ==
-		(WLAN_FC_TODS | WLAN_FC_FROMDS);
-	if (WLAN_FC_GET_TYPE(fc) == WLAN_FC_TYPE_DATA &&
-	    WLAN_FC_GET_STYPE(fc) & 0x08) {
+	a4_included = (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+		(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
+	if ((fc & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_DATA &&
+	    (fc & IEEE80211_FCTL_STYPE) & IEEE80211_STYPE_QOS_DATA) {
 		pos = (u8 *) &hdr->addr4;
 		if (a4_included)
 			pos += 6;
@@ -133,7 +133,7 @@ #endif /* MICHAEL_MIC_HWACCEL */
 	}
 
 #if 0
-	authenticator = fc & WLAN_FC_FROMDS; /* FIX */
+	authenticator = fc & IEEE80211_FCTL_FROMDS; /* FIX */
 #else
 	authenticator = 1;
 #endif
@@ -145,8 +145,8 @@ #endif
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if (tx->sta && tx->sta->wpa_trigger & WPA_TRIGGER_FAIL_TX_MIC) {
 		printk(KERN_INFO "%s: WPA testing - corrupting TX Michael MIC "
-		       "for STA " MACSTR "\n",
-		       tx->dev->name, MAC2STR(tx->sta->addr));
+		       "for STA " MAC_FMT "\n",
+		       tx->dev->name, MAC_ARG(tx->sta->addr));
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 		tx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_TX_MIC;
 		tx->wpa_test = 1;
@@ -184,7 +184,7 @@ ieee80211_rx_h_michael_mic_verify(struct
 		return TXRX_CONTINUE;
 
 	if (!rx->key || rx->key->alg != ALG_TKIP ||
-	    !(rx->fc & WLAN_FC_ISWEP) || !WLAN_FC_DATA_PRESENT(fc))
+	    !(rx->fc & IEEE80211_FCTL_PROTECTED) || !WLAN_FC_DATA_PRESENT(fc))
 		return TXRX_CONTINUE;
 
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
@@ -215,7 +215,7 @@ #endif /* MICHAEL_MIC_HWACCEL */
 	data_len -= MICHAEL_MIC_LEN;
 
 #if 0
-	authenticator = fc & WLAN_FC_TODS; /* FIX */
+	authenticator = fc & IEEE80211_FCTL_TODS; /* FIX */
 #else
 	authenticator = 1;
 #endif
@@ -225,8 +225,8 @@ #endif
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if (rx->sta && rx->sta->wpa_trigger & WPA_TRIGGER_FAIL_RX_MIC) {
 		printk(KERN_INFO "%s: WPA testing - corrupting RX Michael MIC "
-		       "for STA " MACSTR "\n",
-		       rx->dev->name, MAC2STR(rx->sta->addr));
+		       "for STA " MAC_FMT "\n",
+		       rx->dev->name, MAC_ARG(rx->sta->addr));
 		rx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_RX_MIC;
 		mic[0]++;
 	}
@@ -240,7 +240,7 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 			return TXRX_DROP;
 
 		printk(KERN_DEBUG "%s: invalid Michael MIC in data frame from "
-		       MACSTR "\n", rx->dev->name, MAC2STR(sa));
+		       MAC_FMT "\n", rx->dev->name, MAC_ARG(sa));
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 		printk(KERN_DEBUG "   received");
 		for (i = 0; i < MICHAEL_MIC_LEN; i++)
@@ -249,8 +249,8 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 		for (i = 0; i < MICHAEL_MIC_LEN; i++)
 			printk(" %02x", mic[i]);
 		printk("\n");
-		printk(KERN_DEBUG "   SA=" MACSTR " DA=" MACSTR " key",
-		       MAC2STR(sa), MAC2STR(da));
+		printk(KERN_DEBUG "   SA=" MAC_FMT " DA=" MAC_FMT " key",
+		       MAC_ARG(sa), MAC_ARG(da));
 		for (i = 0; i < 8; i++)
 			printk(" %02x", key[i]);
 		printk(" (%d)\n", authenticator);
@@ -266,10 +266,10 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 			/* TODO: needed parameters: count, key type, TSC */
 			hdr = (struct ieee80211_hdr *) skb->data;
 			sprintf(buf, "MLME-MICHAELMICFAILURE.indication("
-				"keyid=%d %scast addr=" MACSTR ")",
+				"keyid=%d %scast addr=" MAC_FMT ")",
 				rx->key->keyidx,
 				hdr->addr1[0] & 0x01 ? "broad" : "uni",
-				MAC2STR(hdr->addr2));
+				MAC_ARG(hdr->addr2));
 			memset(&wrqu, 0, sizeof(wrqu));
 			wrqu.data.length = strlen(buf);
 			wireless_send_event(rx->dev, IWEVCUSTOM, &wrqu, buf);
@@ -439,8 +439,8 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if (tx->sta && tx->sta->wpa_trigger & WPA_TRIGGER_FAIL_TX_ICV) {
 		printk(KERN_INFO "%s: WPA testing - corrupting TX TKIP ICV "
-		       "for STA " MACSTR "\n",
-		       tx->dev->name, MAC2STR(tx->sta->addr));
+		       "for STA " MAC_FMT "\n",
+		       tx->dev->name, MAC_ARG(tx->sta->addr));
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 		tx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_TX_ICV;
 		skb->data[skb->len - 1]++;
@@ -472,8 +472,8 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 
 	if (!rx->key || rx->key->alg != ALG_TKIP ||
-	    !(rx->fc & WLAN_FC_ISWEP) ||
-	    WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA)
+	    !(rx->fc & IEEE80211_FCTL_PROTECTED) ||
+	    (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA)
 		return TXRX_CONTINUE;
 
 	if (!rx->sta || skb->len - hdrlen < 12)
@@ -482,8 +482,8 @@ ieee80211_rx_h_tkip_decrypt(struct ieee8
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	if (rx->sta && rx->sta->wpa_trigger & WPA_TRIGGER_FAIL_RX_ICV) {
 		printk(KERN_INFO "%s: WPA testing - corrupting RX TKIP ICV "
-		       "for STA " MACSTR "\n",
-		       rx->dev->name, MAC2STR(rx->sta->addr));
+		       "for STA " MAC_FMT "\n",
+		       rx->dev->name, MAC_ARG(rx->sta->addr));
 		rx->sta->wpa_trigger &= ~WPA_TRIGGER_FAIL_RX_ICV;
 		skb->data[skb->len - 1]++;
 		wpa_test = 1;
@@ -507,8 +507,8 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 					  hwaccel, rx->u.rx.queue);
 	if (res != TKIP_DECRYPT_OK || wpa_test) {
 		printk(KERN_DEBUG "%s: TKIP decrypt failed for RX frame from "
-		       MACSTR " (res=%d)\n",
-		       rx->dev->name, MAC2STR(rx->sta->addr), res);
+		       MAC_FMT " (res=%d)\n",
+		       rx->dev->name, MAC_ARG(rx->sta->addr), res);
 		return TXRX_DROP;
 	}
 
@@ -535,8 +535,8 @@ static void ccmp_special_blocks(struct s
 
 	fc_pos = (u8 *) &hdr->frame_control;
 	fc = fc_pos[0] ^ (fc_pos[1] << 8);
-	a4_included = (fc & (WLAN_FC_TODS | WLAN_FC_FROMDS)) ==
-		(WLAN_FC_TODS | WLAN_FC_FROMDS);
+	a4_included = (fc & (IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS)) ==
+		(IEEE80211_FCTL_TODS | IEEE80211_FCTL_FROMDS);
 
 	ieee80211_get_hdr_info(skb, &sa, &da, &qos_tid, &data, &data_len);
 	data_len -= CCMP_HDR_LEN + (encrypted ? CCMP_MIC_LEN : 0);
@@ -772,8 +772,8 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 
 	if (!key || key->alg != ALG_CCMP ||
-	    !(rx->fc & WLAN_FC_ISWEP) ||
-	    WLAN_FC_GET_TYPE(rx->fc) != WLAN_FC_TYPE_DATA)
+	    !(rx->fc & IEEE80211_FCTL_PROTECTED) ||
+	    (rx->fc & IEEE80211_FCTL_FTYPE) != IEEE80211_FTYPE_DATA)
 		return TXRX_CONTINUE;
 
 	data_len = skb->len - hdrlen - CCMP_HDR_LEN - CCMP_MIC_LEN;
@@ -791,9 +791,9 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 #ifdef CONFIG_D80211_DEBUG
 		u8 *ppn = key->u.ccmp.rx_pn[rx->u.rx.queue];
 		printk(KERN_DEBUG "%s: CCMP replay detected for RX frame from "
-		       MACSTR " (RX PN %02x%02x%02x%02x%02x%02x <= prev. PN "
+		       MAC_FMT " (RX PN %02x%02x%02x%02x%02x%02x <= prev. PN "
 		       "%02x%02x%02x%02x%02x%02x)\n", rx->dev->name,
-		       MAC2STR(rx->sta->addr),
+		       MAC_ARG(rx->sta->addr),
 		       pn[0], pn[1], pn[2], pn[3], pn[4], pn[5],
 		       ppn[0], ppn[1], ppn[2], ppn[3], ppn[4], ppn[5]);
 #endif /* CONFIG_D80211_DEBUG */
@@ -819,8 +819,8 @@ #endif /* CONFIG_D80211_DEBUG */
 			    skb->data + skb->len - CCMP_MIC_LEN,
 			    skb->data + hdrlen + CCMP_HDR_LEN)) {
 			printk(KERN_DEBUG "%s: CCMP decrypt failed for RX "
-			       "frame from " MACSTR "\n", rx->dev->name,
-			       MAC2STR(rx->sta->addr));
+			       "frame from " MAC_FMT "\n", rx->dev->name,
+			       MAC_ARG(rx->sta->addr));
 			return TXRX_DROP;
 		}
 	}
-- 
1.3.0

