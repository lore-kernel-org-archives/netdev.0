From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 2/3] wireless: Remove casts to same type
Date: Mon,  4 Jun 2012 15:44:17 -0700
Message-ID: <932258ce13f4943c8c376c5109178a3575015d97.1338849366.git.joe@perches.com>
References: <cover.1338849364.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46545 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757393Ab2FDWoi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 18:44:38 -0400
In-Reply-To: <cover.1338849364.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding casts of objects to the same type is unnecessary
and confusing for a human reader.

For example, this cast:

        int y;
        int *p = (int *)&y;

I used the coccinelle script below to find and remove these
unnecessary casts.  I manually removed the conversions this
script produces of casts with __force, __iomem and __user.

@@
type T;
T *p;
@@

-       (T *)p
+       p

Neatened the mwifiex_deauthenticate_infra function which
was doing odd things with array pointers and not using
is_zero_ether_addr.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/adm8211.c                     |    3 +-
 drivers/net/wireless/airo.c                        |    4 +-
 drivers/net/wireless/ath/ath9k/ar9003_eeprom.c     |    4 +-
 drivers/net/wireless/ath/ath9k/eeprom_4k.c         |    3 +-
 drivers/net/wireless/ath/ath9k/eeprom_def.c        |    3 +-
 drivers/net/wireless/ath/carl9170/cmd.c            |    2 +-
 drivers/net/wireless/ath/carl9170/rx.c             |    4 +-
 drivers/net/wireless/atmel.c                       |    4 +-
 drivers/net/wireless/b43legacy/dma.c               |    2 +-
 drivers/net/wireless/b43legacy/xmit.c              |    6 +--
 drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c |    4 +-
 drivers/net/wireless/brcm80211/brcmsmac/dma.c      |    2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c     |    2 +-
 drivers/net/wireless/hostap/hostap_proc.c          |    3 +-
 drivers/net/wireless/ipw2x00/ipw2200.c             |    4 +-
 drivers/net/wireless/iwlwifi/iwl-testmode.c        |    2 +-
 drivers/net/wireless/iwlwifi/iwl-trans-pcie.c      |    2 +-
 drivers/net/wireless/libertas/debugfs.c            |    4 +-
 drivers/net/wireless/libertas/if_usb.c             |    2 +-
 drivers/net/wireless/libertas_tf/if_usb.c          |    2 +-
 drivers/net/wireless/mwifiex/11n.c                 |   14 ++----
 drivers/net/wireless/mwifiex/11n.h                 |    3 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |   18 ++------
 drivers/net/wireless/mwifiex/cfg80211.c            |    2 +-
 drivers/net/wireless/mwifiex/join.c                |   20 +++------
 drivers/net/wireless/mwifiex/scan.c                |   24 ++++------
 drivers/net/wireless/mwifiex/sta_cmd.c             |   16 ++-----
 drivers/net/wireless/mwifiex/sta_cmdresp.c         |   24 ++++------
 drivers/net/wireless/mwifiex/sta_event.c           |    2 +-
 drivers/net/wireless/p54/eeprom.c                  |    2 +-
 drivers/net/wireless/p54/fwio.c                    |    2 +-
 drivers/net/wireless/prism54/islpci_eth.c          |    2 +-
 drivers/net/wireless/ray_cs.c                      |    2 +-
 drivers/net/wireless/rtlwifi/base.c                |    2 +-
 drivers/net/wireless/rtlwifi/cam.c                 |    2 +-
 drivers/net/wireless/rtlwifi/core.c                |   14 +++---
 drivers/net/wireless/rtlwifi/efuse.c               |    4 +-
 drivers/net/wireless/rtlwifi/pci.c                 |   14 +++---
 drivers/net/wireless/rtlwifi/ps.c                  |   10 ++--
 drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c  |    5 +-
 drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c  |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192ce/hw.c        |   43 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c       |    4 +-
 drivers/net/wireless/rtlwifi/rtl8192cu/hw.c        |   43 +++++++++---------
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c       |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192de/fw.c        |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192de/hw.c        |   34 +++++++-------
 drivers/net/wireless/rtlwifi/rtl8192de/trx.c       |    6 +-
 drivers/net/wireless/rtlwifi/rtl8192se/dm.c        |    2 +-
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |   46 +++++++++----------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c       |    2 +-
 drivers/net/wireless/ti/wlcore/tx.c                |    3 +-
 drivers/net/wireless/zd1211rw/zd_chip.h            |    2 +-
 drivers/net/wireless/zd1211rw/zd_usb.h             |    2 +-
 55 files changed, 198 insertions(+), 247 deletions(-)

diff --git a/drivers/net/wireless/adm8211.c b/drivers/net/wireless/adm8211.c
index 0ac09a2..97afcec 100644
--- a/drivers/net/wireless/adm8211.c
+++ b/drivers/net/wireless/adm8211.c
@@ -1738,8 +1738,7 @@ static int adm8211_alloc_rings(struct ieee80211_hw *dev)
 		return -ENOMEM;
 	}
 
-	priv->tx_ring = (struct adm8211_desc *)(priv->rx_ring +
-						priv->rx_ring_size);
+	priv->tx_ring = priv->rx_ring + priv->rx_ring_size;
 	priv->tx_ring_dma = priv->rx_ring_dma +
 			    sizeof(struct adm8211_desc) * priv->rx_ring_size;
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index 520a4b2..252c2c2 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -1997,7 +1997,7 @@ static int mpi_send_packet (struct net_device *dev)
  *                         ------------------------------------------------
  */
 
-	memcpy((char *)ai->txfids[0].virtual_host_addr,
+	memcpy(ai->txfids[0].virtual_host_addr,
 		(char *)&wifictlhdr8023, sizeof(wifictlhdr8023));
 
 	payloadLen = (__le16 *)(ai->txfids[0].virtual_host_addr +
@@ -4212,7 +4212,7 @@ static int PC4500_writerid(struct airo_info *ai, u16 rid,
 			airo_print_err(ai->dev->name, "%s: len=%d", __func__, len);
 			rc = -1;
 		} else {
-			memcpy((char *)ai->config_desc.virtual_host_addr,
+			memcpy(ai->config_desc.virtual_host_addr,
 				pBuf, len);
 
 			rc = issuecommand(ai, &cmd, &rsp);
diff --git a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
index dfb0441..ca88155 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_eeprom.c
@@ -3178,7 +3178,7 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 				mdata_size, length);
 			return -1;
 		}
-		memcpy(mptr, (u8 *) (word + COMP_HDR_LEN), length);
+		memcpy(mptr, word + COMP_HDR_LEN, length);
 		ath_dbg(common, EEPROM,
 			"restored eeprom %d: uncompressed, length %d\n",
 			it, length);
@@ -3199,7 +3199,7 @@ static int ar9300_compress_decision(struct ath_hw *ah,
 			"restore eeprom %d: block, reference %d, length %d\n",
 			it, reference, length);
 		ar9300_uncompress_block(ah, mptr, mdata_size,
-					(u8 *) (word + COMP_HDR_LEN), length);
+					(word + COMP_HDR_LEN), length);
 		break;
 	default:
 		ath_dbg(common, EEPROM, "unknown compression code %d\n", code);
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_4k.c b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
index 4322ac8..92543d1 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_4k.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_4k.c
@@ -188,8 +188,7 @@ static int ath9k_hw_4k_check_eeprom(struct ath_hw *ah)
 {
 #define EEPROM_4K_SIZE (sizeof(struct ar5416_eeprom_4k) / sizeof(u16))
 	struct ath_common *common = ath9k_hw_common(ah);
-	struct ar5416_eeprom_4k *eep =
-		(struct ar5416_eeprom_4k *) &ah->eeprom.map4k;
+	struct ar5416_eeprom_4k *eep = &ah->eeprom.map4k;
 	u16 *eepdata, temp, magic, magic2;
 	u32 sum = 0, el;
 	bool need_swap = false;
diff --git a/drivers/net/wireless/ath/ath9k/eeprom_def.c b/drivers/net/wireless/ath/ath9k/eeprom_def.c
index b5fba8b..a9f071b 100644
--- a/drivers/net/wireless/ath/ath9k/eeprom_def.c
+++ b/drivers/net/wireless/ath/ath9k/eeprom_def.c
@@ -264,8 +264,7 @@ static u32 ath9k_hw_def_dump_eeprom(struct ath_hw *ah, bool dump_base_hdr,
 
 static int ath9k_hw_def_check_eeprom(struct ath_hw *ah)
 {
-	struct ar5416_eeprom_def *eep =
-		(struct ar5416_eeprom_def *) &ah->eeprom.def;
+	struct ar5416_eeprom_def *eep = &ah->eeprom.def;
 	struct ath_common *common = ath9k_hw_common(ah);
 	u16 *eepdata, temp, magic, magic2;
 	u32 sum = 0, el;
diff --git a/drivers/net/wireless/ath/carl9170/cmd.c b/drivers/net/wireless/ath/carl9170/cmd.c
index 195dc65..39a6387 100644
--- a/drivers/net/wireless/ath/carl9170/cmd.c
+++ b/drivers/net/wireless/ath/carl9170/cmd.c
@@ -138,7 +138,7 @@ int carl9170_reboot(struct ar9170 *ar)
 	if (!cmd)
 		return -ENOMEM;
 
-	err = __carl9170_exec_cmd(ar, (struct carl9170_cmd *)cmd, true);
+	err = __carl9170_exec_cmd(ar, cmd, true);
 	return err;
 }
 
diff --git a/drivers/net/wireless/ath/carl9170/rx.c b/drivers/net/wireless/ath/carl9170/rx.c
index 84b22ee..7a8e90e 100644
--- a/drivers/net/wireless/ath/carl9170/rx.c
+++ b/drivers/net/wireless/ath/carl9170/rx.c
@@ -161,7 +161,7 @@ static void carl9170_cmd_callback(struct ar9170 *ar, u32 len, void *buffer)
 
 void carl9170_handle_command_response(struct ar9170 *ar, void *buf, u32 len)
 {
-	struct carl9170_rsp *cmd = (void *) buf;
+	struct carl9170_rsp *cmd = buf;
 	struct ieee80211_vif *vif;
 
 	if (carl9170_check_sequence(ar, cmd->hdr.seq))
@@ -520,7 +520,7 @@ static u8 *carl9170_find_ie(u8 *data, unsigned int len, u8 ie)
  */
 static void carl9170_ps_beacon(struct ar9170 *ar, void *data, unsigned int len)
 {
-	struct ieee80211_hdr *hdr = (void *) data;
+	struct ieee80211_hdr *hdr = data;
 	struct ieee80211_tim_ie *tim_ie;
 	u8 *tim;
 	u8 tim_len;
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index d07c030..4a4e98f 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -2952,10 +2952,10 @@ static void send_association_request(struct atmel_private *priv, int is_reassoc)
 	/* current AP address - only in reassoc frame */
 	if (is_reassoc) {
 		memcpy(body.ap, priv->CurrentBSSID, 6);
-		ssid_el_p = (u8 *)&body.ssid_el_id;
+		ssid_el_p = &body.ssid_el_id;
 		bodysize = 18 + priv->SSID_size;
 	} else {
-		ssid_el_p = (u8 *)&body.ap[0];
+		ssid_el_p = &body.ap[0];
 		bodysize = 12 + priv->SSID_size;
 	}
 
diff --git a/drivers/net/wireless/b43legacy/dma.c b/drivers/net/wireless/b43legacy/dma.c
index f1f8bd0..ff50cb4 100644
--- a/drivers/net/wireless/b43legacy/dma.c
+++ b/drivers/net/wireless/b43legacy/dma.c
@@ -52,7 +52,7 @@ struct b43legacy_dmadesc32 *op32_idx2desc(struct b43legacy_dmaring *ring,
 	desc = ring->descbase;
 	desc = &(desc[slot]);
 
-	return (struct b43legacy_dmadesc32 *)desc;
+	return desc;
 }
 
 static void op32_fill_descriptor(struct b43legacy_dmaring *ring,
diff --git a/drivers/net/wireless/b43legacy/xmit.c b/drivers/net/wireless/b43legacy/xmit.c
index a8012f2..b8ffea6 100644
--- a/drivers/net/wireless/b43legacy/xmit.c
+++ b/drivers/net/wireless/b43legacy/xmit.c
@@ -269,8 +269,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 	b43legacy_generate_plcp_hdr((struct b43legacy_plcp_hdr4 *)
 				    (&txhdr->plcp), plcp_fragment_len,
 				    rate);
-	b43legacy_generate_plcp_hdr((struct b43legacy_plcp_hdr4 *)
-				    (&txhdr->plcp_fb), plcp_fragment_len,
+	b43legacy_generate_plcp_hdr(&txhdr->plcp_fb, plcp_fragment_len,
 				    rate_fb->hw_value);
 
 	/* PHY TX Control word */
@@ -340,8 +339,7 @@ static int generate_txhdr_fw3(struct b43legacy_wldev *dev,
 		b43legacy_generate_plcp_hdr((struct b43legacy_plcp_hdr4 *)
 					    (&txhdr->rts_plcp),
 					    len, rts_rate);
-		b43legacy_generate_plcp_hdr((struct b43legacy_plcp_hdr4 *)
-					    (&txhdr->rts_plcp_fb),
+		b43legacy_generate_plcp_hdr(&txhdr->rts_plcp_fb,
 					    len, rts_rate_fb);
 		hdr = (struct ieee80211_hdr *)(&txhdr->rts_frame);
 		txhdr->rts_dur_fb = hdr->duration_id;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
index 1dbf2be..4deae28 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/dhd_sdio.c
@@ -2502,7 +2502,7 @@ clkwait:
 		int ret, i;
 
 		ret = brcmf_sdcard_send_buf(bus->sdiodev, bus->sdiodev->sbwad,
-			SDIO_FUNC_2, F2SYNC, (u8 *) bus->ctrl_frame_buf,
+			SDIO_FUNC_2, F2SYNC, bus->ctrl_frame_buf,
 			(u32) bus->ctrl_frame_len);
 
 		if (ret < 0) {
@@ -3327,7 +3327,7 @@ static int brcmf_sdbrcm_download_nvram(struct brcmf_sdio *bus)
 	len = brcmf_sdbrcm_get_image(memblock, MEMBLOCK, bus);
 
 	if (len > 0 && len < MEMBLOCK) {
-		bufp = (char *)memblock;
+		bufp = memblock;
 		bufp[len] = 0;
 		len = brcmf_process_nvram_vars(bufp, len);
 		bufp += len;
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/dma.c b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
index 11054ae..7516639 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/dma.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/dma.c
@@ -1433,7 +1433,7 @@ void dma_walk_packets(struct dma_pub *dmah, void (*callback_fnc)
 	struct ieee80211_tx_info *tx_info;
 
 	while (i != end) {
-		skb = (struct sk_buff *)di->txp[i];
+		skb = di->txp[i];
 		if (skb != NULL) {
 			tx_info = (struct ieee80211_tx_info *)skb->cb;
 			(callback_fnc)(tx_info, arg_a);
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 19db405..e675567 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -8318,7 +8318,7 @@ brcms_c_attach(struct brcms_info *wl, struct bcma_device *core, uint unit,
 	struct brcms_pub *pub;
 
 	/* allocate struct brcms_c_info state and its substructures */
-	wlc = (struct brcms_c_info *) brcms_c_attach_malloc(unit, &err, 0);
+	wlc = brcms_c_attach_malloc(unit, &err, 0);
 	if (wlc == NULL)
 		goto fail;
 	wlc->wiphy = wl->wiphy;
diff --git a/drivers/net/wireless/hostap/hostap_proc.c b/drivers/net/wireless/hostap/hostap_proc.c
index 75ef8f0..dc447c1 100644
--- a/drivers/net/wireless/hostap/hostap_proc.c
+++ b/drivers/net/wireless/hostap/hostap_proc.c
@@ -58,8 +58,7 @@ static int prism2_stats_proc_read(char *page, char **start, off_t off,
 {
 	char *p = page;
 	local_info_t *local = (local_info_t *) data;
-	struct comm_tallies_sums *sums = (struct comm_tallies_sums *)
-		&local->comm_tallies;
+	struct comm_tallies_sums *sums = &local->comm_tallies;
 
 	if (off != 0) {
 		*eof = 1;
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 0036737..afdec4a 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -7069,9 +7069,7 @@ static int ipw_qos_activate(struct ipw_priv *priv,
 	}
 
 	IPW_DEBUG_QOS("QoS sending IPW_CMD_QOS_PARAMETERS\n");
-	err = ipw_send_qos_params_command(priv,
-					  (struct libipw_qos_parameters *)
-					  &(qos_parameters[0]));
+	err = ipw_send_qos_params_command(priv, &qos_parameters[0]);
 	if (err)
 		IPW_DEBUG_QOS("QoS IPW_CMD_QOS_PARAMETERS failed\n");
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-testmode.c b/drivers/net/wireless/iwlwifi/iwl-testmode.c
index 060aac3..492e64f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-testmode.c
+++ b/drivers/net/wireless/iwlwifi/iwl-testmode.c
@@ -170,7 +170,7 @@ static void iwl_testmode_ucode_rx_pkt(struct iwl_priv *priv,
 	void *data;
 	int length;
 
-	data = (void *)rxb_addr(rxb);
+	data = rxb_addr(rxb);
 	length = get_event_length(rxb);
 
 	if (!data || length == 0)
diff --git a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
index ec6fb39..b849528 100644
--- a/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
+++ b/drivers/net/wireless/iwlwifi/iwl-trans-pcie.c
@@ -1354,7 +1354,7 @@ static int iwl_trans_pcie_tx(struct iwl_trans *trans, struct sk_buff *skb,
 			DMA_BIDIRECTIONAL);
 
 	trace_iwlwifi_dev_tx(trans->dev,
-			     &((struct iwl_tfd *)txq->tfds)[txq->q.write_ptr],
+			     &txq->tfds[txq->q.write_ptr],
 			     sizeof(struct iwl_tfd),
 			     &dev_cmd->hdr, firstlen,
 			     skb->data + hdr_len, secondlen);
diff --git a/drivers/net/wireless/libertas/debugfs.c b/drivers/net/wireless/libertas/debugfs.c
index a06cc28..668dd27 100644
--- a/drivers/net/wireless/libertas/debugfs.c
+++ b/drivers/net/wireless/libertas/debugfs.c
@@ -483,7 +483,7 @@ static ssize_t lbs_rdmac_write(struct file *file,
 		res = -EFAULT;
 		goto out_unlock;
 	}
-	priv->mac_offset = simple_strtoul((char *)buf, NULL, 16);
+	priv->mac_offset = simple_strtoul(buf, NULL, 16);
 	res = count;
 out_unlock:
 	free_page(addr);
@@ -565,7 +565,7 @@ static ssize_t lbs_rdbbp_write(struct file *file,
 		res = -EFAULT;
 		goto out_unlock;
 	}
-	priv->bbp_offset = simple_strtoul((char *)buf, NULL, 16);
+	priv->bbp_offset = simple_strtoul(buf, NULL, 16);
 	res = count;
 out_unlock:
 	free_page(addr);
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index cd3b0d4..64b7dc5 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -302,7 +302,7 @@ error:
 static void if_usb_disconnect(struct usb_interface *intf)
 {
 	struct if_usb_card *cardp = usb_get_intfdata(intf);
-	struct lbs_private *priv = (struct lbs_private *) cardp->priv;
+	struct lbs_private *priv = cardp->priv;
 
 	lbs_deb_enter(LBS_DEB_MAIN);
 
diff --git a/drivers/net/wireless/libertas_tf/if_usb.c b/drivers/net/wireless/libertas_tf/if_usb.c
index 19a5a92..d576dd6 100644
--- a/drivers/net/wireless/libertas_tf/if_usb.c
+++ b/drivers/net/wireless/libertas_tf/if_usb.c
@@ -253,7 +253,7 @@ lbtf_deb_leave(LBTF_DEB_MAIN);
 static void if_usb_disconnect(struct usb_interface *intf)
 {
 	struct if_usb_card *cardp = usb_get_intfdata(intf);
-	struct lbtf_private *priv = (struct lbtf_private *) cardp->priv;
+	struct lbtf_private *priv = cardp->priv;
 
 	lbtf_deb_enter(LBTF_DEB_MAIN);
 
diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
index fe8ebfe..e535c93 100644
--- a/drivers/net/wireless/mwifiex/11n.c
+++ b/drivers/net/wireless/mwifiex/11n.c
@@ -101,8 +101,7 @@ int mwifiex_ret_11n_delba(struct mwifiex_private *priv,
 {
 	int tid;
 	struct mwifiex_tx_ba_stream_tbl *tx_ba_tbl;
-	struct host_cmd_ds_11n_delba *del_ba =
-		(struct host_cmd_ds_11n_delba *) &resp->params.del_ba;
+	struct host_cmd_ds_11n_delba *del_ba = &resp->params.del_ba;
 	uint16_t del_ba_param_set = le16_to_cpu(del_ba->del_ba_param_set);
 
 	tid = del_ba_param_set >> DELBA_TID_POS;
@@ -147,8 +146,7 @@ int mwifiex_ret_11n_addba_req(struct mwifiex_private *priv,
 			      struct host_cmd_ds_command *resp)
 {
 	int tid;
-	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp =
-		(struct host_cmd_ds_11n_addba_rsp *) &resp->params.add_ba_rsp;
+	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp = &resp->params.add_ba_rsp;
 	struct mwifiex_tx_ba_stream_tbl *tx_ba_tbl;
 
 	add_ba_rsp->ssn = cpu_to_le16((le16_to_cpu(add_ba_rsp->ssn))
@@ -412,7 +410,7 @@ mwifiex_cmd_append_11n_tlv(struct mwifiex_private *priv,
 
 		memcpy((u8 *) bss_co_2040 +
 		       sizeof(struct mwifiex_ie_types_header),
-		       (u8 *) bss_desc->bcn_bss_co_2040 +
+		       bss_desc->bcn_bss_co_2040 +
 		       sizeof(struct ieee_types_header),
 		       le16_to_cpu(bss_co_2040->header.len));
 
@@ -426,10 +424,8 @@ mwifiex_cmd_append_11n_tlv(struct mwifiex_private *priv,
 		ext_cap->header.type = cpu_to_le16(WLAN_EID_EXT_CAPABILITY);
 		ext_cap->header.len = cpu_to_le16(sizeof(ext_cap->ext_cap));
 
-		memcpy((u8 *) ext_cap +
-		       sizeof(struct mwifiex_ie_types_header),
-		       (u8 *) bss_desc->bcn_ext_cap +
-		       sizeof(struct ieee_types_header),
+		memcpy((u8 *)ext_cap + sizeof(struct mwifiex_ie_types_header),
+		       bss_desc->bcn_ext_cap + sizeof(struct ieee_types_header),
 		       le16_to_cpu(ext_cap->header.len));
 
 		*buffer += sizeof(struct mwifiex_ie_types_extcap);
diff --git a/drivers/net/wireless/mwifiex/11n.h b/drivers/net/wireless/mwifiex/11n.h
index 77646d7..28366e9 100644
--- a/drivers/net/wireless/mwifiex/11n.h
+++ b/drivers/net/wireless/mwifiex/11n.h
@@ -105,8 +105,7 @@ static inline u8 mwifiex_space_avail_for_new_ba_stream(
 		priv = adapter->priv[i];
 		if (priv)
 			ba_stream_num += mwifiex_wmm_list_len(
-						(struct list_head *)
-						&priv->tx_ba_stream_tbl_ptr);
+				&priv->tx_ba_stream_tbl_ptr);
 	}
 
 	return ((ba_stream_num <
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index 9c44088..89f7c57 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -296,9 +296,7 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
  */
 int mwifiex_cmd_11n_addba_req(struct host_cmd_ds_command *cmd, void *data_buf)
 {
-	struct host_cmd_ds_11n_addba_req *add_ba_req =
-		(struct host_cmd_ds_11n_addba_req *)
-		&cmd->params.add_ba_req;
+	struct host_cmd_ds_11n_addba_req *add_ba_req = &cmd->params.add_ba_req;
 
 	cmd->command = cpu_to_le16(HostCmd_CMD_11N_ADDBA_REQ);
 	cmd->size = cpu_to_le16(sizeof(*add_ba_req) + S_DS_GEN);
@@ -320,9 +318,7 @@ int mwifiex_cmd_11n_addba_rsp_gen(struct mwifiex_private *priv,
 				  struct host_cmd_ds_11n_addba_req
 				  *cmd_addba_req)
 {
-	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp =
-		(struct host_cmd_ds_11n_addba_rsp *)
-		&cmd->params.add_ba_rsp;
+	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp = &cmd->params.add_ba_rsp;
 	u8 tid;
 	int win_size;
 	uint16_t block_ack_param_set;
@@ -367,8 +363,7 @@ int mwifiex_cmd_11n_addba_rsp_gen(struct mwifiex_private *priv,
  */
 int mwifiex_cmd_11n_delba(struct host_cmd_ds_command *cmd, void *data_buf)
 {
-	struct host_cmd_ds_11n_delba *del_ba = (struct host_cmd_ds_11n_delba *)
-		&cmd->params.del_ba;
+	struct host_cmd_ds_11n_delba *del_ba = &cmd->params.del_ba;
 
 	cmd->command = cpu_to_le16(HostCmd_CMD_11N_DELBA);
 	cmd->size = cpu_to_le16(sizeof(*del_ba) + S_DS_GEN);
@@ -398,8 +393,7 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private *priv,
 	int start_win, end_win, win_size;
 	u16 pkt_index;
 
-	tbl = mwifiex_11n_get_rx_reorder_tbl((struct mwifiex_private *) priv,
-					     tid, ta);
+	tbl = mwifiex_11n_get_rx_reorder_tbl(priv, tid, ta);
 	if (!tbl) {
 		if (pkt_type != PKT_TYPE_BAR)
 			mwifiex_process_rx_packet(priv->adapter, payload);
@@ -520,9 +514,7 @@ mwifiex_del_ba_tbl(struct mwifiex_private *priv, int tid, u8 *peer_mac,
 int mwifiex_ret_11n_addba_resp(struct mwifiex_private *priv,
 			       struct host_cmd_ds_command *resp)
 {
-	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp =
-		(struct host_cmd_ds_11n_addba_rsp *)
-		&resp->params.add_ba_rsp;
+	struct host_cmd_ds_11n_addba_rsp *add_ba_rsp = &resp->params.add_ba_rsp;
 	int tid, win_size;
 	struct mwifiex_rx_reorder_tbl *tbl;
 	uint16_t block_ack_param_set;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 8767144..42c1af9 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1703,7 +1703,7 @@ int mwifiex_register_cfg80211(struct mwifiex_adapter *adapter)
 	wdev_priv = wiphy_priv(wiphy);
 	*(unsigned long *)wdev_priv = (unsigned long)adapter;
 
-	set_wiphy_dev(wiphy, (struct device *)priv->adapter->dev);
+	set_wiphy_dev(wiphy, priv->adapter->dev);
 
 	ret = wiphy_register(wiphy);
 	if (ret < 0) {
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
index d6b4fb0..82e63ce 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -1349,22 +1349,16 @@ static int mwifiex_deauthenticate_infra(struct mwifiex_private *priv, u8 *mac)
 {
 	u8 mac_address[ETH_ALEN];
 	int ret;
-	u8 zero_mac[ETH_ALEN] = { 0, 0, 0, 0, 0, 0 };
 
-	if (mac) {
-		if (!memcmp(mac, zero_mac, sizeof(zero_mac)))
-			memcpy((u8 *) &mac_address,
-			       (u8 *) &priv->curr_bss_params.bss_descriptor.
-			       mac_address, ETH_ALEN);
-		else
-			memcpy((u8 *) &mac_address, (u8 *) mac, ETH_ALEN);
-	} else {
-		memcpy((u8 *) &mac_address, (u8 *) &priv->curr_bss_params.
-		       bss_descriptor.mac_address, ETH_ALEN);
-	}
+	if (!mac || is_zero_ether_addr(mac))
+		memcpy(mac_address,
+		       priv->curr_bss_params.bss_descriptor.mac_address,
+		       ETH_ALEN);
+	else
+		memcpy(mac_address, mac, ETH_ALEN);
 
 	ret = mwifiex_send_cmd_sync(priv, HostCmd_CMD_802_11_DEAUTHENTICATE,
-				    HostCmd_ACT_GEN_SET, 0, &mac_address);
+				    HostCmd_ACT_GEN_SET, 0, mac_address);
 
 	return ret;
 }
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 74f0457..8fa763f 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1014,14 +1014,12 @@ mwifiex_ret_802_11_scan_get_tlv_ptrs(struct mwifiex_adapter *adapter,
 			case TLV_TYPE_TSFTIMESTAMP:
 				dev_dbg(adapter->dev, "info: SCAN_RESP: TSF "
 					"timestamp TLV, len = %d\n", tlv_len);
-				*tlv_data = (struct mwifiex_ie_types_data *)
-					current_tlv;
+				*tlv_data = current_tlv;
 				break;
 			case TLV_TYPE_CHANNELBANDLIST:
 				dev_dbg(adapter->dev, "info: SCAN_RESP: channel"
 					" band list TLV, len = %d\n", tlv_len);
-				*tlv_data = (struct mwifiex_ie_types_data *)
-					current_tlv;
+				*tlv_data = current_tlv;
 				break;
 			default:
 				dev_err(adapter->dev,
@@ -1226,15 +1224,15 @@ int mwifiex_update_bss_desc_with_ie(struct mwifiex_adapter *adapter,
 					bss_entry->beacon_buf);
 			break;
 		case WLAN_EID_BSS_COEX_2040:
-			bss_entry->bcn_bss_co_2040 = (u8 *) (current_ptr +
-					sizeof(struct ieee_types_header));
+			bss_entry->bcn_bss_co_2040 = current_ptr +
+				sizeof(struct ieee_types_header);
 			bss_entry->bss_co_2040_offset = (u16) (current_ptr +
 					sizeof(struct ieee_types_header) -
 						bss_entry->beacon_buf);
 			break;
 		case WLAN_EID_EXT_CAPABILITY:
-			bss_entry->bcn_ext_cap = (u8 *) (current_ptr +
-					sizeof(struct ieee_types_header));
+			bss_entry->bcn_ext_cap = current_ptr +
+				sizeof(struct ieee_types_header);
 			bss_entry->ext_cap_offset = (u16) (current_ptr +
 					sizeof(struct ieee_types_header) -
 					bss_entry->beacon_buf);
@@ -1683,8 +1681,7 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *priv,
 				goto done;
 			}
 			if (element_id == WLAN_EID_DS_PARAMS) {
-				channel = *(u8 *) (current_ptr +
-					sizeof(struct ieee_types_header));
+				channel = *(current_ptr + sizeof(struct ieee_types_header));
 				break;
 			}
 
@@ -2010,12 +2007,11 @@ mwifiex_save_curr_bcn(struct mwifiex_private *priv)
 
 	if (curr_bss->bcn_bss_co_2040)
 		curr_bss->bcn_bss_co_2040 =
-			(u8 *) (curr_bss->beacon_buf +
-					curr_bss->bss_co_2040_offset);
+			(curr_bss->beacon_buf + curr_bss->bss_co_2040_offset);
 
 	if (curr_bss->bcn_ext_cap)
-		curr_bss->bcn_ext_cap = (u8 *) (curr_bss->beacon_buf +
-				curr_bss->ext_cap_offset);
+		curr_bss->bcn_ext_cap = curr_bss->beacon_buf +
+			curr_bss->ext_cap_offset;
 }
 
 /*
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
index 40e025d..1ff1362 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -793,8 +793,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 		struct host_cmd_ds_mac_reg_access *mac_reg;
 
 		cmd->size = cpu_to_le16(sizeof(*mac_reg) + S_DS_GEN);
-		mac_reg = (struct host_cmd_ds_mac_reg_access *) &cmd->
-								params.mac_reg;
+		mac_reg = &cmd->params.mac_reg;
 		mac_reg->action = cpu_to_le16(cmd_action);
 		mac_reg->offset =
 			cpu_to_le16((u16) le32_to_cpu(reg_rw->offset));
@@ -806,8 +805,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 		struct host_cmd_ds_bbp_reg_access *bbp_reg;
 
 		cmd->size = cpu_to_le16(sizeof(*bbp_reg) + S_DS_GEN);
-		bbp_reg = (struct host_cmd_ds_bbp_reg_access *)
-							&cmd->params.bbp_reg;
+		bbp_reg = &cmd->params.bbp_reg;
 		bbp_reg->action = cpu_to_le16(cmd_action);
 		bbp_reg->offset =
 			cpu_to_le16((u16) le32_to_cpu(reg_rw->offset));
@@ -819,8 +817,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 		struct host_cmd_ds_rf_reg_access *rf_reg;
 
 		cmd->size = cpu_to_le16(sizeof(*rf_reg) + S_DS_GEN);
-		rf_reg = (struct host_cmd_ds_rf_reg_access *)
-							&cmd->params.rf_reg;
+		rf_reg = &cmd->params.rf_reg;
 		rf_reg->action = cpu_to_le16(cmd_action);
 		rf_reg->offset = cpu_to_le16((u16) le32_to_cpu(reg_rw->offset));
 		rf_reg->value = (u8) le32_to_cpu(reg_rw->value);
@@ -831,8 +828,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 		struct host_cmd_ds_pmic_reg_access *pmic_reg;
 
 		cmd->size = cpu_to_le16(sizeof(*pmic_reg) + S_DS_GEN);
-		pmic_reg = (struct host_cmd_ds_pmic_reg_access *) &cmd->
-				params.pmic_reg;
+		pmic_reg = &cmd->params.pmic_reg;
 		pmic_reg->action = cpu_to_le16(cmd_action);
 		pmic_reg->offset =
 				cpu_to_le16((u16) le32_to_cpu(reg_rw->offset));
@@ -844,8 +840,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 		struct host_cmd_ds_rf_reg_access *cau_reg;
 
 		cmd->size = cpu_to_le16(sizeof(*cau_reg) + S_DS_GEN);
-		cau_reg = (struct host_cmd_ds_rf_reg_access *)
-							&cmd->params.rf_reg;
+		cau_reg = &cmd->params.rf_reg;
 		cau_reg->action = cpu_to_le16(cmd_action);
 		cau_reg->offset =
 				cpu_to_le16((u16) le32_to_cpu(reg_rw->offset));
@@ -856,7 +851,6 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 	{
 		struct mwifiex_ds_read_eeprom *rd_eeprom = data_buf;
 		struct host_cmd_ds_802_11_eeprom_access *cmd_eeprom =
-			(struct host_cmd_ds_802_11_eeprom_access *)
 			&cmd->params.eeprom;
 
 		cmd->size = cpu_to_le16(sizeof(*cmd_eeprom) + S_DS_GEN);
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index a79ed9b..bd40541 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -227,7 +227,7 @@ static int mwifiex_ret_get_log(struct mwifiex_private *priv,
 			       struct mwifiex_ds_get_stats *stats)
 {
 	struct host_cmd_ds_802_11_get_log *get_log =
-		(struct host_cmd_ds_802_11_get_log *) &resp->params.get_log;
+		&resp->params.get_log;
 
 	if (stats) {
 		stats->mcast_tx_frame = le32_to_cpu(get_log->mcast_tx_frame);
@@ -282,7 +282,7 @@ static int mwifiex_ret_tx_rate_cfg(struct mwifiex_private *priv,
 	u32 i;
 	int ret = 0;
 
-	tlv_buf = (u8 *) ((u8 *) rate_cfg) +
+	tlv_buf = ((u8 *)rate_cfg) +
 			sizeof(struct host_cmd_ds_tx_rate_cfg);
 	tlv_buf_len = *(u16 *) (tlv_buf + sizeof(u16));
 
@@ -679,39 +679,33 @@ static int mwifiex_ret_reg_access(u16 type, struct host_cmd_ds_command *resp,
 	eeprom = data_buf;
 	switch (type) {
 	case HostCmd_CMD_MAC_REG_ACCESS:
-		r.mac = (struct host_cmd_ds_mac_reg_access *)
-			&resp->params.mac_reg;
+		r.mac = &resp->params.mac_reg;
 		reg_rw->offset = cpu_to_le32((u32) le16_to_cpu(r.mac->offset));
 		reg_rw->value = r.mac->value;
 		break;
 	case HostCmd_CMD_BBP_REG_ACCESS:
-		r.bbp = (struct host_cmd_ds_bbp_reg_access *)
-			&resp->params.bbp_reg;
+		r.bbp = &resp->params.bbp_reg;
 		reg_rw->offset = cpu_to_le32((u32) le16_to_cpu(r.bbp->offset));
 		reg_rw->value = cpu_to_le32((u32) r.bbp->value);
 		break;
 
 	case HostCmd_CMD_RF_REG_ACCESS:
-		r.rf = (struct host_cmd_ds_rf_reg_access *)
-		       &resp->params.rf_reg;
+		r.rf = &resp->params.rf_reg;
 		reg_rw->offset = cpu_to_le32((u32) le16_to_cpu(r.rf->offset));
 		reg_rw->value = cpu_to_le32((u32) r.bbp->value);
 		break;
 	case HostCmd_CMD_PMIC_REG_ACCESS:
-		r.pmic = (struct host_cmd_ds_pmic_reg_access *)
-			 &resp->params.pmic_reg;
+		r.pmic = &resp->params.pmic_reg;
 		reg_rw->offset = cpu_to_le32((u32) le16_to_cpu(r.pmic->offset));
 		reg_rw->value = cpu_to_le32((u32) r.pmic->value);
 		break;
 	case HostCmd_CMD_CAU_REG_ACCESS:
-		r.rf = (struct host_cmd_ds_rf_reg_access *)
-		       &resp->params.rf_reg;
+		r.rf = &resp->params.rf_reg;
 		reg_rw->offset = cpu_to_le32((u32) le16_to_cpu(r.rf->offset));
 		reg_rw->value = cpu_to_le32((u32) r.rf->value);
 		break;
 	case HostCmd_CMD_802_11_EEPROM_ACCESS:
-		r.eeprom = (struct host_cmd_ds_802_11_eeprom_access *)
-			   &resp->params.eeprom;
+		r.eeprom = &resp->params.eeprom;
 		pr_debug("info: EEPROM read len=%x\n", r.eeprom->byte_count);
 		if (le16_to_cpu(eeprom->byte_count) <
 		    le16_to_cpu(r.eeprom->byte_count)) {
@@ -787,7 +781,7 @@ static int mwifiex_ret_subsc_evt(struct mwifiex_private *priv,
 				 struct mwifiex_ds_misc_subsc_evt *sub_event)
 {
 	struct host_cmd_ds_802_11_subsc_evt *cmd_sub_event =
-		(struct host_cmd_ds_802_11_subsc_evt *)&resp->params.subsc_evt;
+		&resp->params.subsc_evt;
 
 	/* For every subscribe event command (Get/Set/Clear), FW reports the
 	 * current set of subscribed events*/
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireless/mwifiex/sta_event.c
index 4ace5a3..e8b27c3 100644
--- a/drivers/net/wireless/mwifiex/sta_event.c
+++ b/drivers/net/wireless/mwifiex/sta_event.c
@@ -422,7 +422,7 @@ int mwifiex_process_sta_event(struct mwifiex_private *priv)
 
 			if (len != -1) {
 				sinfo.filled = STATION_INFO_ASSOC_REQ_IES;
-				sinfo.assoc_req_ies = (u8 *)&event->data[len];
+				sinfo.assoc_req_ies = &event->data[len];
 				len = (u8 *)sinfo.assoc_req_ies -
 				      (u8 *)&event->frame_control;
 				sinfo.assoc_req_ies_len =
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index fa8ce51..636daf2 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -905,7 +905,7 @@ int p54_read_eeprom(struct ieee80211_hw *dev)
 
 	while (eeprom_size) {
 		blocksize = min(eeprom_size, maxblocksize);
-		ret = p54_download_eeprom(priv, (void *) (eeprom + offset),
+		ret = p54_download_eeprom(priv, eeprom + offset,
 					  offset, blocksize);
 		if (unlikely(ret))
 			goto free;
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index 18e82b3..9ba8510 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -478,7 +478,7 @@ int p54_scan(struct p54_common *priv, u16 mode, u16 dwell)
 
 		if (priv->rxhw == PDR_SYNTH_FRONTEND_LONGBOW) {
 			memcpy(&body->longbow.curve_data,
-				(void *) entry + sizeof(__le16),
+				entry + sizeof(__le16),
 				priv->curve_data->entry_size);
 		} else {
 			struct p54_scan_body *chan = &body->normal;
diff --git a/drivers/net/wireless/prism54/islpci_eth.c b/drivers/net/wireless/prism54/islpci_eth.c
index 266d45b..799e148 100644
--- a/drivers/net/wireless/prism54/islpci_eth.c
+++ b/drivers/net/wireless/prism54/islpci_eth.c
@@ -455,7 +455,7 @@ islpci_eth_receive(islpci_private *priv)
 			      "Error mapping DMA address\n");
 
 			/* free the skbuf structure before aborting */
-			dev_kfree_skb_irq((struct sk_buff *) skb);
+			dev_kfree_skb_irq(skb);
 			skb = NULL;
 			break;
 		}
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 86a738b..598ca1c 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1849,7 +1849,7 @@ static irqreturn_t ray_interrupt(int irq, void *dev_id)
 	pr_debug("ray_cs: interrupt for *dev=%p\n", dev);
 
 	local = netdev_priv(dev);
-	link = (struct pcmcia_device *)local->finder;
+	link = local->finder;
 	if (!pcmcia_dev_present(link)) {
 		pr_debug(
 			"ray_cs interrupt from device not present or suspended.\n");
diff --git a/drivers/net/wireless/rtlwifi/base.c b/drivers/net/wireless/rtlwifi/base.c
index f4c852c..58e1f7b 100644
--- a/drivers/net/wireless/rtlwifi/base.c
+++ b/drivers/net/wireless/rtlwifi/base.c
@@ -907,7 +907,7 @@ bool rtl_action_proc(struct ieee80211_hw *hw, struct sk_buff *skb, u8 is_tx)
 	struct ieee80211_hdr *hdr = rtl_get_hdr(skb);
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	__le16 fc = hdr->frame_control;
-	u8 *act = (u8 *) (((u8 *) skb->data + MAC80211_3ADDR_LEN));
+	u8 *act = (u8 *)skb->data + MAC80211_3ADDR_LEN;
 	u8 category;
 
 	if (!ieee80211_is_action(fc))
diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 3d8cc4a..2d1a822 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -146,7 +146,7 @@ u8 rtl_cam_add_one_entry(struct ieee80211_hw *hw, u8 *mac_addr,
 	}
 
 	rtl_cam_program_entry(hw, ul_entry_idx, mac_addr,
-			      (u8 *) key_content, us_config);
+			      key_content, us_config);
 
 	RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG, "<===\n");
 
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index 278e9f9..a18ad2a 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -680,7 +680,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 
 		mac->short_preamble = bss_conf->use_short_preamble;
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACK_PREAMBLE,
-					      (u8 *) (&mac->short_preamble));
+					      &mac->short_preamble);
 	}
 
 	if (changed & BSS_CHANGED_ERP_SLOT) {
@@ -693,7 +693,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			mac->slot_time = RTL_SLOT_TIME_20;
 
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-					      (u8 *) (&mac->slot_time));
+					      &mac->slot_time);
 	}
 
 	if (changed & BSS_CHANGED_HT) {
@@ -713,7 +713,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 		rcu_read_unlock();
 
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SHORTGI_DENSITY,
-					      (u8 *) (&mac->max_mss_density));
+					      &mac->max_mss_density);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_FACTOR,
 					      &mac->current_ampdu_factor);
 		rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AMPDU_MIN_SPACE,
@@ -801,7 +801,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				u8 mstatus = RT_MEDIA_CONNECT;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						      HW_VAR_H2C_FW_JOINBSSRPT,
-						      (u8 *) (&mstatus));
+						      &mstatus);
 				ppsc->report_linked = true;
 			}
 		} else {
@@ -809,7 +809,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 				u8 mstatus = RT_MEDIA_DISCONNECT;
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						      HW_VAR_H2C_FW_JOINBSSRPT,
-						      (u8 *)(&mstatus));
+						      &mstatus);
 				ppsc->report_linked = false;
 			}
 		}
@@ -836,7 +836,7 @@ static void rtl_op_set_tsf(struct ieee80211_hw *hw, struct ieee80211_vif *vif,
 	u8 bibss = (mac->opmode == NL80211_IFTYPE_ADHOC) ? 1 : 0;
 
 	mac->tsf = tsf;
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, (u8 *) (&bibss));
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_CORRECT_TSF, &bibss);
 }
 
 static void rtl_op_reset_tsf(struct ieee80211_hw *hw,
@@ -845,7 +845,7 @@ static void rtl_op_reset_tsf(struct ieee80211_hw *hw,
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	u8 tmp = 0;
 
-	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, (u8 *) (&tmp));
+	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_DUAL_TSF_RST, &tmp);
 }
 
 static void rtl_op_sta_notify(struct ieee80211_hw *hw,
diff --git a/drivers/net/wireless/rtlwifi/efuse.c b/drivers/net/wireless/rtlwifi/efuse.c
index 1f14380..8e2f9af 100644
--- a/drivers/net/wireless/rtlwifi/efuse.c
+++ b/drivers/net/wireless/rtlwifi/efuse.c
@@ -352,7 +352,7 @@ void read_efuse(struct ieee80211_hw *hw, u16 _offset, u16 _size_byte, u8 *pbuf)
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_EFUSE_BYTES,
 				      (u8 *)&efuse_utilized);
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_EFUSE_USAGE,
-				      (u8 *)&efuse_usage);
+				      &efuse_usage);
 done:
 	for (i = 0; i < EFUSE_MAX_WORD_UNIT; i++)
 		kfree(efuse_word[i]);
@@ -409,7 +409,7 @@ void efuse_shadow_read(struct ieee80211_hw *hw, u8 type,
 	else if (type == 2)
 		efuse_shadow_read_2byte(hw, offset, (u16 *) value);
 	else if (type == 4)
-		efuse_shadow_read_4byte(hw, offset, (u32 *) value);
+		efuse_shadow_read_4byte(hw, offset, value);
 
 }
 
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlwifi/pci.c
index 2062ea1..82d3afc 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -756,10 +756,10 @@ done:
 		if (index == rtlpci->rxringcount - 1)
 			rtlpriv->cfg->ops->set_desc((u8 *)pdesc, false,
 						    HW_DESC_RXERO,
-						    (u8 *)&tmp_one);
+						    &tmp_one);
 
 		rtlpriv->cfg->ops->set_desc((u8 *)pdesc, false, HW_DESC_RXOWN,
-					    (u8 *)&tmp_one);
+					    &tmp_one);
 
 		index = (index + 1) % rtlpci->rxringcount;
 	}
@@ -934,7 +934,7 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee80211_hw *hw)
 	__skb_queue_tail(&ring->queue, pskb);
 
 	rtlpriv->cfg->ops->set_desc((u8 *) pdesc, true, HW_DESC_OWN,
-				    (u8 *)&temp_one);
+				    &temp_one);
 
 	return;
 }
@@ -1126,11 +1126,11 @@ static int _rtl_pci_init_rx_ring(struct ieee80211_hw *hw)
 						    rxbuffersize);
 			rtlpriv->cfg->ops->set_desc((u8 *) entry, false,
 						    HW_DESC_RXOWN,
-						    (u8 *)&tmp_one);
+						    &tmp_one);
 		}
 
 		rtlpriv->cfg->ops->set_desc((u8 *) entry, false,
-					    HW_DESC_RXERO, (u8 *)&tmp_one);
+					    HW_DESC_RXERO, &tmp_one);
 	}
 	return 0;
 }
@@ -1263,7 +1263,7 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 				rtlpriv->cfg->ops->set_desc((u8 *) entry,
 							    false,
 							    HW_DESC_RXOWN,
-							    (u8 *)&tmp_one);
+							    &tmp_one);
 			}
 			rtlpci->rx_ring[rx_queue_idx].idx = 0;
 		}
@@ -1422,7 +1422,7 @@ static int rtl_pci_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 	__skb_queue_tail(&ring->queue, skb);
 
 	rtlpriv->cfg->ops->set_desc((u8 *)pdesc, true,
-				    HW_DESC_OWN, (u8 *)&temp_one);
+				    HW_DESC_OWN, &temp_one);
 
 
 	if ((ring->entries - skb_queue_len(&ring->queue)) < 2 &&
diff --git a/drivers/net/wireless/rtlwifi/ps.c b/drivers/net/wireless/rtlwifi/ps.c
index 5ae2664..13ad33e 100644
--- a/drivers/net/wireless/rtlwifi/ps.c
+++ b/drivers/net/wireless/rtlwifi/ps.c
@@ -333,10 +333,10 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 			rpwm_val = 0x0C;	/* RF on */
 			fw_pwrmode = FW_PS_ACTIVE_MODE;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SET_RPWM,
-					(u8 *) (&rpwm_val));
+					&rpwm_val);
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 					HW_VAR_H2C_FW_PWRMODE,
-					(u8 *) (&fw_pwrmode));
+					&fw_pwrmode);
 			fw_current_inps = false;
 
 			rtlpriv->cfg->ops->set_hw_reg(hw,
@@ -356,11 +356,11 @@ static void rtl_lps_set_psmode(struct ieee80211_hw *hw, u8 rt_psmode)
 						(u8 *) (&fw_current_inps));
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_H2C_FW_PWRMODE,
-						(u8 *) (&ppsc->fwctrl_psmode));
+						&ppsc->fwctrl_psmode);
 
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_SET_RPWM,
-						(u8 *) (&rpwm_val));
+						&rpwm_val);
 			} else {
 				/* Reset the power save related parameters. */
 				ppsc->dot11_psmode = EACTIVE;
@@ -446,7 +446,7 @@ void rtl_swlps_beacon(struct ieee80211_hw *hw, void *data, unsigned int len)
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_mac *mac = rtl_mac(rtl_priv(hw));
-	struct ieee80211_hdr *hdr = (void *) data;
+	struct ieee80211_hdr *hdr = data;
 	struct ieee80211_tim_ie *tim_ie;
 	u8 *tim;
 	u8 tim_len;
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
index f7f48c7..a45afda 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/dm_common.c
@@ -656,9 +656,8 @@ static void rtl92c_dm_check_edca_turbo(struct ieee80211_hw *hw)
 	} else {
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
-			rtlpriv->cfg->ops->set_hw_reg(hw,
-						      HW_VAR_AC_PARAM,
-						      (u8 *) (&tmp));
+			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
+						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
index 692c8ef..44febfd 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192c/fw_common.c
@@ -168,7 +168,7 @@ static void _rtl92c_write_fw(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 *bufferPtr = (u8 *) buffer;
+	u8 *bufferPtr = buffer;
 
 	RT_TRACE(rtlpriv, COMP_FW, DBG_TRACE, "FW size is %d bytes\n", size);
 
@@ -262,7 +262,7 @@ int rtl92c_download_fw(struct ieee80211_hw *hw)
 		return 1;
 
 	pfwheader = (struct rtl92c_firmware_header *)rtlhal->pfirmware;
-	pfwdata = (u8 *) rtlhal->pfirmware;
+	pfwdata = rtlhal->pfirmware;
 	fwsize = rtlhal->fwsize;
 
 	if (IS_FW_HEADER_EXIST(pfwheader)) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
index 5c4d9bc..bd0da7e 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/hw.c
@@ -214,13 +214,13 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 							      HW_VAR_AC_PARAM,
-							      (u8 *) (&e_aci));
+							      &e_aci);
 			}
 			break;
 		}
 	case HW_VAR_ACK_PREAMBLE:{
 			u8 reg_tmp;
-			u8 short_preamble = (bool) (*(u8 *) val);
+			u8 short_preamble = (bool)*val;
 			reg_tmp = (mac->cur_40_prime_sc) << 5;
 			if (short_preamble)
 				reg_tmp |= 0x80;
@@ -232,7 +232,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 min_spacing_to_set;
 			u8 sec_min_space;
 
-			min_spacing_to_set = *((u8 *) val);
+			min_spacing_to_set = *val;
 			if (min_spacing_to_set <= 7) {
 				sec_min_space = 0;
 
@@ -257,7 +257,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY:{
 			u8 density_to_set;
 
-			density_to_set = *((u8 *) val);
+			density_to_set = *val;
 			mac->min_space_cfg |= (density_to_set << 3);
 
 			RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -284,7 +284,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			else
 				p_regtoset = regtoset_normal;
 
-			factor_toset = *((u8 *) val);
+			factor_toset = *(val);
 			if (factor_toset <= 3) {
 				factor_toset = (1 << (factor_toset + 2));
 				if (factor_toset > 0xf)
@@ -316,17 +316,17 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_AC_PARAM:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *(val);
 			rtl92c_dm_init_edca_turbo(hw);
 
 			if (rtlpci->acm_method != eAcmWay2_SW)
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 							      HW_VAR_ACM_CTRL,
-							      (u8 *) (&e_aci));
+							      (&e_aci));
 			break;
 		}
 	case HW_VAR_ACM_CTRL:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *(val);
 			union aci_aifsn *p_aci_aifsn =
 			    (union aci_aifsn *)(&(mac->ac[0].aifs));
 			u8 acm = p_aci_aifsn->f.acm;
@@ -382,7 +382,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_RETRY_LIMIT:{
-			u8 retry_limit = ((u8 *) (val))[0];
+			u8 retry_limit = val[0];
 
 			rtl_write_word(rtlpriv, REG_RL,
 				       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -396,13 +396,13 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *) val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *) val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl92c_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *) val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_SET_RPWM:{
 			u8 rpwm_val;
@@ -411,31 +411,30 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			udelay(1);
 
 			if (rpwm_val & BIT(7)) {
-				rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-					       (*(u8 *) val));
+				rtl_write_byte(rtlpriv, REG_PCIE_HRPWM, *val);
 			} else {
 				rtl_write_byte(rtlpriv, REG_PCIE_HRPWM,
-					       ((*(u8 *) val) | BIT(7)));
+					       *val | BIT(7));
 			}
 
 			break;
 		}
 	case HW_VAR_H2C_FW_PWRMODE:{
-			u8 psmode = (*(u8 *) val);
+			u8 psmode = *val;
 
 			if ((psmode != FW_PS_ACTIVE_MODE) &&
 			    (!IS_92C_SERIAL(rtlhal->version))) {
 				rtl92c_dm_rf_saving(hw, true);
 			}
 
-			rtl92c_set_fw_pwrmode_cmd(hw, (*(u8 *) val));
+			rtl92c_set_fw_pwrmode_cmd(hw, *val);
 			break;
 		}
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *) val);
 		break;
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
-			u8 mstatus = (*(u8 *) val);
+			u8 mstatus = *val;
 			u8 tmp_regcr, tmp_reg422;
 			bool recover = false;
 
@@ -472,7 +471,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				rtl_write_byte(rtlpriv, REG_CR + 1,
 					       (tmp_regcr & ~(BIT(0))));
 			}
-			rtl92c_set_fw_joinbss_report_cmd(hw, (*(u8 *) val));
+			rtl92c_set_fw_joinbss_report_cmd(hw, *val);
 
 			break;
 		}
@@ -486,7 +485,7 @@ void rtl92ce_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_CORRECT_TSF:{
-			u8 btype_ibss = ((u8 *) (val))[0];
+			u8 btype_ibss = val[0];
 
 			if (btype_ibss)
 				_rtl92ce_stop_tx_beacon(hw);
@@ -1589,10 +1588,10 @@ static void _rtl92ce_read_adapter_info(struct ieee80211_hw *hw)
 						 rtlefuse->autoload_failflag,
 						 hwinfo);
 
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = *&hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->eeprom_version = *(u16 *)&hwinfo[EEPROM_VERSION];
 	rtlefuse->txpwr_fromeprom = true;
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = *&hwinfo[EEPROM_CUSTOMER_ID];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
 		 "EEPROM Customer ID: 0x%2x\n", rtlefuse->eeprom_oemid);
@@ -1939,7 +1938,7 @@ void rtl92ce_update_channel_access_setting(struct ieee80211_hw *hw)
 	u16 sifs_timer;
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+				      &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
index 3af874e..5216664 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -605,7 +605,7 @@ void rtl92ce_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	bool defaultadapter = true;
 	struct ieee80211_sta *sta;
-	u8 *pdesc = (u8 *) pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	u8 fw_qsel = _rtl92ce_map_hwqueue_to_fwqueue(skb, hw_queue);
@@ -806,7 +806,7 @@ void rtl92ce_tx_fill_cmddesc(struct ieee80211_hw *hw,
 
 	SET_TX_DESC_OWN(pdesc, 1);
 
-	SET_TX_DESC_PKT_SIZE((u8 *) pdesc, (u16) (skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16) (skb->len));
 
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
index 0c74d4f..4bbb711 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/hw.c
@@ -381,11 +381,11 @@ static void _rtl92cu_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->eeprom_did = le16_to_cpu(*(__le16 *)&hwinfo[EEPROM_DID]);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_DMESG, " VID = 0x%02x PID = 0x%02x\n",
 		 rtlefuse->eeprom_vid, rtlefuse->eeprom_did);
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->eeprom_version =
 			 le16_to_cpu(*(__le16 *)&hwinfo[EEPROM_VERSION]);
 	rtlefuse->txpwr_fromeprom = true;
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x\n",
 		 rtlefuse->eeprom_oemid);
 	if (rtlhal->oem_id == RT_CID_DEFAULT) {
@@ -1660,7 +1660,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				for (e_aci = 0; e_aci < AC_MAX; e_aci++)
 					rtlpriv->cfg->ops->set_hw_reg(hw,
 								HW_VAR_AC_PARAM,
-								(u8 *)(&e_aci));
+								&e_aci);
 			} else {
 				u8 sifstime = 0;
 				u8	u1bAIFS;
@@ -1685,7 +1685,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		}
 	case HW_VAR_ACK_PREAMBLE:{
 			u8 reg_tmp;
-			u8 short_preamble = (bool) (*(u8 *) val);
+			u8 short_preamble = (bool)*val;
 			reg_tmp = 0;
 			if (short_preamble)
 				reg_tmp |= 0x80;
@@ -1696,7 +1696,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 min_spacing_to_set;
 			u8 sec_min_space;
 
-			min_spacing_to_set = *((u8 *) val);
+			min_spacing_to_set = *val;
 			if (min_spacing_to_set <= 7) {
 				switch (rtlpriv->sec.pairwise_enc_algorithm) {
 				case NO_ENCRYPTION:
@@ -1729,7 +1729,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY:{
 			u8 density_to_set;
 
-			density_to_set = *((u8 *) val);
+			density_to_set = *val;
 			density_to_set &= 0x1f;
 			mac->min_space_cfg &= 0x07;
 			mac->min_space_cfg |= (density_to_set << 3);
@@ -1747,7 +1747,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 index = 0;
 
 			p_regtoset = regtoset_normal;
-			factor_toset = *((u8 *) val);
+			factor_toset = *val;
 			if (factor_toset <= 3) {
 				factor_toset = (1 << (factor_toset + 2));
 				if (factor_toset > 0xf)
@@ -1774,7 +1774,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_AC_PARAM:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *val;
 			u32 u4b_ac_param;
 			u16 cw_min = le16_to_cpu(mac->ac[e_aci].cw_min);
 			u16 cw_max = le16_to_cpu(mac->ac[e_aci].cw_max);
@@ -1814,11 +1814,11 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			}
 			if (rtlusb->acm_method != eAcmWay2_SW)
 				rtlpriv->cfg->ops->set_hw_reg(hw,
-					 HW_VAR_ACM_CTRL, (u8 *)(&e_aci));
+					 HW_VAR_ACM_CTRL, &e_aci);
 			break;
 		}
 	case HW_VAR_ACM_CTRL:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *val;
 			union aci_aifsn *p_aci_aifsn = (union aci_aifsn *)
 							(&(mac->ac[0].aifs));
 			u8 acm = p_aci_aifsn->f.acm;
@@ -1874,7 +1874,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_RETRY_LIMIT:{
-			u8 retry_limit = ((u8 *) (val))[0];
+			u8 retry_limit = val[0];
 
 			rtl_write_word(rtlpriv, REG_RL,
 				       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -1891,39 +1891,38 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *) val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *) val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl92c_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *) val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_SET_RPWM:{
 			u8 rpwm_val = rtl_read_byte(rtlpriv, REG_USB_HRPWM);
 
 			if (rpwm_val & BIT(7))
-				rtl_write_byte(rtlpriv, REG_USB_HRPWM,
-					       (*(u8 *)val));
+				rtl_write_byte(rtlpriv, REG_USB_HRPWM, *val);
 			else
 				rtl_write_byte(rtlpriv, REG_USB_HRPWM,
-					       ((*(u8 *)val) | BIT(7)));
+					       *val | BIT(7));
 			break;
 		}
 	case HW_VAR_H2C_FW_PWRMODE:{
-			u8 psmode = (*(u8 *) val);
+			u8 psmode = *val;
 
 			if ((psmode != FW_PS_ACTIVE_MODE) &&
 			   (!IS_92C_SERIAL(rtlhal->version)))
 				rtl92c_dm_rf_saving(hw, true);
-			rtl92c_set_fw_pwrmode_cmd(hw, (*(u8 *) val));
+			rtl92c_set_fw_pwrmode_cmd(hw, (*val));
 			break;
 		}
 	case HW_VAR_FW_PSMODE_STATUS:
 		ppsc->fw_current_inpsmode = *((bool *) val);
 		break;
 	case HW_VAR_H2C_FW_JOINBSSRPT:{
-			u8 mstatus = (*(u8 *) val);
+			u8 mstatus = *val;
 			u8 tmp_reg422;
 			bool recover = false;
 
@@ -1948,7 +1947,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 						tmp_reg422 | BIT(6));
 				rtl_write_byte(rtlpriv, REG_CR + 1, 0x02);
 			}
-			rtl92c_set_fw_joinbss_report_cmd(hw, (*(u8 *) val));
+			rtl92c_set_fw_joinbss_report_cmd(hw, (*val));
 			break;
 		}
 	case HW_VAR_AID:{
@@ -1961,7 +1960,7 @@ void rtl92cu_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_CORRECT_TSF:{
-			u8 btype_ibss = ((u8 *) (val))[0];
+			u8 btype_ibss = val[0];
 
 			if (btype_ibss)
 				_rtl92cu_stop_tx_beacon(hw);
@@ -2184,7 +2183,7 @@ void rtl92cu_update_channel_access_setting(struct ieee80211_hw *hw)
 	u16 sifs_timer;
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+				      &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 21bc827..2e6eb35 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -668,7 +668,7 @@ void rtl92cu_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	SET_TX_DESC_RATE_ID(pdesc, 7);
 	SET_TX_DESC_MACID(pdesc, 0);
 	SET_TX_DESC_OWN(pdesc, 1);
-	SET_TX_DESC_PKT_SIZE((u8 *) pdesc, (u16) (skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16)skb->len);
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
 	SET_TX_DESC_OFFSET(pdesc, 0x20);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index a7d63a8..c0201ed 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -696,7 +696,7 @@ static void rtl92d_dm_check_edca_turbo(struct ieee80211_hw *hw)
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      (u8 *) (&tmp));
+						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
index f548a8d..895ae6c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/fw.c
@@ -120,7 +120,7 @@ static void _rtl92d_write_fw(struct ieee80211_hw *hw,
 {
 	struct rtl_priv *rtlpriv = rtl_priv(hw);
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
-	u8 *bufferPtr = (u8 *) buffer;
+	u8 *bufferPtr = buffer;
 	u32 pagenums, remainSize;
 	u32 page, offset;
 
@@ -256,8 +256,8 @@ int rtl92d_download_fw(struct ieee80211_hw *hw)
 	if (rtlpriv->max_fw_size == 0 || !rtlhal->pfirmware)
 		return 1;
 	fwsize = rtlhal->fwsize;
-	pfwheader = (u8 *) rtlhal->pfirmware;
-	pfwdata = (u8 *) rtlhal->pfirmware;
+	pfwheader = rtlhal->pfirmware;
+	pfwdata = rtlhal->pfirmware;
 	rtlhal->fw_version = (u16) GET_FIRMWARE_HDR_VERSION(pfwheader);
 	rtlhal->fw_subversion = (u16) GET_FIRMWARE_HDR_SUB_VER(pfwheader);
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD,
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
index b338d52..f4051f4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/hw.c
@@ -235,12 +235,12 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		for (e_aci = 0; e_aci < AC_MAX; e_aci++)
 			rtlpriv->cfg->ops->set_hw_reg(hw,
 						      HW_VAR_AC_PARAM,
-						      (u8 *) (&e_aci));
+						      (&e_aci));
 		break;
 	}
 	case HW_VAR_ACK_PREAMBLE: {
 		u8 reg_tmp;
-		u8 short_preamble = (bool) (*(u8 *) val);
+		u8 short_preamble = (bool) (*val);
 
 		reg_tmp = (mac->cur_40_prime_sc) << 5;
 		if (short_preamble)
@@ -252,7 +252,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		u8 min_spacing_to_set;
 		u8 sec_min_space;
 
-		min_spacing_to_set = *((u8 *) val);
+		min_spacing_to_set = *val;
 		if (min_spacing_to_set <= 7) {
 			sec_min_space = 0;
 			if (min_spacing_to_set < sec_min_space)
@@ -271,7 +271,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY: {
 		u8 density_to_set;
 
-		density_to_set = *((u8 *) val);
+		density_to_set = *val;
 		mac->min_space_cfg = rtlpriv->rtlhal.minspace_cfg;
 		mac->min_space_cfg |= (density_to_set << 3);
 		RT_TRACE(rtlpriv, COMP_MLME, DBG_LOUD,
@@ -293,7 +293,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			regtoSet = 0x66626641;
 		else
 			regtoSet = 0xb972a841;
-		factor_toset = *((u8 *) val);
+		factor_toset = *val;
 		if (factor_toset <= 3) {
 			factor_toset = (1 << (factor_toset + 2));
 			if (factor_toset > 0xf)
@@ -316,15 +316,15 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	}
 	case HW_VAR_AC_PARAM: {
-		u8 e_aci = *((u8 *) val);
+		u8 e_aci = *val;
 		rtl92d_dm_init_edca_turbo(hw);
 		if (rtlpci->acm_method != eAcmWay2_SW)
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_ACM_CTRL,
-						      (u8 *) (&e_aci));
+						      &e_aci);
 		break;
 	}
 	case HW_VAR_ACM_CTRL: {
-		u8 e_aci = *((u8 *) val);
+		u8 e_aci = *val;
 		union aci_aifsn *p_aci_aifsn =
 		    (union aci_aifsn *)(&(mac->ac[0].aifs));
 		u8 acm = p_aci_aifsn->f.acm;
@@ -376,7 +376,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlpci->receive_config = ((u32 *) (val))[0];
 		break;
 	case HW_VAR_RETRY_LIMIT: {
-		u8 retry_limit = ((u8 *) (val))[0];
+		u8 retry_limit = val[0];
 
 		rtl_write_word(rtlpriv, REG_RL,
 			       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -390,16 +390,16 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		rtlefuse->efuse_usedbytes = *((u16 *) val);
 		break;
 	case HW_VAR_EFUSE_USAGE:
-		rtlefuse->efuse_usedpercentage = *((u8 *) val);
+		rtlefuse->efuse_usedpercentage = *val;
 		break;
 	case HW_VAR_IO_CMD:
 		rtl92d_phy_set_io_cmd(hw, (*(enum io_type *)val));
 		break;
 	case HW_VAR_WPA_CONFIG:
-		rtl_write_byte(rtlpriv, REG_SECCFG, *((u8 *) val));
+		rtl_write_byte(rtlpriv, REG_SECCFG, *val);
 		break;
 	case HW_VAR_SET_RPWM:
-		rtl92d_fill_h2c_cmd(hw, H2C_PWRM, 1, (u8 *) (val));
+		rtl92d_fill_h2c_cmd(hw, H2C_PWRM, 1, (val));
 		break;
 	case HW_VAR_H2C_FW_PWRMODE:
 		break;
@@ -407,7 +407,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		ppsc->fw_current_inpsmode = *((bool *) val);
 		break;
 	case HW_VAR_H2C_FW_JOINBSSRPT: {
-		u8 mstatus = (*(u8 *) val);
+		u8 mstatus = (*val);
 		u8 tmp_regcr, tmp_reg422;
 		bool recover = false;
 
@@ -435,7 +435,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			rtl_write_byte(rtlpriv, REG_CR + 1,
 				       (tmp_regcr & ~(BIT(0))));
 		}
-		rtl92d_set_fw_joinbss_report_cmd(hw, (*(u8 *) val));
+		rtl92d_set_fw_joinbss_report_cmd(hw, (*val));
 		break;
 	}
 	case HW_VAR_AID: {
@@ -447,7 +447,7 @@ void rtl92de_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 		break;
 	}
 	case HW_VAR_CORRECT_TSF: {
-		u8 btype_ibss = ((u8 *) (val))[0];
+		u8 btype_ibss = val[0];
 
 		if (btype_ibss)
 			_rtl92de_stop_tx_beacon(hw);
@@ -1794,7 +1794,7 @@ static void _rtl92de_read_adapter_info(struct ieee80211_hw *hw)
 			 "RTL819X Not boot from eeprom, check it !!\n");
 		return;
 	}
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMER_ID];
+	rtlefuse->eeprom_oemid = hwinfo[EEPROM_CUSTOMER_ID];
 	_rtl92de_read_macphymode_and_bandtype(hw, hwinfo);
 
 	/* VID, DID  SE     0xA-D */
@@ -2115,7 +2115,7 @@ void rtl92de_update_channel_access_setting(struct ieee80211_hw *hw)
 	u16 sifs_timer;
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+				      &mac->slot_time);
 	if (!mac->ht_enable)
 		sifs_timer = 0x0a0a;
 	else
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
index 1666ef7..f80690d 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/trx.c
@@ -560,7 +560,7 @@ void rtl92de_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_hal *rtlhal = rtl_hal(rtlpriv);
 	struct rtl_ps_ctl *ppsc = rtl_psc(rtl_priv(hw));
 	struct ieee80211_sta *sta = info->control.sta;
-	u8 *pdesc = (u8 *) pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	unsigned int buf_len = 0;
@@ -761,11 +761,11 @@ void rtl92de_tx_fill_cmddesc(struct ieee80211_hw *hw,
 	SET_TX_DESC_QUEUE_SEL(pdesc, fw_queue);
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
-	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16) (skb->len));
+	SET_TX_DESC_TX_BUFFER_SIZE(pdesc, (u16)skb->len);
 	SET_TX_DESC_TX_BUFFER_ADDRESS(pdesc, mapping);
 	SET_TX_DESC_RATE_ID(pdesc, 7);
 	SET_TX_DESC_MACID(pdesc, 0);
-	SET_TX_DESC_PKT_SIZE((u8 *) pdesc, (u16) (skb->len));
+	SET_TX_DESC_PKT_SIZE(pdesc, (u16) (skb->len));
 	SET_TX_DESC_FIRST_SEG(pdesc, 1);
 	SET_TX_DESC_LAST_SEG(pdesc, 1);
 	SET_TX_DESC_OFFSET(pdesc, 0x20);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
index 2e11580..465f581 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/dm.c
@@ -146,7 +146,7 @@ static void _rtl92s_dm_check_edca_turbo(struct ieee80211_hw *hw)
 		if (rtlpriv->dm.current_turbo_edca) {
 			u8 tmp = AC0_BE;
 			rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_AC_PARAM,
-						      (u8 *)(&tmp));
+						      &tmp);
 			rtlpriv->dm.current_turbo_edca = false;
 		}
 	}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
index b141c35..4542e69 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -145,13 +145,13 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			for (e_aci = 0; e_aci < AC_MAX; e_aci++) {
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						HW_VAR_AC_PARAM,
-						(u8 *)(&e_aci));
+						(&e_aci));
 			}
 			break;
 		}
 	case HW_VAR_ACK_PREAMBLE:{
 			u8 reg_tmp;
-			u8 short_preamble = (bool) (*(u8 *) val);
+			u8 short_preamble = (bool) (*val);
 			reg_tmp = (mac->cur_40_prime_sc) << 5;
 			if (short_preamble)
 				reg_tmp |= 0x80;
@@ -163,7 +163,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			u8 min_spacing_to_set;
 			u8 sec_min_space;
 
-			min_spacing_to_set = *((u8 *)val);
+			min_spacing_to_set = *val;
 			if (min_spacing_to_set <= 7) {
 				if (rtlpriv->sec.pairwise_enc_algorithm ==
 				    NO_ENCRYPTION)
@@ -194,7 +194,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 	case HW_VAR_SHORTGI_DENSITY:{
 			u8 density_to_set;
 
-			density_to_set = *((u8 *) val);
+			density_to_set = *val;
 			mac->min_space_cfg = rtlpriv->rtlhal.minspace_cfg;
 			mac->min_space_cfg |= (density_to_set << 3);
 
@@ -216,7 +216,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 				15, 15, 15, 15, 0};
 			u8 index = 0;
 
-			factor_toset = *((u8 *) val);
+			factor_toset = *val;
 			if (factor_toset <= 3) {
 				factor_toset = (1 << (factor_toset + 2));
 				if (factor_toset > 0xf)
@@ -248,17 +248,17 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_AC_PARAM:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *val;
 			rtl92s_dm_init_edca_turbo(hw);
 
 			if (rtlpci->acm_method != eAcmWay2_SW)
 				rtlpriv->cfg->ops->set_hw_reg(hw,
 						 HW_VAR_ACM_CTRL,
-						 (u8 *)(&e_aci));
+						 &e_aci);
 			break;
 		}
 	case HW_VAR_ACM_CTRL:{
-			u8 e_aci = *((u8 *) val);
+			u8 e_aci = *val;
 			union aci_aifsn *p_aci_aifsn = (union aci_aifsn *)(&(
 							mac->ac[0].aifs));
 			u8 acm = p_aci_aifsn->f.acm;
@@ -313,7 +313,7 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_RETRY_LIMIT:{
-			u8 retry_limit = ((u8 *) (val))[0];
+			u8 retry_limit = val[0];
 
 			rtl_write_word(rtlpriv, RETRY_LIMIT,
 				       retry_limit << RETRY_LIMIT_SHORT_SHIFT |
@@ -328,14 +328,14 @@ void rtl92se_set_hw_reg(struct ieee80211_hw *hw, u8 variable, u8 *val)
 			break;
 		}
 	case HW_VAR_EFUSE_USAGE: {
-			rtlefuse->efuse_usedpercentage = *((u8 *) val);
+			rtlefuse->efuse_usedpercentage = *val;
 			break;
 		}
 	case HW_VAR_IO_CMD: {
 			break;
 		}
 	case HW_VAR_WPA_CONFIG: {
-			rtl_write_byte(rtlpriv, REG_SECR, *((u8 *) val));
+			rtl_write_byte(rtlpriv, REG_SECR, *val);
 			break;
 		}
 	case HW_VAR_SET_RPWM:{
@@ -1813,8 +1813,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		else
 			index = 2;
 
-		tempval = (*(u8 *)&hwinfo[EEPROM_TX_PWR_HT20_DIFF +
-			   index]) & 0xff;
+		tempval = hwinfo[EEPROM_TX_PWR_HT20_DIFF + index] & 0xff;
 		rtlefuse->txpwr_ht20diff[RF90_PATH_A][i] = (tempval & 0xF);
 		rtlefuse->txpwr_ht20diff[RF90_PATH_B][i] =
 						 ((tempval >> 4) & 0xF);
@@ -1830,14 +1829,13 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		else
 			index = 1;
 
-		tempval = (*(u8 *)&hwinfo[EEPROM_TX_PWR_OFDM_DIFF + index])
-				  & 0xff;
+		tempval = hwinfo[EEPROM_TX_PWR_OFDM_DIFF + index] & 0xff;
 		rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][i] =
 				 (tempval & 0xF);
 		rtlefuse->txpwr_legacyhtdiff[RF90_PATH_B][i] =
 				 ((tempval >> 4) & 0xF);
 
-		tempval = (*(u8 *)&hwinfo[TX_PWR_SAFETY_CHK]);
+		tempval = hwinfo[TX_PWR_SAFETY_CHK];
 		rtlefuse->txpwr_safetyflag = (tempval & 0x01);
 	}
 
@@ -1876,7 +1874,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 
 	/* Read RF-indication and Tx Power gain
 	 * index diff of legacy to HT OFDM rate. */
-	tempval = (*(u8 *)&hwinfo[EEPROM_RFIND_POWERDIFF]) & 0xff;
+	tempval = hwinfo[EEPROM_RFIND_POWERDIFF] & 0xff;
 	rtlefuse->eeprom_txpowerdiff = tempval;
 	rtlefuse->legacy_httxpowerdiff =
 		rtlefuse->txpwr_legacyhtdiff[RF90_PATH_A][0];
@@ -1887,7 +1885,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	/* Get TSSI value for each path. */
 	usvalue = *(u16 *)&hwinfo[EEPROM_TSSI_A];
 	rtlefuse->eeprom_tssi[RF90_PATH_A] = (u8)((usvalue & 0xff00) >> 8);
-	usvalue = *(u8 *)&hwinfo[EEPROM_TSSI_B];
+	usvalue = hwinfo[EEPROM_TSSI_B];
 	rtlefuse->eeprom_tssi[RF90_PATH_B] = (u8)(usvalue & 0xff);
 
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower, "TSSI_A = 0x%x, TSSI_B = 0x%x\n",
@@ -1896,7 +1894,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 
 	/* Read antenna tx power offset of B/C/D to A  from EEPROM */
 	/* and read ThermalMeter from EEPROM */
-	tempval = *(u8 *)&hwinfo[EEPROM_THERMALMETER];
+	tempval = hwinfo[EEPROM_THERMALMETER];
 	rtlefuse->eeprom_thermalmeter = tempval;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
 		"thermalmeter = 0x%x\n", rtlefuse->eeprom_thermalmeter);
@@ -1906,20 +1904,20 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 	rtlefuse->tssi_13dbm = rtlefuse->eeprom_thermalmeter * 100;
 
 	/* Read CrystalCap from EEPROM */
-	tempval = (*(u8 *)&hwinfo[EEPROM_CRYSTALCAP]) >> 4;
+	tempval = hwinfo[EEPROM_CRYSTALCAP] >> 4;
 	rtlefuse->eeprom_crystalcap = tempval;
 	/* CrystalCap, BIT(12)~15 */
 	rtlefuse->crystalcap = rtlefuse->eeprom_crystalcap;
 
 	/* Read IC Version && Channel Plan */
 	/* Version ID, Channel plan */
-	rtlefuse->eeprom_channelplan = *(u8 *)&hwinfo[EEPROM_CHANNELPLAN];
+	rtlefuse->eeprom_channelplan = hwinfo[EEPROM_CHANNELPLAN];
 	rtlefuse->txpwr_fromeprom = true;
 	RTPRINT(rtlpriv, FINIT, INIT_TxPower,
 		"EEPROM ChannelPlan = 0x%4x\n", rtlefuse->eeprom_channelplan);
 
 	/* Read Customer ID or Board Type!!! */
-	tempval = *(u8 *)&hwinfo[EEPROM_BOARDTYPE];
+	tempval = hwinfo[EEPROM_BOARDTYPE];
 	/* Change RF type definition */
 	if (tempval == 0)
 		rtlphy->rf_type = RF_2T2R;
@@ -1941,7 +1939,7 @@ static void _rtl92se_read_adapter_info(struct ieee80211_hw *hw)
 		}
 	}
 	rtlefuse->b1ss_support = rtlefuse->b1x1_recvcombine;
-	rtlefuse->eeprom_oemid = *(u8 *)&hwinfo[EEPROM_CUSTOMID];
+	rtlefuse->eeprom_oemid = *&hwinfo[EEPROM_CUSTOMID];
 
 	RT_TRACE(rtlpriv, COMP_INIT, DBG_LOUD, "EEPROM Customer ID: 0x%2x",
 		 rtlefuse->eeprom_oemid);
@@ -2251,7 +2249,7 @@ void rtl92se_update_channel_access_setting(struct ieee80211_hw *hw)
 	u16 sifs_timer;
 
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SLOT_TIME,
-				      (u8 *)&mac->slot_time);
+				      &mac->slot_time);
 	sifs_timer = 0x0e0e;
 	rtlpriv->cfg->ops->set_hw_reg(hw, HW_VAR_SIFS, (u8 *)&sifs_timer);
 
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
index 812b585..36d1cb3 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -599,7 +599,7 @@ void rtl92se_tx_fill_desc(struct ieee80211_hw *hw,
 	struct rtl_pci *rtlpci = rtl_pcidev(rtl_pcipriv(hw));
 	struct rtl_hal *rtlhal = rtl_hal(rtl_priv(hw));
 	struct ieee80211_sta *sta = info->control.sta;
-	u8 *pdesc = (u8 *) pdesc_tx;
+	u8 *pdesc = pdesc_tx;
 	u16 seq_number;
 	__le16 fc = hdr->frame_control;
 	u8 reserved_macid = 0;
diff --git a/drivers/net/wireless/ti/wlcore/tx.c b/drivers/net/wireless/ti/wlcore/tx.c
index 6893bc2..3fb5955 100644
--- a/drivers/net/wireless/ti/wlcore/tx.c
+++ b/drivers/net/wireless/ti/wlcore/tx.c
@@ -871,8 +871,7 @@ static void wl1271_tx_complete_packet(struct wl1271 *wl,
 /* Called upon reception of a TX complete interrupt */
 void wl1271_tx_complete(struct wl1271 *wl)
 {
-	struct wl1271_acx_mem_map *memmap =
-		(struct wl1271_acx_mem_map *)wl->target_mem_map;
+	struct wl1271_acx_mem_map *memmap = wl->target_mem_map;
 	u32 count, fw_counter;
 	u32 i;
 
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 117c412..7ab9222 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -827,7 +827,7 @@ int zd_ioread32v_locked(struct zd_chip *chip, u32 *values,
 static inline int zd_ioread32_locked(struct zd_chip *chip, u32 *value,
 	                             const zd_addr_t addr)
 {
-	return zd_ioread32v_locked(chip, value, (const zd_addr_t *)&addr, 1);
+	return zd_ioread32v_locked(chip, value, &addr, 1);
 }
 
 static inline int zd_iowrite16_locked(struct zd_chip *chip, u16 value,
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index 99193b4..45e3bb2 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -274,7 +274,7 @@ int zd_usb_ioread16v(struct zd_usb *usb, u16 *values,
 static inline int zd_usb_ioread16(struct zd_usb *usb, u16 *value,
 	                      const zd_addr_t addr)
 {
-	return zd_usb_ioread16v(usb, value, (const zd_addr_t *)&addr, 1);
+	return zd_usb_ioread16v(usb, value, &addr, 1);
 }
 
 void zd_usb_iowrite16v_async_start(struct zd_usb *usb);
-- 
1.7.8.111.gad25c.dirty
