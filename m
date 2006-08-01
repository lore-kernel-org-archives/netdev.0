From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 5/5] d80211: Switch d80211 drivers to IEEE80211_ style definitions
Date: Tue,  1 Aug 2006 21:17:00 +0200 (CEST)
Message-ID: <20060801191700.7546B483A9@silver.suse.cz>
References: <20060801211530.150852000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:50648 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S1751827AbWHATQ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:16:59 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060801211530.150852000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes the d80211 drivers work with the switch to IEEE80211_ style
names in d80211.h. Based on the patch by Michael Wu <flamingice@sourmilk.net>.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 drivers/net/wireless/d80211/adm8211/adm8211.c      |   10 +++++-----
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   12 ++++++------
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |   15 +++++++--------
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |   12 ++++++------
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |   12 ++++++------
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |   12 ++++++------
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |   10 +++++-----
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |   10 +++++-----
 8 files changed, 46 insertions(+), 47 deletions(-)

d2273a999331dce2e2bf6719e9fbc70ed252ea25
diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 0a762d7..748eb26 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -1825,7 +1825,7 @@ static int adm8211_tx(struct net_device 
 
 	memcpy(&hdr, skb->data, sizeof(hdr));
 
-	fc = le16_to_cpu(hdr.frame_control) & ~WLAN_FC_ISWEP;
+	fc = le16_to_cpu(hdr.frame_control) & ~IEEE80211_FCTL_PROTECTED;
 	hdrlen = ieee80211_get_hdrlen(fc);
 	skb_pull(skb, hdrlen);
 	payload_len = skb->len;
@@ -1847,7 +1847,7 @@ static int adm8211_tx(struct net_device 
 	txhdr->frame_control = hdr.frame_control;
 
 	len = hdrlen + payload_len + FCS_LEN;
-	if (fc & WLAN_FC_ISWEP)
+	if (fc & IEEE80211_FCTL_PROTECTED)
 		len += 8;
 
 	txhdr->frag = cpu_to_le16(0x0FFF);
@@ -1866,7 +1866,7 @@ static int adm8211_tx(struct net_device 
 	if (control->use_rts_cts)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
 
-	if (fc & WLAN_FC_ISWEP)
+	if (fc & IEEE80211_FCTL_PROTECTED)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_WEP_ENGINE);
 
 	txhdr->retry_limit = control->retry_limit;
@@ -2082,8 +2082,8 @@ #endif
 		goto err_free_desc;
 	}
 
-	printk("%s: hwaddr " MACSTR ", Rev 0x%02x\n",
-	       dev->name, MAC2STR(dev->dev_addr), priv->revid);
+	printk("%s: hwaddr " MAC_FMT ", Rev 0x%02x\n",
+	       dev->name, MAC_ARG(dev->dev_addr), priv->revid);
 
 	return 0;
 
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 337544e..59d137b 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -1682,8 +1682,8 @@ static u8 * bcm43xx_generate_probe_resp(
 	*dest_size = dest_pos;
 
 	/* Set the frame control. */
-	dest_data[0] = ((WLAN_FC_TYPE_MGMT << 2) |
-			(WLAN_FC_STYPE_PROBE_RESP << 4));
+	dest_data[0] = (IEEE80211_FTYPE_MGMT |
+			IEEE80211_STYPE_PROBE_RESP);
 	dest_data[1] = 0;
 
 	/* Set the duration field.
@@ -4270,9 +4270,9 @@ static int bcm43xx_add_interface(struct 
 
 	dprintk(KERN_INFO PFX "Virtual interface added "
 			      "(type: 0x%08X, ID: %d, MAC: "
-			      MACSTR ")\n",
+			      MAC_FMT ")\n",
 		conf->type, conf->if_id,
-		MAC2STR((u8 *)conf->mac_addr));
+		MAC_ARG(conf->mac_addr));
 
 out_unlock:
 	spin_unlock_irqrestore(&bcm->irq_lock, flags);
@@ -4301,9 +4301,9 @@ static void bcm43xx_remove_interface(str
 
 	dprintk(KERN_INFO PFX "Virtual interface removed "
 			      "(type: 0x%08X, ID: %d, MAC: "
-			      MACSTR ")\n",
+			      MAC_FMT ")\n",
 		conf->type, conf->if_id,
-		MAC2STR((u8 *)conf->mac_addr));
+		MAC_ARG(conf->mac_addr));
 }
 
 static int bcm43xx_config_interface(struct net_device *net_dev,
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 6ebe9fa..3f86079 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -180,12 +180,12 @@ __le16 bcm43xx_calc_duration_id(const st
 	const u16 frame_ctl = le16_to_cpu(wireless_header->frame_control);
 	__le16 duration_id = wireless_header->duration_id;
 
-	switch (WLAN_FC_GET_TYPE(frame_ctl)) {
-	case WLAN_FC_TYPE_DATA:
-	case WLAN_FC_TYPE_MGMT:
+	switch (frame_ctl & IEEE80211_FCTL_FTYPE) {
+	case IEEE80211_FTYPE_DATA:
+	case IEEE80211_FTYPE_MGMT:
 		//TODO: Steal the code from ieee80211, once it is completed there.
 		break;
-	case WLAN_FC_TYPE_CTRL:
+	case IEEE80211_FTYPE_CTL:
 		/* Use the original duration/id. */
 		break;
 	default:
@@ -226,8 +226,7 @@ static void bcm43xx_generate_rts(const s
 				  flen, bitrate);
 	bcm43xx_generate_plcp_hdr((struct bcm43xx_plcp_hdr4 *)(&txhdr->rts_cts_fallback_plcp),
 				  flen, fallback_bitrate);
-	fctl = WLAN_FC_TYPE_CTRL << 2;
-	fctl |= WLAN_FC_STYPE_RTS << 4;
+	fctl = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	dur = le16_to_cpu(wlhdr->duration_id);
 /*FIXME: should we test for dur==0 here and let it unmodified in this case?
  *       The following assert checks for this case...
@@ -259,8 +258,8 @@ assert(dur);
 
 	txhdr->rts_cts_frame_control = cpu_to_le16(fctl);
 	txhdr->rts_cts_dur = cpu_to_le16(dur);
-//printk(MACSTR "  " MACSTR "  " MACSTR "\n", MAC2STR(wlhdr->addr1), MAC2STR(wlhdr->addr2), MAC2STR(wlhdr->addr3));
-//printk(MACSTR "  " MACSTR "\n", MAC2STR(sa), MAC2STR(da));
+//printk(MAC_FMT "  " MAC_FMT "  " MAC_FMT "\n", MAC_ARG(wlhdr->addr1), MAC_ARG(wlhdr->addr2), MAC_ARG(wlhdr->addr3));
+//printk(MAC_FMT "  " MAC_FMT "\n", MAC_ARG(sa), MAC_ARG(da));
 	memcpy(txhdr->rts_cts_mac1, wlhdr->addr1, ETH_ALEN);//FIXME!
 	memcpy(txhdr->rts_cts_mac2, sa, ETH_ALEN);
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 4a74d2a..709cdbf 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -1532,7 +1532,7 @@ static struct sk_buff* rt2400pci_create_
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
@@ -1564,7 +1564,7 @@ static void rt2400pci_write_tx_desc(stru
 	 * Check which rate should be used for this frame.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS &&
 	    control->rts_cts_rate)
 		tx_rate = control->rts_cts_rate;
 	else
@@ -1577,7 +1577,7 @@ static void rt2400pci_write_tx_desc(stru
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
-	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
 	    control->use_rts_cts)
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
@@ -1598,7 +1598,7 @@ static void rt2400pci_write_tx_desc(stru
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		rt2x00_set_field32(&txd->word0, TXD_W0_RTS, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_RTS, 0);
@@ -1922,7 +1922,7 @@ static int rt2400pci_tx(struct net_devic
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if (control->use_rts_cts &&
-	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2400pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -1957,7 +1957,7 @@ static int rt2400pci_tx(struct net_devic
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2400pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index a2e41a3..8a22968 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -1652,7 +1652,7 @@ static struct sk_buff* rt2500pci_create_
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
@@ -1685,7 +1685,7 @@ static void rt2500pci_write_tx_desc(stru
 	 * Check which rate should be used for this frame.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS &&
 	    control->rts_cts_rate)
 		tx_rate = control->rts_cts_rate;
 	else
@@ -1707,7 +1707,7 @@ static void rt2500pci_write_tx_desc(stru
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
-	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
 	    control->use_rts_cts)
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
@@ -1723,7 +1723,7 @@ static void rt2500pci_write_tx_desc(stru
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 1);
 	else
 		rt2x00_set_field32(&txd->word10, TXD_W10_RTS, 0);
@@ -2069,7 +2069,7 @@ static int rt2500pci_tx(struct net_devic
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if (control->use_rts_cts &&
-	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2500pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -2104,7 +2104,7 @@ static int rt2500pci_tx(struct net_devic
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt2500pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index ff84d0e..d15a33e 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -1414,7 +1414,7 @@ static struct sk_buff* rt2500usb_create_
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
@@ -1447,7 +1447,7 @@ static void rt2500usb_write_tx_desc(stru
 	 * Check which rate should be used for this frame.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS &&
 	    control->rts_cts_rate)
 		tx_rate = control->rts_cts_rate;
 	else
@@ -1468,7 +1468,7 @@ static void rt2500usb_write_tx_desc(stru
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
-	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
 	    control->use_rts_cts)
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
@@ -1482,7 +1482,7 @@ static void rt2500usb_write_tx_desc(stru
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_MORE_FRAG, 0);
 
-	if (WLAN_GET_SEQ_FRAG(ieee80211hdr->seq_ctrl) == 0)
+	if ((ieee80211hdr->seq_ctrl & IEEE80211_SCTL_FRAG) == 0)
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 1);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_NEW_SEQ, 0);
@@ -1788,7 +1788,7 @@ static int rt2500usb_tx(struct net_devic
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if (control->use_rts_cts &&
-	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2500usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -1817,7 +1817,7 @@ static int rt2500usb_tx(struct net_devic
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt2500usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 3233658..8bb9de9 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -2085,7 +2085,7 @@ static struct sk_buff* rt61pci_create_rt
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
@@ -2118,7 +2118,7 @@ static void rt61pci_write_tx_desc(struct
 	 * Check which rate should be used for this frame.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS &&
 	    control->rts_cts_rate)
 		tx_rate = control->rts_cts_rate;
 	else
@@ -2140,7 +2140,7 @@ static void rt61pci_write_tx_desc(struct
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
-	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
 	    control->use_rts_cts)
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
@@ -2548,7 +2548,7 @@ static int rt61pci_tx(struct net_device 
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if (control->use_rts_cts &&
-	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt61pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -2578,7 +2578,7 @@ static int rt61pci_tx(struct net_device 
 	memcpy(rt2x00pci_data_addr(entry), skb->data, skb->len);
 	rt61pci_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 1106a20..acc5357 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -1681,7 +1681,7 @@ static struct sk_buff* rt73usb_create_rt
 	memcpy(skb_put(skb, IEEE80211_HEADER), hdr, IEEE80211_HEADER);
 	ieee80211hdr = (struct ieee80211_hdr*)skb->data;
 
-	frame_control = (WLAN_FC_TYPE_CTRL  << 2) | (WLAN_FC_STYPE_RTS << 4);
+	frame_control = IEEE80211_FTYPE_CTL | IEEE80211_STYPE_RTS;
 	ieee80211hdr->frame_control = cpu_to_le16(frame_control);
 
 	ieee80211hdr->duration_id += cpu_to_le16(duration);
@@ -1714,7 +1714,7 @@ static void rt73usb_write_tx_desc(struct
 	 * Check which rate should be used for this frame.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS &&
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS &&
 	    control->rts_cts_rate)
 		tx_rate = control->rts_cts_rate;
 	else
@@ -1736,7 +1736,7 @@ static void rt73usb_write_tx_desc(struct
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
-	if ((WLAN_GET_SEQ_FRAG(le16_to_cpu(ieee80211hdr->seq_ctrl)) > 0) ||
+	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
 	    control->use_rts_cts)
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
@@ -2072,7 +2072,7 @@ static int rt73usb_tx(struct net_device 
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
 	if (control->use_rts_cts &&
-	    WLAN_FC_GET_STYPE(frame_control) != WLAN_FC_STYPE_RTS) {
+	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt73usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
 		if (!skb_rts) {
@@ -2101,7 +2101,7 @@ static int rt73usb_tx(struct net_device 
 	memcpy(rt2x00usb_txdata_addr(entry), skb->data, skb->len);
 	rt73usb_write_tx_desc(rt2x00dev, txd, skb, control);
 	memcpy(&entry->tx_status.control, control, sizeof(*control));
-	if (WLAN_FC_GET_STYPE(frame_control) == WLAN_FC_STYPE_RTS)
+	if ((frame_control & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_RTS)
 		SET_FLAG(entry, ENTRY_RTS_FRAME);
 	entry->skb = skb;
 
-- 
1.3.0

