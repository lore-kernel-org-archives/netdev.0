From: yuan linyu <cugyly@163.com>
Subject: [PATCH net-next 3/3] net: manual clean code which call skb_put_[data:zero]
Date: Sun, 18 Jun 2017 22:52:04 +0800
Message-ID: <1497797524-25622-1-git-send-email-cugyly@163.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-13.163.com ([220.181.12.13]:43087 "EHLO m12-13.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752909AbdFROwj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 10:52:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>

Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
---
 drivers/isdn/hysdn/hycapi.c                           |  8 ++++----
 drivers/isdn/i4l/isdn_bsdcomp.c                       |  2 +-
 drivers/isdn/i4l/isdn_ppp.c                           |  2 +-
 drivers/net/bonding/bond_alb.c                        |  3 +--
 drivers/net/caif/caif_hsi.c                           |  6 ++----
 drivers/net/caif/caif_serial.c                        |  3 +--
 drivers/net/caif/caif_spi.c                           |  3 +--
 drivers/net/ethernet/nxp/lpc_eth.c                    |  7 +++----
 drivers/net/ethernet/packetengines/hamachi.c          |  4 ++--
 drivers/net/ppp/ppp_synctty.c                         |  2 +-
 drivers/net/usb/asix_common.c                         |  5 ++---
 drivers/net/usb/hso.c                                 | 13 ++++++-------
 drivers/net/wireless/ath/ath9k/wmi.c                  |  3 +--
 drivers/net/wireless/marvell/libertas/if_sdio.c       |  3 +--
 drivers/net/wireless/quantenna/qtnfmac/qlink_util.h   |  4 +---
 drivers/net/wireless/realtek/rtlwifi/pci.c            |  3 +--
 drivers/net/wireless/rsi/rsi_91x_mgmt.c               | 10 +++-------
 drivers/net/wireless/ti/wlcore/rx.c                   |  3 +--
 drivers/nfc/pn533/pn533.c                             |  4 ++--
 drivers/staging/rtl8188eu/core/rtw_recv.c             |  4 +---
 drivers/staging/rtl8192e/rtllib_rx.c                  |  5 ++---
 drivers/staging/rtl8192e/rtllib_softmac.c             | 11 ++++++-----
 drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c     |  4 +---
 .../staging/rtl8192u/ieee80211/ieee80211_softmac.c    | 11 +++++------
 drivers/staging/rtl8192u/r819xU_cmdpkt.c              |  3 +--
 drivers/staging/rtl8712/rtl8712_recv.c                |  4 ++--
 drivers/staging/rtl8723bs/os_dep/recv_linux.c         |  4 +---
 drivers/staging/wlan-ng/hfa384x_usb.c                 |  2 +-
 drivers/usb/gadget/function/f_ncm.c                   | 11 +++++------
 lib/nlattr.c                                          |  6 +-----
 net/bridge/netfilter/nft_reject_bridge.c              |  6 ++----
 net/dsa/tag_trailer.c                                 |  3 +--
 net/hsr/hsr_device.c                                  |  6 +++---
 net/irda/irlap_frame.c                                |  5 ++---
 net/mac80211/mlme.c                                   | 12 ++++--------
 net/mac80211/tdls.c                                   | 19 +++++++++----------
 net/sctp/sm_make_chunk.c                              |  3 +--
 net/vmw_vsock/virtio_transport_common.c               |  5 ++---
 net/x25/x25_subr.c                                    | 16 ++++++++--------
 39 files changed, 93 insertions(+), 135 deletions(-)

diff --git a/drivers/isdn/hysdn/hycapi.c b/drivers/isdn/hysdn/hycapi.c
index 87119b5..eac0f51 100644
--- a/drivers/isdn/hysdn/hycapi.c
+++ b/drivers/isdn/hysdn/hycapi.c
@@ -173,8 +173,8 @@ hycapi_register_internal(struct capi_ctr *ctrl, __u16 appl,
 	}
 	skb_put_data(skb, &len, sizeof(__u16));
 	skb_put_data(skb, &appl, sizeof(__u16));
-	memcpy(skb_put(skb, sizeof(__u8)), &_command, sizeof(_command));
-	memcpy(skb_put(skb, sizeof(__u8)), &_subcommand, sizeof(_subcommand));
+	skb_put_data(skb, &_command, sizeof(__u8));
+	skb_put_data(skb, &_subcommand, sizeof(__u8));
 	skb_put_data(skb, &MessageNumber, sizeof(__u16));
 	skb_put_data(skb, &MessageBufferSize, sizeof(__u16));
 	skb_put_data(skb, &(rp->level3cnt), sizeof(__u16));
@@ -281,8 +281,8 @@ static void hycapi_release_internal(struct capi_ctr *ctrl, __u16 appl)
 	}
 	skb_put_data(skb, &len, sizeof(__u16));
 	skb_put_data(skb, &appl, sizeof(__u16));
-	memcpy(skb_put(skb, sizeof(__u8)), &_command, sizeof(_command));
-	memcpy(skb_put(skb, sizeof(__u8)), &_subcommand, sizeof(_subcommand));
+	skb_put_data(skb, &_command, sizeof(__u8));
+	skb_put_data(skb, &_subcommand, sizeof(__u8));
 	skb_put_data(skb, &MessageNumber, sizeof(__u16));
 	hycapi_send_message(ctrl, skb);
 	hycapi_applications[appl - 1].ctrl_mask &= ~(1 << (ctrl->cnr - 1));
diff --git a/drivers/isdn/i4l/isdn_bsdcomp.c b/drivers/isdn/i4l/isdn_bsdcomp.c
index 3035210..5b64a13 100644
--- a/drivers/isdn/i4l/isdn_bsdcomp.c
+++ b/drivers/isdn/i4l/isdn_bsdcomp.c
@@ -472,7 +472,7 @@ static int bsd_compress(void *state, struct sk_buff *skb_in, struct sk_buff *skb
 		accm |= ((ent) << bitno);				\
 		do	{						\
 			if (skb_out && skb_tailroom(skb_out) > 0)	\
-				*(u8 *)skb_put(skb_out, 1) = (u8)(accm >> 24); \
+				skb_put(skb_out, (u8)(accm >> 24));	\
 			accm <<= 8;					\
 			bitno += 8;					\
 		} while (bitno <= 24);					\
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index b7e3f1c..88e5a02 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -2258,7 +2258,7 @@ static void isdn_ppp_ccp_xmit_reset(struct ippp_struct *is, int proto,
 
 	/* Now stuff remaining bytes */
 	if (len) {
-		p = skb_put_data(skb, data, len);
+		skb_put_data(skb, data, len);
 	}
 
 	/* skb is now ready for xmit */
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b796db7..c02cc81 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -925,7 +925,6 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	struct learning_pkt pkt;
 	struct sk_buff *skb;
 	int size = sizeof(struct learning_pkt);
-	char *data;
 
 	memset(&pkt, 0, size);
 	ether_addr_copy(pkt.mac_dst, mac_addr);
@@ -936,7 +935,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	if (!skb)
 		return;
 
-	data = skb_put_data(skb, &pkt, size);
+	skb_put_data(skb, &pkt, size);
 
 	skb_reset_mac_header(skb);
 	skb->network_header = skb->mac_header + ETH_HLEN;
diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 4534326..11ba6e3 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -426,7 +426,6 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 	/* Check for embedded CAIF frame. */
 	if (desc->offset) {
 		struct sk_buff *skb;
-		u8 *dst = NULL;
 		int len = 0;
 		pfrm = ((u8 *)desc) + desc->offset;
 
@@ -454,7 +453,7 @@ static int cfhsi_rx_desc(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 		}
 		caif_assert(skb != NULL);
 
-		dst = skb_put_data(skb, pfrm, len);
+		skb_put_data(skb, pfrm, len);
 
 		skb->protocol = htons(ETH_P_CAIF);
 		skb_reset_mac_header(skb);
@@ -555,7 +554,6 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 	/* Parse payload. */
 	while (nfrms < CFHSI_MAX_PKTS && *plen) {
 		struct sk_buff *skb;
-		u8 *dst = NULL;
 		u8 *pcffrm = NULL;
 		int len;
 
@@ -584,7 +582,7 @@ static int cfhsi_rx_pld(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 		}
 		caif_assert(skb != NULL);
 
-		dst = skb_put_data(skb, pcffrm, len);
+		skb_put_data(skb, pcffrm, len);
 
 		skb->protocol = htons(ETH_P_CAIF);
 		skb_reset_mac_header(skb);
diff --git a/drivers/net/caif/caif_serial.c b/drivers/net/caif/caif_serial.c
index 5c57be2..709838e 100644
--- a/drivers/net/caif/caif_serial.c
+++ b/drivers/net/caif/caif_serial.c
@@ -171,7 +171,6 @@ static void ldisc_receive(struct tty_struct *tty, const u8 *data,
 	struct sk_buff *skb = NULL;
 	struct ser_device *ser;
 	int ret;
-	u8 *p;
 
 	ser = tty->disc_data;
 
@@ -198,7 +197,7 @@ static void ldisc_receive(struct tty_struct *tty, const u8 *data,
 	skb = netdev_alloc_skb(ser->dev, count+1);
 	if (skb == NULL)
 		return;
-	p = skb_put_data(skb, data, count);
+	skb_put_data(skb, data, count);
 
 	skb->protocol = htons(ETH_P_CAIF);
 	skb_reset_mac_header(skb);
diff --git a/drivers/net/caif/caif_spi.c b/drivers/net/caif/caif_spi.c
index 24a5f5c..207cb84 100644
--- a/drivers/net/caif/caif_spi.c
+++ b/drivers/net/caif/caif_spi.c
@@ -526,7 +526,6 @@ int cfspi_rxfrm(struct cfspi *cfspi, u8 *buf, size_t len)
 		struct sk_buff *skb = NULL;
 		int spad = 0;
 		int epad = 0;
-		u8 *dst = NULL;
 		int pkt_len = 0;
 
 		/*
@@ -548,7 +547,7 @@ int cfspi_rxfrm(struct cfspi *cfspi, u8 *buf, size_t len)
 		skb = netdev_alloc_skb(cfspi->ndev, pkt_len + 1);
 		caif_assert(skb != NULL);
 
-		dst = skb_put_data(skb, src, pkt_len);
+		skb_put_data(skb, src, pkt_len);
 		src += pkt_len;
 
 		skb->protocol = htons(ETH_P_CAIF);
diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index 828bfd9..08381ef 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -919,7 +919,6 @@ static int __lpc_handle_recv(struct net_device *ndev, int budget)
 	struct sk_buff *skb;
 	u32 rxconsidx, len, ethst;
 	struct rx_status_t *prxstat;
-	u8 *prdbuf;
 	int rx_done = 0;
 
 	/* Get the current RX buffer indexes */
@@ -960,9 +959,9 @@ static int __lpc_handle_recv(struct net_device *ndev, int budget)
 				ndev->stats.rx_dropped++;
 			} else {
 				/* Copy packet from buffer */
-				prdbuf = skb_put_data(skb,
-						      pldat->rx_buff_v + rxconsidx * ENET_MAXF_SIZE,
-						      len);
+				skb_put_data(skb,
+					     pldat->rx_buff_v + rxconsidx * ENET_MAXF_SIZE,
+					     len);
 
 				/* Pass to upper layer */
 				skb->protocol = eth_type_trans(skb, ndev);
diff --git a/drivers/net/ethernet/packetengines/hamachi.c b/drivers/net/ethernet/packetengines/hamachi.c
index 8b026db..482b85e 100644
--- a/drivers/net/ethernet/packetengines/hamachi.c
+++ b/drivers/net/ethernet/packetengines/hamachi.c
@@ -1495,8 +1495,8 @@ static int hamachi_rx(struct net_device *dev)
 					hmp->rx_skbuff[entry]->data, pkt_len);
 				skb_put(skb, pkt_len);
 #else
-				memcpy(skb_put(skb, pkt_len), hmp->rx_ring_dma
-					+ entry*sizeof(*desc), pkt_len);
+				skb_put_data(skb, hmp->rx_ring_dma
+					     + entry*sizeof(*desc), pkt_len);
 #endif
 				pci_dma_sync_single_for_device(hmp->pci_dev,
 							       leXX_to_cpu(hmp->rx_ring[entry].addr),
diff --git a/drivers/net/ppp/ppp_synctty.c b/drivers/net/ppp/ppp_synctty.c
index ef08590..7868c29 100644
--- a/drivers/net/ppp/ppp_synctty.c
+++ b/drivers/net/ppp/ppp_synctty.c
@@ -697,7 +697,7 @@ ppp_sync_input(struct syncppp *ap, const unsigned char *buf,
 		goto err;
 	}
 
-	p = skb_put_data(skb, buf, count);
+	skb_put_data(skb, buf, count);
 
 	/* strip address/control field if present */
 	p = skb->data;
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
index 90facc5..7847436 100644
--- a/drivers/net/usb/asix_common.c
+++ b/drivers/net/usb/asix_common.c
@@ -113,7 +113,6 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 
 	while (offset + sizeof(u16) <= skb->len) {
 		u16 copy_length;
-		unsigned char *data;
 
 		if (!rx->remaining) {
 			if (skb->len - offset == sizeof(u16)) {
@@ -167,8 +166,8 @@ int asix_rx_fixup_internal(struct usbnet *dev, struct sk_buff *skb,
 		}
 
 		if (rx->ax_skb) {
-			data = skb_put_data(rx->ax_skb, skb->data + offset,
-					    copy_length);
+			skb_put_data(rx->ax_skb, skb->data + offset,
+				     copy_length);
 			if (!rx->remaining)
 				usbnet_skb_return(dev, rx->ax_skb);
 		}
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 908ada4..d7a3379 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -861,7 +861,6 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 	unsigned short temp_bytes;
 	unsigned short buffer_offset = 0;
 	unsigned short frame_len;
-	unsigned char *tmp_rx_buf;
 
 	/* log if needed */
 	hso_dbg(0x1, "Rx %d bytes\n", count);
@@ -911,9 +910,9 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 
 				/* Copy what we got so far. make room for iphdr
 				 * after tail. */
-				tmp_rx_buf = skb_put_data(odev->skb_rx_buf,
-							  (char *)&(odev->rx_ip_hdr),
-							  sizeof(struct iphdr));
+				skb_put_data(odev->skb_rx_buf,
+					     (char *)&(odev->rx_ip_hdr),
+					     sizeof(struct iphdr));
 
 				/* ETH_HLEN */
 				odev->rx_buf_size = sizeof(struct iphdr);
@@ -932,9 +931,9 @@ static void packetizeRx(struct hso_net *odev, unsigned char *ip_pkt,
 			/* Copy the rest of the bytes that are left in the
 			 * buffer into the waiting sk_buf. */
 			/* Make room for temp_bytes after tail. */
-			tmp_rx_buf = skb_put_data(odev->skb_rx_buf,
-						  ip_pkt + buffer_offset,
-						  temp_bytes);
+			skb_put_data(odev->skb_rx_buf,
+				     ip_pkt + buffer_offset,
+				     temp_bytes);
 
 			odev->rx_buf_missing -= temp_bytes;
 			count -= temp_bytes;
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 85d09fd..64a354f 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -298,7 +298,6 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 	u16 headroom = sizeof(struct htc_frame_hdr) +
 		       sizeof(struct wmi_cmd_hdr);
 	struct sk_buff *skb;
-	u8 *data;
 	unsigned long time_left;
 	int ret = 0;
 
@@ -312,7 +311,7 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 	skb_reserve(skb, headroom);
 
 	if (cmd_len != 0 && cmd_buf != NULL) {
-		data = skb_put_data(skb, cmd_buf, cmd_len);
+		skb_put_data(skb, cmd_buf, cmd_len);
 	}
 
 	mutex_lock(&wmi->op_mutex);
diff --git a/drivers/net/wireless/marvell/libertas/if_sdio.c b/drivers/net/wireless/marvell/libertas/if_sdio.c
index a9e2b06..2300e79 100644
--- a/drivers/net/wireless/marvell/libertas/if_sdio.c
+++ b/drivers/net/wireless/marvell/libertas/if_sdio.c
@@ -239,7 +239,6 @@ static int if_sdio_handle_data(struct if_sdio_card *card,
 {
 	int ret;
 	struct sk_buff *skb;
-	char *data;
 
 	if (size > MRVDRV_ETH_RX_PACKET_BUFFER_SIZE) {
 		lbs_deb_sdio("response packet too large (%d bytes)\n",
@@ -256,7 +255,7 @@ static int if_sdio_handle_data(struct if_sdio_card *card,
 
 	skb_reserve(skb, NET_IP_ALIGN);
 
-	data = skb_put_data(skb, buffer, size);
+	skb_put_data(skb, buffer, size);
 
 	lbs_process_rxed_packet(card->priv, skb);
 
diff --git a/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h b/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
index f6ac399..90d7d09 100644
--- a/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
+++ b/drivers/net/wireless/quantenna/qtnfmac/qlink_util.h
@@ -33,9 +33,7 @@ static inline void qtnf_cmd_skb_put_action(struct sk_buff *skb, u16 action)
 static inline void
 qtnf_cmd_skb_put_buffer(struct sk_buff *skb, const u8 *buf_src, size_t len)
 {
-	u8 *buf_dst;
-
-	buf_dst = skb_put_data(skb, buf_src, len);
+	skb_put_data(skb, buf_src, len);
 }
 
 static inline void qtnf_cmd_skb_put_tlv_arr(struct sk_buff *skb,
diff --git a/drivers/net/wireless/realtek/rtlwifi/pci.c b/drivers/net/wireless/realtek/rtlwifi/pci.c
index 0c1f830..df5f679 100644
--- a/drivers/net/wireless/realtek/rtlwifi/pci.c
+++ b/drivers/net/wireless/realtek/rtlwifi/pci.c
@@ -729,13 +729,12 @@ static void _rtl_pci_rx_to_mac80211(struct ieee80211_hw *hw,
 		dev_kfree_skb_any(skb);
 	} else {
 		struct sk_buff *uskb = NULL;
-		u8 *pdata;
 
 		uskb = dev_alloc_skb(skb->len + 128);
 		if (likely(uskb)) {
 			memcpy(IEEE80211_SKB_RXCB(uskb), &rx_status,
 			       sizeof(rx_status));
-			pdata = skb_put_data(uskb, skb->data, skb->len);
+			skb_put_data(uskb, skb->data, skb->len);
 			dev_kfree_skb_any(skb);
 			ieee80211_rx_irqsafe(hw, uskb);
 		} else {
diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
index 4433cec..a0f0437 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -389,9 +389,7 @@ static int rsi_mgmt_pkt_to_core(struct rsi_common *common,
 	struct ieee80211_tx_info *info;
 	struct skb_info *rx_params;
 	u8 pad_bytes = msg[4];
-	u8 pkt_recv;
 	struct sk_buff *skb;
-	char *buffer;
 
 	if (type == RX_DOT11_MGMT) {
 		if (!adapter->sc_nvifs)
@@ -412,11 +410,9 @@ static int rsi_mgmt_pkt_to_core(struct rsi_common *common,
 			return -ENOMEM;
 		}
 
-		buffer = skb_put_data(skb,
-				      (u8 *)(msg + FRAME_DESC_SZ + pad_bytes),
-				      msg_len);
-
-		pkt_recv = buffer[0];
+		skb_put_data(skb,
+			     (u8 *)(msg + FRAME_DESC_SZ + pad_bytes),
+			     msg_len);
 
 		info = IEEE80211_SKB_CB(skb);
 		rx_params = (struct skb_info *)info->driver_data;
diff --git a/drivers/net/wireless/ti/wlcore/rx.c b/drivers/net/wireless/ti/wlcore/rx.c
index 53cd6d4..0f15696 100644
--- a/drivers/net/wireless/ti/wlcore/rx.c
+++ b/drivers/net/wireless/ti/wlcore/rx.c
@@ -117,7 +117,6 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	struct wl1271_rx_descriptor *desc;
 	struct sk_buff *skb;
 	struct ieee80211_hdr *hdr;
-	u8 *buf;
 	u8 beacon = 0;
 	u8 is_data = 0;
 	u8 reserved = 0, offset_to_data = 0;
@@ -180,7 +179,7 @@ static int wl1271_rx_handle_data(struct wl1271 *wl, u8 *data, u32 length,
 	 * packets copy the packets in offset of 2 bytes guarantee IP header
 	 * payload aligned to 4 bytes.
 	 */
-	buf = skb_put_data(skb, data + sizeof(*desc), pkt_data_len);
+	skb_put_data(skb, data + sizeof(*desc), pkt_data_len);
 	if (rx_align == WLCORE_RX_BUF_PADDED)
 		skb_pull(skb, RX_BUF_ALIGN);
 
diff --git a/drivers/nfc/pn533/pn533.c b/drivers/nfc/pn533/pn533.c
index c8a8f5b..c05cb63 100644
--- a/drivers/nfc/pn533/pn533.c
+++ b/drivers/nfc/pn533/pn533.c
@@ -1006,7 +1006,7 @@ static int pn533_start_poll_complete(struct pn533 *dev, struct sk_buff *resp)
 static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 {
 	struct sk_buff *skb;
-	u8 *felica, *nfcid3, *gb;
+	u8 *felica, *nfcid3;
 
 	u8 *gbytes = dev->gb;
 	size_t gbytes_len = dev->gb_len;
@@ -1048,7 +1048,7 @@ static struct sk_buff *pn533_alloc_poll_tg_frame(struct pn533 *dev)
 	/* General bytes */
 	skb_put_u8(skb, gbytes_len);
 
-	gb = skb_put_data(skb, gbytes, gbytes_len);
+	skb_put_data(skb, gbytes, gbytes_len);
 
 	/* Len Tk */
 	skb_put_u8(skb, 0);
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 14173cf..afb9dad 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -1510,7 +1510,6 @@ static int amsdu_to_msdu(struct adapter *padapter, struct recv_frame *prframe)
 	u8	nr_subframes, i;
 	unsigned char *pdata;
 	struct rx_pkt_attrib *pattrib;
-	unsigned char *data_ptr;
 	struct sk_buff *sub_skb, *subframes[MAX_SUBFRAME_COUNT];
 	struct recv_priv *precvpriv = &padapter->recvpriv;
 	struct __queue *pfree_recv_queue = &(precvpriv->free_recv_queue);
@@ -1544,8 +1543,7 @@ static int amsdu_to_msdu(struct adapter *padapter, struct recv_frame *prframe)
 		sub_skb = dev_alloc_skb(nSubframe_Length + 12);
 		if (sub_skb) {
 			skb_reserve(sub_skb, 12);
-			data_ptr = skb_put_data(sub_skb, pdata,
-						nSubframe_Length);
+			skb_put_data(sub_skb, pdata, nSubframe_Length);
 		} else {
 			sub_skb = skb_clone(prframe->pkt, GFP_ATOMIC);
 			if (sub_skb) {
diff --git a/drivers/staging/rtl8192e/rtllib_rx.c b/drivers/staging/rtl8192e/rtllib_rx.c
index bae98ca..03a81ba 100644
--- a/drivers/staging/rtl8192e/rtllib_rx.c
+++ b/drivers/staging/rtl8192e/rtllib_rx.c
@@ -782,7 +782,6 @@ static u8 parse_subframe(struct rtllib_device *ieee, struct sk_buff *skb,
 	u8		nPadding_Length = 0;
 	u16		SeqNum = 0;
 	struct sk_buff *sub_skb;
-	u8	     *data_ptr;
 	/* just for debug purpose */
 	SeqNum = WLAN_GET_SEQ_SEQ(le16_to_cpu(hdr->seq_ctl));
 	if ((RTLLIB_QOS_HAS_SEQ(fc)) &&
@@ -817,7 +816,7 @@ static u8 parse_subframe(struct rtllib_device *ieee, struct sk_buff *skb,
 		if (!sub_skb)
 			return 0;
 		skb_reserve(sub_skb, 12);
-		data_ptr = skb_put_data(sub_skb, skb->data, skb->len);
+		skb_put_data(sub_skb, skb->data, skb->len);
 		sub_skb->dev = ieee->dev;
 
 		rxb->subframes[0] = sub_skb;
@@ -869,7 +868,7 @@ static u8 parse_subframe(struct rtllib_device *ieee, struct sk_buff *skb,
 		if (!sub_skb)
 			return 0;
 		skb_reserve(sub_skb, 12);
-		data_ptr = skb_put_data(sub_skb, skb->data, nSubframe_Length);
+		skb_put_data(sub_skb, skb->data, nSubframe_Length);
 
 		sub_skb->dev = ieee->dev;
 		rxb->subframes[rxb->nr_subframes++] = sub_skb;
diff --git a/drivers/staging/rtl8192e/rtllib_softmac.c b/drivers/staging/rtl8192e/rtllib_softmac.c
index 5f2751d..09d2c86 100644
--- a/drivers/staging/rtl8192e/rtllib_softmac.c
+++ b/drivers/staging/rtl8192e/rtllib_softmac.c
@@ -1264,7 +1264,7 @@ rtllib_association_req(struct rtllib_network *beacon,
 	hdr->info_element[0].id = MFIE_TYPE_SSID;
 
 	hdr->info_element[0].len = beacon->ssid_len;
-	tag = skb_put_data(skb, beacon->ssid, beacon->ssid_len);
+	skb_put_data(skb, beacon->ssid, beacon->ssid_len);
 
 	tag = skb_put(skb, rate_len);
 
@@ -1340,7 +1340,7 @@ rtllib_association_req(struct rtllib_network *beacon,
 	}
 
 	if (wpa_ie_len) {
-		tag = skb_put_data(skb, ieee->wpa_ie, ieee->wpa_ie_len);
+		skb_put_data(skb, ieee->wpa_ie, ieee->wpa_ie_len);
 
 		if (PMKCacheIdx >= 0) {
 			tag = skb_put(skb, 18);
@@ -1356,12 +1356,13 @@ rtllib_association_req(struct rtllib_network *beacon,
 	}
 
 	if (wps_ie_len && ieee->wps_ie) {
-		tag = skb_put_data(skb, ieee->wps_ie, wps_ie_len);
+		skb_put_data(skb, ieee->wps_ie, wps_ie_len);
 	}
 
-	tag = skb_put(skb, turbo_info_len);
-	if (turbo_info_len)
+	if (turbo_info_len) {
+		tag = skb_put(skb, turbo_info_len);
 		rtllib_TURBO_Info(ieee, &tag);
+	}
 
 	if (ieee->pHTInfo->bCurrentHTSupport && ieee->pHTInfo->bEnableHT) {
 		if (ieee->pHTInfo->ePeerHTSpecVer == HT_SPEC_VER_EWC) {
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
index c0e2f71..a4aedb4 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_rx.c
@@ -780,7 +780,6 @@ static u8 parse_subframe(struct sk_buff *skb,
 	u16		SeqNum=0;
 
 	struct sk_buff *sub_skb;
-	u8             *data_ptr;
 	/* just for debug purpose */
 	SeqNum = WLAN_GET_SEQ_SEQ(le16_to_cpu(hdr->seq_ctl));
 
@@ -848,8 +847,7 @@ static u8 parse_subframe(struct sk_buff *skb,
 			if (!sub_skb)
 				return 0;
 			skb_reserve(sub_skb, 12);
-			data_ptr = skb_put_data(sub_skb, skb->data,
-						nSubframe_Length);
+			skb_put_data(sub_skb, skb->data, nSubframe_Length);
 #endif
 			rxb->subframes[rxb->nr_subframes++] = sub_skb;
 			if (rxb->nr_subframes >= MAX_SUBFRAME_COUNT) {
diff --git a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
index 1070691..fe6f38b 100644
--- a/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
+++ b/drivers/staging/rtl8192u/ieee80211/ieee80211_softmac.c
@@ -1112,7 +1112,7 @@ ieee80211_association_req(struct ieee80211_network *beacon,
 	hdr->info_element[0].id = MFIE_TYPE_SSID;
 
 	hdr->info_element[0].len = beacon->ssid_len;
-	tag = skb_put_data(skb, beacon->ssid, beacon->ssid_len);
+	skb_put_data(skb, beacon->ssid, beacon->ssid_len);
 
 	tag = skb_put(skb, rate_len);
 
@@ -1184,18 +1184,17 @@ ieee80211_association_req(struct ieee80211_network *beacon,
 
 
 	//choose what wpa_supplicant gives to associate.
-	tag = skb_put(skb, wpa_ie_len);
 	if (wpa_ie_len) {
-		memcpy(tag, ieee->wpa_ie, ieee->wpa_ie_len);
+		skb_put_data(skb, ieee->wpa_ie, wpa_ie_len);
 	}
 
-	tag = skb_put(skb, wmm_info_len);
 	if (wmm_info_len) {
-	  ieee80211_WMM_Info(ieee, &tag);
+		tag = skb_put(skb, wmm_info_len);
+		ieee80211_WMM_Info(ieee, &tag);
 	}
 #ifdef THOMAS_TURBO
-	tag = skb_put(skb, turbo_info_len);
 	if (turbo_info_len) {
+		tag = skb_put(skb, turbo_info_len);
 		ieee80211_TURBO_Info(ieee, &tag);
 	}
 #endif
diff --git a/drivers/staging/rtl8192u/r819xU_cmdpkt.c b/drivers/staging/rtl8192u/r819xU_cmdpkt.c
index c3cf01c..87ab3ba 100644
--- a/drivers/staging/rtl8192u/r819xU_cmdpkt.c
+++ b/drivers/staging/rtl8192u/r819xU_cmdpkt.c
@@ -31,7 +31,6 @@ rt_status SendTxCommandPacket(struct net_device *dev, void *pData, u32 DataLen)
 	struct r8192_priv   *priv = ieee80211_priv(dev);
 	struct sk_buff	    *skb;
 	struct cb_desc	    *tcb_desc;
-	unsigned char	    *ptr_buf;
 
 	/* Get TCB and local buffer from common pool.
 	 * (It is shared by CmdQ, MgntQ, and USB coalesce DataQ)
@@ -45,7 +44,7 @@ rt_status SendTxCommandPacket(struct net_device *dev, void *pData, u32 DataLen)
 	tcb_desc->bCmdOrInit = DESC_PACKET_TYPE_NORMAL;
 	tcb_desc->bLastIniPkt = 0;
 	skb_reserve(skb, USB_HWDESC_HEADER_LEN);
-	ptr_buf = skb_put_data(skb, pData, DataLen);
+	skb_put_data(skb, pData, DataLen);
 	tcb_desc->txbuf_size = (u16)DataLen;
 
 	if (!priv->ieee80211->check_nic_enough_desc(dev, tcb_desc->queue_index) ||
diff --git a/drivers/staging/rtl8712/rtl8712_recv.c b/drivers/staging/rtl8712/rtl8712_recv.c
index f96c558..ea3eb94 100644
--- a/drivers/staging/rtl8712/rtl8712_recv.c
+++ b/drivers/staging/rtl8712/rtl8712_recv.c
@@ -340,7 +340,7 @@ static int amsdu_to_msdu(struct _adapter *padapter, union recv_frame *prframe)
 	int	a_len, padding_len;
 	u16	eth_type, nSubframe_Length;
 	u8	nr_subframes, i;
-	unsigned char *data_ptr, *pdata;
+	unsigned char *pdata;
 	struct rx_pkt_attrib *pattrib;
 	_pkt *sub_skb, *subframes[MAX_SUBFRAME_COUNT];
 	struct recv_priv *precvpriv = &padapter->recvpriv;
@@ -372,7 +372,7 @@ static int amsdu_to_msdu(struct _adapter *padapter, union recv_frame *prframe)
 		if (!sub_skb)
 			break;
 		skb_reserve(sub_skb, 12);
-		data_ptr = skb_put_data(sub_skb, pdata, nSubframe_Length);
+		skb_put_data(sub_skb, pdata, nSubframe_Length);
 		subframes[nr_subframes++] = sub_skb;
 		if (nr_subframes >= MAX_SUBFRAME_COUNT) {
 			netdev_warn(padapter->pnetdev, "r8712u: ParseSubframe(): Too many Subframes! Packets dropped!\n");
diff --git a/drivers/staging/rtl8723bs/os_dep/recv_linux.c b/drivers/staging/rtl8723bs/os_dep/recv_linux.c
index 1a6443d..f42e000 100644
--- a/drivers/staging/rtl8723bs/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8723bs/os_dep/recv_linux.c
@@ -72,7 +72,6 @@ int rtw_os_recvbuf_resource_free(struct adapter *padapter, struct recv_buf *prec
 _pkt *rtw_os_alloc_msdu_pkt(union recv_frame *prframe, u16 nSubframe_Length, u8 *pdata)
 {
 	u16 eth_type;
-	u8 *data_ptr;
 	_pkt *sub_skb;
 	struct rx_pkt_attrib *pattrib;
 
@@ -82,8 +81,7 @@ _pkt *rtw_os_alloc_msdu_pkt(union recv_frame *prframe, u16 nSubframe_Length, u8
 	if (sub_skb)
 	{
 		skb_reserve(sub_skb, 12);
-		data_ptr = skb_put_data(sub_skb, (pdata + ETH_HLEN),
-					nSubframe_Length);
+		skb_put_data(sub_skb, (pdata + ETH_HLEN), nSubframe_Length);
 	}
 	else
 	{
diff --git a/drivers/staging/wlan-ng/hfa384x_usb.c b/drivers/staging/wlan-ng/hfa384x_usb.c
index 1de67f2..83ea8ab 100644
--- a/drivers/staging/wlan-ng/hfa384x_usb.c
+++ b/drivers/staging/wlan-ng/hfa384x_usb.c
@@ -3530,7 +3530,7 @@ static void hfa384x_int_rxmonitor(struct wlandevice *wlandev,
 	/* Copy the 802.11 header to the skb
 	 * (ctl frames may be less than a full header)
 	 */
-	datap = skb_put_data(skb, &rxdesc->frame_control, hdrlen);
+	skb_put_data(skb, &rxdesc->frame_control, hdrlen);
 
 	/* If any, copy the data from the card to the skb */
 	if (datalen > 0) {
diff --git a/drivers/usb/gadget/function/f_ncm.c b/drivers/usb/gadget/function/f_ncm.c
index a9c28c7..24e34cf 100644
--- a/drivers/usb/gadget/function/f_ncm.c
+++ b/drivers/usb/gadget/function/f_ncm.c
@@ -1004,16 +1004,15 @@ static struct sk_buff *package_for_tx(struct f_ncm *ncm)
 	}
 
 	/* Insert NDP alignment. */
-	ntb_iter = skb_put_zero(skb2, ndp_pad);
+	skb_put_zero(skb2, ndp_pad);
 
 	/* Copy NTB across. */
-	ntb_iter = skb_put_data(skb2, ncm->skb_tx_ndp->data,
-				ncm->skb_tx_ndp->len);
+	skb_put_data(skb2, ncm->skb_tx_ndp->data, ncm->skb_tx_ndp->len);
 	dev_consume_skb_any(ncm->skb_tx_ndp);
 	ncm->skb_tx_ndp = NULL;
 
 	/* Insert zero'd datagram. */
-	ntb_iter = skb_put_zero(skb2, dgram_idx_len);
+	skb_put_zero(skb2, dgram_idx_len);
 
 	return skb2;
 }
@@ -1127,8 +1126,8 @@ static struct sk_buff *ncm_wrap_ntb(struct gether *port,
 		ncm->ndp_dgram_count++;
 
 		/* Add the new data to the skb */
-		ntb_data = skb_put_zero(ncm->skb_tx_data, dgram_pad);
-		ntb_data = skb_put_data(ncm->skb_tx_data, skb->data, skb->len);
+		skb_put_zero(ncm->skb_tx_data, dgram_pad);
+		skb_put_data(ncm->skb_tx_data, skb->data, skb->len);
 		dev_consume_skb_any(skb);
 		skb = NULL;
 
diff --git a/lib/nlattr.c b/lib/nlattr.c
index a0c738a..fb52435 100644
--- a/lib/nlattr.c
+++ b/lib/nlattr.c
@@ -398,11 +398,7 @@ EXPORT_SYMBOL(__nla_reserve_64bit);
  */
 void *__nla_reserve_nohdr(struct sk_buff *skb, int attrlen)
 {
-	void *start;
-
-	start = skb_put_zero(skb, NLA_ALIGN(attrlen));
-
-	return start;
+	return skb_put_zero(skb, NLA_ALIGN(attrlen));
 }
 EXPORT_SYMBOL(__nla_reserve_nohdr);
 
diff --git a/net/bridge/netfilter/nft_reject_bridge.c b/net/bridge/netfilter/nft_reject_bridge.c
index a05775a..eaf05de 100644
--- a/net/bridge/netfilter/nft_reject_bridge.c
+++ b/net/bridge/netfilter/nft_reject_bridge.c
@@ -107,7 +107,6 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 	struct iphdr *niph;
 	struct icmphdr *icmph;
 	unsigned int len;
-	void *payload;
 	__wsum csum;
 	u8 proto;
 
@@ -151,7 +150,7 @@ static void nft_reject_br_send_v4_unreach(struct net *net,
 	icmph->type     = ICMP_DEST_UNREACH;
 	icmph->code	= code;
 
-	payload = skb_put_data(nskb, skb_network_header(oldskb), len);
+	skb_put_data(nskb, skb_network_header(oldskb), len);
 
 	csum = csum_partial((void *)icmph, len + sizeof(struct icmphdr), 0);
 	icmph->checksum = csum_fold(csum);
@@ -247,7 +246,6 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 	struct ipv6hdr *nip6h;
 	struct icmp6hdr *icmp6h;
 	unsigned int len;
-	void *payload;
 
 	if (!nft_bridge_ip6hdr_validate(oldskb))
 		return;
@@ -277,7 +275,7 @@ static void nft_reject_br_send_v6_unreach(struct net *net,
 	icmp6h->icmp6_type = ICMPV6_DEST_UNREACH;
 	icmp6h->icmp6_code = code;
 
-	payload = skb_put_data(nskb, skb_network_header(oldskb), len);
+	skb_put_data(nskb, skb_network_header(oldskb), len);
 	nip6h->payload_len = htons(nskb->len - sizeof(struct ipv6hdr));
 
 	icmp6h->icmp6_cksum =
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 172f131..b09e562 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -43,8 +43,7 @@ static struct sk_buff *trailer_xmit(struct sk_buff *skb, struct net_device *dev)
 	kfree_skb(skb);
 
 	if (padlen) {
-		u8 *pad = skb_put(nskb, padlen);
-		memset(pad, 0, padlen);
+		skb_put_zero(nskb, padlen);
 	}
 
 	trailer = skb_put(nskb, 4);
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 0a0a392..4e7bdb2 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -284,12 +284,12 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	skb_reset_mac_header(skb);
 
 	if (hsrVer > 0) {
-		hsr_tag = (typeof(hsr_tag)) skb_put(skb, sizeof(struct hsr_tag));
+		hsr_tag = skb_put(skb, sizeof(struct hsr_tag));
 		hsr_tag->encap_proto = htons(ETH_P_PRP);
 		set_hsr_tag_LSDU_size(hsr_tag, HSR_V1_SUP_LSDUSIZE);
 	}
 
-	hsr_stag = (typeof(hsr_stag)) skb_put(skb, sizeof(struct hsr_sup_tag));
+	hsr_stag = skb_put(skb, sizeof(struct hsr_sup_tag));
 	set_hsr_stag_path(hsr_stag, (hsrVer ? 0x0 : 0xf));
 	set_hsr_stag_HSR_Ver(hsr_stag, hsrVer);
 
@@ -311,7 +311,7 @@ static void send_hsr_supervision_frame(struct hsr_port *master,
 	hsr_stag->HSR_TLV_Length = hsrVer ? sizeof(struct hsr_sup_payload) : 12;
 
 	/* Payload: MacAddressA */
-	hsr_sp = (typeof(hsr_sp)) skb_put(skb, sizeof(struct hsr_sup_payload));
+	hsr_sp = skb_put(skb, sizeof(struct hsr_sup_payload));
 	ether_addr_copy(hsr_sp->MacAddressA, master->dev->dev_addr);
 
 	skb_put_padto(skb, ETH_ZLEN + HSR_HLEN);
diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 82e71e5..debda3d 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -392,7 +392,7 @@ void irlap_send_discovery_xid_frame(struct irlap_cb *self, int S, __u8 s,
 		info[0] = discovery->data.charset;
 
 		len = IRDA_MIN(discovery->name_len, skb_tailroom(tx_skb));
-		info = skb_put_data(tx_skb, discovery->data.info, len);
+		skb_put_data(tx_skb, discovery->data.info, len);
 	}
 	irlap_queue_xmit(self, tx_skb);
 }
@@ -1194,7 +1194,6 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 {
 	struct sk_buff *tx_skb;
 	struct test_frame *frame;
-	__u8 *info;
 
 	tx_skb = alloc_skb(cmd->len + sizeof(struct test_frame), GFP_ATOMIC);
 	if (!tx_skb)
@@ -1214,7 +1213,7 @@ void irlap_send_test_frame(struct irlap_cb *self, __u8 caddr, __u32 daddr,
 	frame->control = TEST_RSP | PF_BIT;
 
 	/* Copy info */
-	info = skb_put_data(tx_skb, cmd->data, cmd->len);
+	skb_put_data(tx_skb, cmd->data, cmd->len);
 
 	/* Return to sender */
 	irlap_wait_min_turn_around(self, &self->qos_tx);
diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 7be7917..b588e59 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -796,8 +796,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 						 after_ric,
 						 ARRAY_SIZE(after_ric),
 						 offset);
-		pos = skb_put_data(skb, assoc_data->ie + offset,
-				   noffset - offset);
+		skb_put_data(skb, assoc_data->ie + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -834,8 +833,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 		noffset = ieee80211_ie_split(assoc_data->ie, assoc_data->ie_len,
 					     before_vht, ARRAY_SIZE(before_vht),
 					     offset);
-		pos = skb_put_data(skb, assoc_data->ie + offset,
-				   noffset - offset);
+		skb_put_data(skb, assoc_data->ie + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -848,8 +846,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 		noffset = ieee80211_ie_split_vendor(assoc_data->ie,
 						    assoc_data->ie_len,
 						    offset);
-		pos = skb_put_data(skb, assoc_data->ie + offset,
-				   noffset - offset);
+		skb_put_data(skb, assoc_data->ie + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -868,8 +865,7 @@ static void ieee80211_send_assoc(struct ieee80211_sub_if_data *sdata)
 	/* add any remaining custom (i.e. vendor specific here) IEs */
 	if (assoc_data->ie_len) {
 		noffset = assoc_data->ie_len;
-		pos = skb_put_data(skb, assoc_data->ie + offset,
-				   noffset - offset);
+		skb_put_data(skb, assoc_data->ie + offset, noffset - offset);
 	}
 
 	if (assoc_data->fils_kek_len &&
diff --git a/net/mac80211/tdls.c b/net/mac80211/tdls.c
index 709ef02..91093d4 100644
--- a/net/mac80211/tdls.c
+++ b/net/mac80211/tdls.c
@@ -388,7 +388,7 @@ ieee80211_tdls_add_setup_start_ies(struct ieee80211_sub_if_data *sdata,
 					     before_ext_cap,
 					     ARRAY_SIZE(before_ext_cap),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -417,7 +417,7 @@ ieee80211_tdls_add_setup_start_ies(struct ieee80211_sub_if_data *sdata,
 					     before_ht_cap,
 					     ARRAY_SIZE(before_ht_cap),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -488,7 +488,7 @@ ieee80211_tdls_add_setup_start_ies(struct ieee80211_sub_if_data *sdata,
 					     before_vht_cap,
 					     ARRAY_SIZE(before_vht_cap),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -529,7 +529,7 @@ ieee80211_tdls_add_setup_start_ies(struct ieee80211_sub_if_data *sdata,
 	/* add any remaining IEs */
 	if (extra_ies_len) {
 		noffset = extra_ies_len;
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 	}
 
 }
@@ -571,7 +571,7 @@ ieee80211_tdls_add_setup_cfm_ies(struct ieee80211_sub_if_data *sdata,
 					     before_qos,
 					     ARRAY_SIZE(before_qos),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -591,7 +591,7 @@ ieee80211_tdls_add_setup_cfm_ies(struct ieee80211_sub_if_data *sdata,
 					     before_ht_op,
 					     ARRAY_SIZE(before_ht_op),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -632,7 +632,7 @@ ieee80211_tdls_add_setup_cfm_ies(struct ieee80211_sub_if_data *sdata,
 	/* add any remaining IEs */
 	if (extra_ies_len) {
 		noffset = extra_ies_len;
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 	}
 }
 
@@ -645,7 +645,6 @@ ieee80211_tdls_add_chan_switch_req_ies(struct ieee80211_sub_if_data *sdata,
 {
 	struct ieee80211_tdls_data *tf;
 	size_t offset = 0, noffset;
-	u8 *pos;
 
 	if (WARN_ON_ONCE(!chandef))
 		return;
@@ -663,7 +662,7 @@ ieee80211_tdls_add_chan_switch_req_ies(struct ieee80211_sub_if_data *sdata,
 					     before_lnkie,
 					     ARRAY_SIZE(before_lnkie),
 					     offset);
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 		offset = noffset;
 	}
 
@@ -672,7 +671,7 @@ ieee80211_tdls_add_chan_switch_req_ies(struct ieee80211_sub_if_data *sdata,
 	/* add any remaining IEs */
 	if (extra_ies_len) {
 		noffset = extra_ies_len;
-		pos = skb_put_data(skb, extra_ies + offset, noffset - offset);
+		skb_put_data(skb, extra_ies + offset, noffset - offset);
 	}
 }
 
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 2c196b3..4b19679 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -1474,11 +1474,10 @@ void sctp_chunk_put(struct sctp_chunk *ch)
 void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
 {
 	void *target;
-	void *padding;
 	int chunklen = ntohs(chunk->chunk_hdr->length);
 	int padlen = SCTP_PAD4(chunklen) - chunklen;
 
-	padding = skb_put_zero(chunk->skb, padlen);
+	skb_put_zero(chunk->skb, padlen);
 	target = skb_put_data(chunk->skb, data, len);
 
 	/* Adjust the chunk length field.  */
diff --git a/net/vmw_vsock/virtio_transport_common.c b/net/vmw_vsock/virtio_transport_common.c
index 7d6ee03..edba7ab 100644
--- a/net/vmw_vsock/virtio_transport_common.c
+++ b/net/vmw_vsock/virtio_transport_common.c
@@ -90,7 +90,6 @@ virtio_transport_alloc_pkt(struct virtio_vsock_pkt_info *info,
 static struct sk_buff *virtio_transport_build_skb(void *opaque)
 {
 	struct virtio_vsock_pkt *pkt = opaque;
-	unsigned char *t_hdr, *payload;
 	struct af_vsockmon_hdr *hdr;
 	struct sk_buff *skb;
 
@@ -132,10 +131,10 @@ static struct sk_buff *virtio_transport_build_skb(void *opaque)
 		break;
 	}
 
-	t_hdr = skb_put_data(skb, &pkt->hdr, sizeof(pkt->hdr));
+	skb_put_data(skb, &pkt->hdr, sizeof(pkt->hdr));
 
 	if (pkt->len) {
-		payload = skb_put_data(skb, pkt->buf, pkt->len);
+		skb_put_data(skb, pkt->buf, pkt->len);
 	}
 
 	return skb;
diff --git a/net/x25/x25_subr.c b/net/x25/x25_subr.c
index eb466ec..db0b131 100644
--- a/net/x25/x25_subr.c
+++ b/net/x25/x25_subr.c
@@ -188,14 +188,14 @@ void x25_write_internal(struct sock *sk, int frametype)
 			*dptr++ = X25_CALL_REQUEST;
 			len     = x25_addr_aton(addresses, &x25->dest_addr,
 						&x25->source_addr);
-			dptr = skb_put_data(skb, addresses, len);
+			skb_put_data(skb, addresses, len);
 			len     = x25_create_facilities(facilities,
 					&x25->facilities,
 					&x25->dte_facilities,
 					x25->neighbour->global_facil_mask);
-			dptr = skb_put_data(skb, facilities, len);
-			dptr = skb_put_data(skb, x25->calluserdata.cuddata,
-					    x25->calluserdata.cudlength);
+			skb_put_data(skb, facilities, len);
+			skb_put_data(skb, x25->calluserdata.cuddata,
+				     x25->calluserdata.cudlength);
 			x25->calluserdata.cudlength = 0;
 			break;
 
@@ -207,15 +207,15 @@ void x25_write_internal(struct sock *sk, int frametype)
 							&x25->facilities,
 							&x25->dte_facilities,
 							x25->vc_facil_mask);
-			dptr = skb_put_data(skb, facilities, len);
+			skb_put_data(skb, facilities, len);
 
 			/* fast select with no restriction on response
 				allows call user data. Userland must
 				ensure it is ours and not theirs */
 			if(x25->facilities.reverse & 0x80) {
-				dptr = skb_put_data(skb,
-						    x25->calluserdata.cuddata,
-						    x25->calluserdata.cudlength);
+				skb_put_data(skb,
+					     x25->calluserdata.cuddata,
+					     x25->calluserdata.cudlength);
 			}
 			x25->calluserdata.cudlength = 0;
 			break;
-- 
2.7.4
