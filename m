From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 04/14] wireless: Use eth_<foo>_addr instead of memset
Date: Mon,  2 Mar 2015 19:54:49 -0800
Message-ID: <5078ca23b564b061e56df74ef78ebdeec459a77d.1425354528.git.joe@perches.com>
References: <cover.1425354527.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
 Johannes Berg <johannes.berg@intel.com>, libertas-dev@lists.infradead.org,
 brcm80211-dev-list@broadcom.com, Brett Rudley <brudley@broadcom.com>,
 linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
 ath10k@lists.infradead.org, Intel Linux Wireless <ilw@linux.intel.com>,
 Hante Meuleman <meuleman@broadcom.com>, ath9k-devel@lists.ath9k.org,
 b43-dev@lists.infradead.org, "Franky \(Zhenhui\) Lin" <frankyl@broadcom.com>,
 Arend van Spriel <arend@broadcom.com>
To: netdev@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
 Jiri Slaby <jirislaby@gmail.com>, Nick Kossifidis <mickflemm@gmail.com>,
 "Luis R. Rodriguez" <mcgrof@do-not-panic.com>,
 QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
 Simon Kelley <simon@thekelleys.org.uk>,
 Stefano Brivio <stefano.brivio@polimi.it>,
 Larry Finger <Larry.Finger@lwfinger.net>,
 Solomon Peachy <pizza@shaftnet.org>, Jouni Malinen <j@w1.fi>,
 Stanislav Yakovlev <stas.yakovlev@gmail.com>,
 Stanislaw Gruszka <sgruszka@redhat.com>,
 Amitkumar Karwar <akarwar@marvell.com>, Avinash Patil <patila@marvell.com>,
 Lennert Buytenhek <buytenh@wantstofly.org>,
 Christian Lamparter <chunkeey@googlemail.com>,
 Jussi Kivilinna <jussi.kivilinna@iki.fi>,
 Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org>
In-Reply-To: <cover.1425354527.git.joe@perches.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/ath10k/>
List-Post: <mailto:ath10k@lists.infradead.org>
List-Help: <mailto:ath10k-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/ath10k>,
 <mailto:ath10k-request@lists.infradead.org?subject=subscribe>
Sender: "ath10k" <ath10k-bounces@lists.infradead.org>
Errors-To: ath10k-bounces+gldad-ath10k=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Use the built-in function instead of memset.

Miscellanea:

Add #include <linux/etherdevice.h> where appropriate
Use ETH_ALEN instead of 6

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/airo.c                        |  4 +--
 drivers/net/wireless/at76c50x-usb.c                |  6 ++--
 drivers/net/wireless/ath/ath10k/mac.c              |  2 +-
 drivers/net/wireless/ath/ath5k/base.c              |  2 +-
 drivers/net/wireless/ath/ath6kl/cfg80211.c         |  2 +-
 drivers/net/wireless/ath/ath6kl/main.c             |  2 +-
 drivers/net/wireless/ath/ath9k/htc_drv_main.c      |  2 +-
 drivers/net/wireless/ath/ath9k/main.c              |  4 +--
 drivers/net/wireless/atmel.c                       | 16 +++++------
 drivers/net/wireless/b43/main.c                    |  8 +++---
 drivers/net/wireless/b43legacy/main.c              |  8 +++---
 drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c | 12 ++++----
 drivers/net/wireless/brcm80211/brcmfmac/flowring.c |  2 +-
 drivers/net/wireless/brcm80211/brcmfmac/p2p.c      |  2 +-
 drivers/net/wireless/cw1200/sta.c                  |  2 +-
 drivers/net/wireless/cw1200/txrx.c                 |  2 +-
 drivers/net/wireless/hostap/hostap_80211_tx.c      |  4 +--
 drivers/net/wireless/hostap/hostap_ap.c            |  8 +++---
 drivers/net/wireless/hostap/hostap_info.c          |  2 +-
 drivers/net/wireless/hostap/hostap_main.c          |  4 +--
 drivers/net/wireless/hostap/hostap_wlan.h          | 33 +++++++++++-----------
 drivers/net/wireless/ipw2x00/ipw2100.c             |  8 +++---
 drivers/net/wireless/ipw2x00/ipw2200.c             |  6 ++--
 drivers/net/wireless/iwlegacy/common.c             |  2 +-
 drivers/net/wireless/iwlwifi/mvm/power.c           |  3 +-
 drivers/net/wireless/libertas/main.c               |  4 +--
 drivers/net/wireless/libertas_tf/main.c            |  4 +--
 drivers/net/wireless/mac80211_hwsim.c              |  6 ++--
 drivers/net/wireless/mwifiex/cfg80211.c            |  8 +++---
 drivers/net/wireless/mwifiex/init.c                |  4 +--
 drivers/net/wireless/mwifiex/sta_event.c           |  2 +-
 drivers/net/wireless/mwifiex/wmm.c                 |  2 +-
 drivers/net/wireless/mwl8k.c                       |  2 +-
 drivers/net/wireless/orinoco/wext.c                |  2 +-
 drivers/net/wireless/p54/fwio.c                    |  2 +-
 drivers/net/wireless/p54/main.c                    |  8 +++---
 drivers/net/wireless/ray_cs.c                      |  2 +-
 drivers/net/wireless/rndis_wlan.c                  | 28 +++++++++---------
 drivers/net/wireless/rtlwifi/core.c                |  6 ++--
 drivers/net/wireless/ti/wl1251/main.c              |  4 +--
 drivers/net/wireless/ti/wlcore/cmd.c               |  4 +--
 41 files changed, 118 insertions(+), 116 deletions(-)

diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index e71a2ce..6274432 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -2676,7 +2676,7 @@ static void wifi_setup(struct net_device *dev)
 	dev->addr_len           = ETH_ALEN;
 	dev->tx_queue_len       = 100; 
 
-	memset(dev->broadcast,0xFF, ETH_ALEN);
+	eth_broadcast_addr(dev->broadcast);
 
 	dev->flags              = IFF_BROADCAST|IFF_MULTICAST;
 }
@@ -3273,7 +3273,7 @@ static void airo_handle_link(struct airo_info *ai)
 		}
 
 		/* Send event to user space */
-		memset(wrqu.ap_addr.sa_data, '\0', ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 		wireless_send_event(ai->dev, SIOCGIWAP, &wrqu, NULL);
 	}
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index da92bfa..49219c5 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -1166,7 +1166,7 @@ static int at76_start_monitor(struct at76_priv *priv)
 	int ret;
 
 	memset(&scan, 0, sizeof(struct at76_req_scan));
-	memset(scan.bssid, 0xff, ETH_ALEN);
+	eth_broadcast_addr(scan.bssid);
 
 	scan.channel = priv->channel;
 	scan.scan_type = SCAN_TYPE_PASSIVE;
@@ -1427,7 +1427,7 @@ static int at76_startup_device(struct at76_priv *priv)
 	at76_wait_completion(priv, CMD_STARTUP);
 
 	/* remove BSSID from previous run */
-	memset(priv->bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->bssid);
 
 	priv->scanning = false;
 
@@ -1973,7 +1973,7 @@ static int at76_hw_scan(struct ieee80211_hw *hw,
 	ieee80211_stop_queues(hw);
 
 	memset(&scan, 0, sizeof(struct at76_req_scan));
-	memset(scan.bssid, 0xFF, ETH_ALEN);
+	eth_broadcast_addr(scan.bssid);
 
 	if (req->n_ssids) {
 		scan.scan_type = SCAN_TYPE_ACTIVE;
diff --git a/drivers/net/wireless/ath/ath10k/mac.c b/drivers/net/wireless/ath/ath10k/mac.c
index d6d2f0f..6c364bb 100644
--- a/drivers/net/wireless/ath/ath10k/mac.c
+++ b/drivers/net/wireless/ath/ath10k/mac.c
@@ -1182,7 +1182,7 @@ static void ath10k_control_ibss(struct ath10k_vif *arvif,
 		if (is_zero_ether_addr(arvif->bssid))
 			return;
 
-		memset(arvif->bssid, 0, ETH_ALEN);
+		eth_zero_addr(arvif->bssid);
 
 		return;
 	}
diff --git a/drivers/net/wireless/ath/ath5k/base.c b/drivers/net/wireless/ath/ath5k/base.c
index bc9cb35..57a80e8 100644
--- a/drivers/net/wireless/ath/ath5k/base.c
+++ b/drivers/net/wireless/ath/ath5k/base.c
@@ -528,7 +528,7 @@ ath5k_update_bssid_mask_and_opmode(struct ath5k_hw *ah,
 	 * together with the BSSID mask when matching addresses.
 	 */
 	iter_data.hw_macaddr = common->macaddr;
-	memset(&iter_data.mask, 0xff, ETH_ALEN);
+	eth_broadcast_addr(iter_data.mask);
 	iter_data.found_active = false;
 	iter_data.need_set_hw_addr = true;
 	iter_data.opmode = NL80211_IFTYPE_UNSPECIFIED;
diff --git a/drivers/net/wireless/ath/ath6kl/cfg80211.c b/drivers/net/wireless/ath/ath6kl/cfg80211.c
index 85da63a..e297803 100644
--- a/drivers/net/wireless/ath/ath6kl/cfg80211.c
+++ b/drivers/net/wireless/ath/ath6kl/cfg80211.c
@@ -2033,7 +2033,7 @@ static int ath6kl_wow_sta(struct ath6kl *ar, struct ath6kl_vif *vif)
 	int ret;
 
 	/* Setup unicast pkt pattern */
-	memset(mac_mask, 0xff, ETH_ALEN);
+	eth_broadcast_addr(mac_mask);
 	ret = ath6kl_wmi_add_wow_pattern_cmd(ar->wmi,
 				vif->fw_vif_idx, WOW_LIST_ID,
 				ETH_ALEN, 0, ndev->dev_addr,
diff --git a/drivers/net/wireless/ath/ath6kl/main.c b/drivers/net/wireless/ath/ath6kl/main.c
index b42ba46..1af3fed 100644
--- a/drivers/net/wireless/ath/ath6kl/main.c
+++ b/drivers/net/wireless/ath/ath6kl/main.c
@@ -105,7 +105,7 @@ static void ath6kl_sta_cleanup(struct ath6kl *ar, u8 i)
 
 	memset(&ar->ap_stats.sta[sta->aid - 1], 0,
 	       sizeof(struct wmi_per_sta_stat));
-	memset(sta->mac, 0, ETH_ALEN);
+	eth_zero_addr(sta->mac);
 	memset(sta->wpa_ie, 0, ATH6KL_MAX_IE);
 	sta->aid = 0;
 	sta->sta_flags = 0;
diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_main.c b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
index 92d5a6c..564923c 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_main.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_main.c
@@ -149,7 +149,7 @@ static void ath9k_htc_set_mac_bssid_mask(struct ath9k_htc_priv *priv,
 	 * when matching addresses.
 	 */
 	iter_data.hw_macaddr = NULL;
-	memset(&iter_data.mask, 0xff, ETH_ALEN);
+	eth_broadcast_addr(iter_data.mask);
 
 	if (vif)
 		ath9k_htc_bssid_iter(&iter_data, vif->addr, vif);
diff --git a/drivers/net/wireless/ath/ath9k/main.c b/drivers/net/wireless/ath/ath9k/main.c
index 9ede991..93ed99a 100644
--- a/drivers/net/wireless/ath/ath9k/main.c
+++ b/drivers/net/wireless/ath/ath9k/main.c
@@ -994,7 +994,7 @@ void ath9k_calculate_iter_data(struct ath_softc *sc,
 	 * BSSID mask when matching addresses.
 	 */
 	memset(iter_data, 0, sizeof(*iter_data));
-	memset(&iter_data->mask, 0xff, ETH_ALEN);
+	eth_broadcast_addr(iter_data->mask);
 	iter_data->slottime = ATH9K_SLOT_TIME_9;
 
 	list_for_each_entry(avp, &ctx->vifs, list)
@@ -1139,7 +1139,7 @@ void ath9k_calculate_summary_state(struct ath_softc *sc,
 			ctx->primary_sta = iter_data.primary_sta;
 		} else {
 			ctx->primary_sta = NULL;
-			memset(common->curbssid, 0, ETH_ALEN);
+			eth_zero_addr(common->curbssid);
 			common->curaid = 0;
 			ath9k_hw_write_associd(sc->sc_ah);
 			if (ath9k_hw_mci_is_enabled(sc->sc_ah))
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 55db9f0..6a1f03c 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1004,7 +1004,7 @@ static void frag_rx_path(struct atmel_private *priv,
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
 				priv->dev->stats.rx_crc_errors++;
-				memset(priv->frag_source, 0xff, ETH_ALEN);
+				eth_broadcast_addr(priv->frag_source);
 			}
 		}
 
@@ -1022,7 +1022,7 @@ static void frag_rx_path(struct atmel_private *priv,
 			atmel_copy_to_host(priv->dev, (void *)&netcrc, rx_packet_loc + msdu_size, 4);
 			if ((crc ^ 0xffffffff) != netcrc) {
 				priv->dev->stats.rx_crc_errors++;
-				memset(priv->frag_source, 0xff, ETH_ALEN);
+				eth_broadcast_addr(priv->frag_source);
 				more_frags = 1; /* don't send broken assembly */
 			}
 		}
@@ -1031,7 +1031,7 @@ static void frag_rx_path(struct atmel_private *priv,
 		priv->frag_no++;
 
 		if (!more_frags) { /* last one */
-			memset(priv->frag_source, 0xff, ETH_ALEN);
+			eth_broadcast_addr(priv->frag_source);
 			if (!(skb = dev_alloc_skb(priv->frag_len + 14))) {
 				priv->dev->stats.rx_dropped++;
 			} else {
@@ -1127,7 +1127,7 @@ static void rx_done_irq(struct atmel_private *priv)
 			atmel_copy_to_host(priv->dev, (unsigned char *)&priv->rx_buf, rx_packet_loc + 24, msdu_size);
 
 			/* we use the same buffer for frag reassembly and control packets */
-			memset(priv->frag_source, 0xff, ETH_ALEN);
+			eth_broadcast_addr(priv->frag_source);
 
 			if (priv->do_rx_crc) {
 				/* last 4 octets is crc */
@@ -1379,7 +1379,7 @@ static int atmel_close(struct net_device *dev)
 		wrqu.data.length = 0;
 		wrqu.data.flags = 0;
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
 	}
 
@@ -1555,7 +1555,7 @@ struct net_device *init_atmel_card(unsigned short irq, unsigned long port,
 	priv->last_qual = jiffies;
 	priv->last_beacon_timestamp = 0;
 	memset(priv->frag_source, 0xff, sizeof(priv->frag_source));
-	memset(priv->BSSID, 0, ETH_ALEN);
+	eth_zero_addr(priv->BSSID);
 	priv->CurrentBSSID[0] = 0xFF; /* Initialize to something invalid.... */
 	priv->station_was_associated = 0;
 
@@ -2760,7 +2760,7 @@ static void atmel_scan(struct atmel_private *priv, int specific_ssid)
 		u8 SSID_size;
 	} cmd;
 
-	memset(cmd.BSSID, 0xff, ETH_ALEN);
+	eth_broadcast_addr(cmd.BSSID);
 
 	if (priv->fast_scan) {
 		cmd.SSID_size = priv->SSID_size;
@@ -4049,7 +4049,7 @@ static int reset_atmel_card(struct net_device *dev)
 		wrqu.data.length = 0;
 		wrqu.data.flags = 0;
 		wrqu.ap_addr.sa_family = ARPHRD_ETHER;
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 		wireless_send_event(priv->dev, SIOCGIWAP, &wrqu, NULL);
 	}
 
diff --git a/drivers/net/wireless/b43/main.c b/drivers/net/wireless/b43/main.c
index ccbdb05..31c7e4d 100644
--- a/drivers/net/wireless/b43/main.c
+++ b/drivers/net/wireless/b43/main.c
@@ -4132,7 +4132,7 @@ static void b43_op_bss_info_changed(struct ieee80211_hw *hw,
 		if (conf->bssid)
 			memcpy(wl->bssid, conf->bssid, ETH_ALEN);
 		else
-			memset(wl->bssid, 0, ETH_ALEN);
+			eth_zero_addr(wl->bssid);
 	}
 
 	if (b43_status(dev) >= B43_STAT_INITIALIZED) {
@@ -5051,7 +5051,7 @@ static void b43_op_remove_interface(struct ieee80211_hw *hw,
 	wl->operating = false;
 
 	b43_adjust_opmode(dev);
-	memset(wl->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(wl->mac_addr);
 	b43_upload_card_macaddress(dev);
 
 	mutex_unlock(&wl->mutex);
@@ -5067,8 +5067,8 @@ static int b43_op_start(struct ieee80211_hw *hw)
 	/* Kill all old instance specific information to make sure
 	 * the card won't use it in the short timeframe between start
 	 * and mac80211 reconfiguring it. */
-	memset(wl->bssid, 0, ETH_ALEN);
-	memset(wl->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(wl->bssid);
+	eth_zero_addr(wl->mac_addr);
 	wl->filter_flags = 0;
 	wl->radiotap_enabled = false;
 	b43_qos_clear(wl);
diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index 4e58c00..c77b7f5 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -2866,7 +2866,7 @@ static void b43legacy_op_bss_info_changed(struct ieee80211_hw *hw,
 		if (conf->bssid)
 			memcpy(wl->bssid, conf->bssid, ETH_ALEN);
 		else
-			memset(wl->bssid, 0, ETH_ALEN);
+			eth_zero_addr(wl->bssid);
 	}
 
 	if (b43legacy_status(dev) >= B43legacy_STAT_INITIALIZED) {
@@ -3470,7 +3470,7 @@ static void b43legacy_op_remove_interface(struct ieee80211_hw *hw,
 
 	spin_lock_irqsave(&wl->irq_lock, flags);
 	b43legacy_adjust_opmode(dev);
-	memset(wl->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(wl->mac_addr);
 	b43legacy_upload_card_macaddress(dev);
 	spin_unlock_irqrestore(&wl->irq_lock, flags);
 
@@ -3487,8 +3487,8 @@ static int b43legacy_op_start(struct ieee80211_hw *hw)
 	/* Kill all old instance specific information to make sure
 	 * the card won't use it in the short timeframe between start
 	 * and mac80211 reconfiguring it. */
-	memset(wl->bssid, 0, ETH_ALEN);
-	memset(wl->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(wl->bssid);
+	eth_zero_addr(wl->mac_addr);
 	wl->filter_flags = 0;
 	wl->beacon0_uploaded = false;
 	wl->beacon1_uploaded = false;
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c b/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
index b59b8c6..06727a6 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/cfg80211.c
@@ -700,7 +700,7 @@ s32 brcmf_notify_escan_complete(struct brcmf_cfg80211_info *cfg,
 		/* Do a scan abort to stop the driver's scan engine */
 		brcmf_dbg(SCAN, "ABORT scan in firmware\n");
 		memset(&params_le, 0, sizeof(params_le));
-		memset(params_le.bssid, 0xFF, ETH_ALEN);
+		eth_broadcast_addr(params_le.bssid);
 		params_le.bss_type = DOT11_BSSTYPE_ANY;
 		params_le.scan_type = 0;
 		params_le.channel_num = cpu_to_le32(1);
@@ -866,7 +866,7 @@ static void brcmf_escan_prep(struct brcmf_cfg80211_info *cfg,
 	char *ptr;
 	struct brcmf_ssid_le ssid_le;
 
-	memset(params_le->bssid, 0xFF, ETH_ALEN);
+	eth_broadcast_addr(params_le->bssid);
 	params_le->bss_type = DOT11_BSSTYPE_ANY;
 	params_le->scan_type = 0;
 	params_le->channel_num = 0;
@@ -1375,8 +1375,8 @@ brcmf_cfg80211_join_ibss(struct wiphy *wiphy, struct net_device *ndev,
 				   BRCMF_ASSOC_PARAMS_FIXED_SIZE;
 		memcpy(profile->bssid, params->bssid, ETH_ALEN);
 	} else {
-		memset(join_params.params_le.bssid, 0xFF, ETH_ALEN);
-		memset(profile->bssid, 0, ETH_ALEN);
+		eth_broadcast_addr(join_params.params_le.bssid);
+		eth_zero_addr(profile->bssid);
 	}
 
 	/* Channel */
@@ -1850,7 +1850,7 @@ brcmf_cfg80211_connect(struct wiphy *wiphy, struct net_device *ndev,
 	if (sme->bssid)
 		memcpy(&ext_join_params->assoc_le.bssid, sme->bssid, ETH_ALEN);
 	else
-		memset(&ext_join_params->assoc_le.bssid, 0xFF, ETH_ALEN);
+		eth_broadcast_addr(ext_join_params->assoc_le.bssid);
 
 	if (cfg->channel) {
 		ext_join_params->assoc_le.chanspec_num = cpu_to_le32(1);
@@ -1895,7 +1895,7 @@ brcmf_cfg80211_connect(struct wiphy *wiphy, struct net_device *ndev,
 	if (sme->bssid)
 		memcpy(join_params.params_le.bssid, sme->bssid, ETH_ALEN);
 	else
-		memset(join_params.params_le.bssid, 0xFF, ETH_ALEN);
+		eth_broadcast_addr(join_params.params_le.bssid);
 
 	if (cfg->channel) {
 		join_params.params_le.chanspec_list[0] = cpu_to_le16(chanspec);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/flowring.c b/drivers/net/wireless/brcm80211/brcmfmac/flowring.c
index 910fbb5..eb13253 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/flowring.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/flowring.c
@@ -236,7 +236,7 @@ void brcmf_flowring_delete(struct brcmf_flowring *flow, u8 flowid)
 	brcmf_flowring_block(flow, flowid, false);
 	hash_idx = ring->hash_id;
 	flow->hash[hash_idx].ifidx = BRCMF_FLOWRING_INVALID_IFIDX;
-	memset(flow->hash[hash_idx].mac, 0, ETH_ALEN);
+	eth_zero_addr(flow->hash[hash_idx].mac);
 	flow->rings[flowid] = NULL;
 
 	skb = skb_dequeue(&ring->skblist);
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
index effb48e..98d82ec 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/p2p.c
@@ -697,7 +697,7 @@ static s32 brcmf_p2p_escan(struct brcmf_p2p_info *p2p, u32 num_chans,
 	else
 		sparams->scan_type = 1;
 
-	memset(&sparams->bssid, 0xFF, ETH_ALEN);
+	eth_broadcast_addr(sparams->bssid);
 	if (ssid.SSID_len)
 		memcpy(sparams->ssid_le.SSID, ssid.SSID, ssid.SSID_len);
 	sparams->ssid_le.SSID_len = cpu_to_le32(ssid.SSID_len);
diff --git a/drivers/net/wireless/cw1200/sta.c b/drivers/net/wireless/cw1200/sta.c
index 4a47c7f..89bc18c 100644
--- a/drivers/net/wireless/cw1200/sta.c
+++ b/drivers/net/wireless/cw1200/sta.c
@@ -293,7 +293,7 @@ void cw1200_remove_interface(struct ieee80211_hw *dev,
 	}
 	priv->vif = NULL;
 	priv->mode = NL80211_IFTYPE_MONITOR;
-	memset(priv->mac_addr, 0, ETH_ALEN);
+	eth_zero_addr(priv->mac_addr);
 	memset(&priv->p2p_ps_modeinfo, 0, sizeof(priv->p2p_ps_modeinfo));
 	cw1200_free_keys(priv);
 	cw1200_setup_mac(priv);
diff --git a/drivers/net/wireless/cw1200/txrx.c b/drivers/net/wireless/cw1200/txrx.c
index 0bd5411..d28bd49 100644
--- a/drivers/net/wireless/cw1200/txrx.c
+++ b/drivers/net/wireless/cw1200/txrx.c
@@ -1429,7 +1429,7 @@ void cw1200_link_id_gc_work(struct work_struct *work)
 				priv->link_id_map &= ~mask;
 				priv->sta_asleep_mask &= ~mask;
 				priv->pspoll_mask &= ~mask;
-				memset(map_link.mac_addr, 0, ETH_ALEN);
+				eth_zero_addr(map_link.mac_addr);
 				spin_unlock_bh(&priv->ps_state_lock);
 				reset.link_id = i + 1;
 				wsm_reset(priv, &reset);
diff --git a/drivers/net/wireless/hostap/hostap_80211_tx.c b/drivers/net/wireless/hostap/hostap_80211_tx.c
index 8bde776..055e11d 100644
--- a/drivers/net/wireless/hostap/hostap_80211_tx.c
+++ b/drivers/net/wireless/hostap/hostap_80211_tx.c
@@ -174,8 +174,8 @@ netdev_tx_t hostap_data_start_xmit(struct sk_buff *skb,
 		/* send broadcast and multicast frames to broadcast RA, if
 		 * configured; otherwise, use unicast RA of the WDS link */
 		if ((local->wds_type & HOSTAP_WDS_BROADCAST_RA) &&
-		    skb->data[0] & 0x01)
-			memset(&hdr.addr1, 0xff, ETH_ALEN);
+		    is_multicast_ether_addr(skb->data))
+			eth_broadcast_addr(hdr.addr1);
 		else if (iface->type == HOSTAP_INTERFACE_WDS)
 			memcpy(&hdr.addr1, iface->u.wds.remote_addr,
 			       ETH_ALEN);
diff --git a/drivers/net/wireless/hostap/hostap_ap.c b/drivers/net/wireless/hostap/hostap_ap.c
index fd8d83d..c995ace 100644
--- a/drivers/net/wireless/hostap/hostap_ap.c
+++ b/drivers/net/wireless/hostap/hostap_ap.c
@@ -309,7 +309,7 @@ void hostap_deauth_all_stas(struct net_device *dev, struct ap_data *ap,
 	int i;
 
 	PDEBUG(DEBUG_AP, "%s: Deauthenticate all stations\n", dev->name);
-	memset(addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(addr);
 
 	resp = cpu_to_le16(WLAN_REASON_PREV_AUTH_NOT_VALID);
 
@@ -1015,8 +1015,8 @@ static void prism2_send_mgmt(struct net_device *dev,
 		memcpy(hdr->addr3, dev->dev_addr, ETH_ALEN); /* SA */
 	} else if (ieee80211_is_ctl(hdr->frame_control)) {
 		/* control:ACK does not have addr2 or addr3 */
-		memset(hdr->addr2, 0, ETH_ALEN);
-		memset(hdr->addr3, 0, ETH_ALEN);
+		eth_zero_addr(hdr->addr2);
+		eth_zero_addr(hdr->addr3);
 	} else {
 		memcpy(hdr->addr2, dev->dev_addr, ETH_ALEN); /* SA */
 		memcpy(hdr->addr3, dev->dev_addr, ETH_ALEN); /* BSSID */
@@ -1601,7 +1601,7 @@ static void handle_assoc(local_info_t *local, struct sk_buff *skb,
 		memcpy(prev_ap, pos, ETH_ALEN);
 		pos++; pos++; pos++; left -= 6;
 	} else
-		memset(prev_ap, 0, ETH_ALEN);
+		eth_zero_addr(prev_ap);
 
 	if (left >= 2) {
 		unsigned int ileft;
diff --git a/drivers/net/wireless/hostap/hostap_info.c b/drivers/net/wireless/hostap/hostap_info.c
index de7c4ff..7635ac4 100644
--- a/drivers/net/wireless/hostap/hostap_info.c
+++ b/drivers/net/wireless/hostap/hostap_info.c
@@ -442,7 +442,7 @@ static void handle_info_queue_linkstatus(local_info_t *local)
 	} else {
 		netif_carrier_off(local->dev);
 		netif_carrier_off(local->ddev);
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 	}
 	wrqu.ap_addr.sa_family = ARPHRD_ETHER;
 
diff --git a/drivers/net/wireless/hostap/hostap_main.c b/drivers/net/wireless/hostap/hostap_main.c
index 8f9f3e9..01de1a3 100644
--- a/drivers/net/wireless/hostap/hostap_main.c
+++ b/drivers/net/wireless/hostap/hostap_main.c
@@ -224,7 +224,7 @@ int prism2_wds_del(local_info_t *local, u8 *remote_addr,
 
 	if (selected) {
 		if (do_not_remove)
-			memset(selected->u.wds.remote_addr, 0, ETH_ALEN);
+			eth_zero_addr(selected->u.wds.remote_addr);
 		else {
 			hostap_remove_interface(selected->dev, rtnl_locked, 0);
 			local->wds_connections--;
@@ -1087,7 +1087,7 @@ int prism2_sta_deauth(local_info_t *local, u16 reason)
 
 	ret = prism2_sta_send_mgmt(local, local->bssid, IEEE80211_STYPE_DEAUTH,
 				   (u8 *) &val, 2);
-	memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+	eth_zero_addr(wrqu.ap_addr.sa_data);
 	wireless_send_event(local->dev, SIOCGIWAP, &wrqu, NULL);
 	return ret;
 }
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 5790401..ca25283 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -4,6 +4,7 @@
 #include <linux/interrupt.h>
 #include <linux/wireless.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/mutex.h>
 #include <net/iw_handler.h>
 #include <net/ieee80211_radiotap.h>
@@ -85,16 +86,16 @@ struct hfa384x_rx_frame {
 	/* 802.11 */
 	__le16 frame_control;
 	__le16 duration_id;
-	u8 addr1[6];
-	u8 addr2[6];
-	u8 addr3[6];
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN];
+	u8 addr3[ETH_ALEN];
 	__le16 seq_ctrl;
-	u8 addr4[6];
+	u8 addr4[ETH_ALEN];
 	__le16 data_len;
 
 	/* 802.3 */
-	u8 dst_addr[6];
-	u8 src_addr[6];
+	u8 dst_addr[ETH_ALEN];
+	u8 src_addr[ETH_ALEN];
 	__be16 len;
 
 	/* followed by frame data; max 2304 bytes */
@@ -114,16 +115,16 @@ struct hfa384x_tx_frame {
 	/* 802.11 */
 	__le16 frame_control; /* parts not used */
 	__le16 duration_id;
-	u8 addr1[6];
-	u8 addr2[6]; /* filled by firmware */
-	u8 addr3[6];
+	u8 addr1[ETH_ALEN];
+	u8 addr2[ETH_ALEN]; /* filled by firmware */
+	u8 addr3[ETH_ALEN];
 	__le16 seq_ctrl; /* filled by firmware */
-	u8 addr4[6];
+	u8 addr4[ETH_ALEN];
 	__le16 data_len;
 
 	/* 802.3 */
-	u8 dst_addr[6];
-	u8 src_addr[6];
+	u8 dst_addr[ETH_ALEN];
+	u8 src_addr[ETH_ALEN];
 	__be16 len;
 
 	/* followed by frame data; max 2304 bytes */
@@ -156,7 +157,7 @@ struct hfa384x_hostscan_request {
 } __packed;
 
 struct hfa384x_join_request {
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	__le16 channel;
 } __packed;
 
@@ -228,7 +229,7 @@ struct hfa384x_scan_result {
 	__le16 chid;
 	__le16 anl;
 	__le16 sl;
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	__le16 beacon_interval;
 	__le16 capability;
 	__le16 ssid_len;
@@ -241,7 +242,7 @@ struct hfa384x_hostscan_result {
 	__le16 chid;
 	__le16 anl;
 	__le16 sl;
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	__le16 beacon_interval;
 	__le16 capability;
 	__le16 ssid_len;
@@ -824,7 +825,7 @@ struct local_info {
 #define PRISM2_INFO_PENDING_SCANRESULTS 1
 	int prev_link_status; /* previous received LinkStatus info */
 	int prev_linkstatus_connected;
-	u8 preferred_ap[6]; /* use this AP if possible */
+	u8 preferred_ap[ETH_ALEN]; /* use this AP if possible */
 
 #ifdef PRISM2_CALLBACK
 	void *callback_data; /* Can be used in callbacks; e.g., allocate
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 6fabea0..08eb229 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -2147,8 +2147,8 @@ static void isr_indicate_association_lost(struct ipw2100_priv *priv, u32 status)
 		return;
 	}
 
-	memset(priv->bssid, 0, ETH_ALEN);
-	memset(priv->ieee->bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->bssid);
+	eth_zero_addr(priv->ieee->bssid);
 
 	netif_carrier_off(priv->net_dev);
 	netif_stop_queue(priv->net_dev);
@@ -6956,7 +6956,7 @@ static int ipw2100_wx_get_wap(struct net_device *dev,
 		wrqu->ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(wrqu->ap_addr.sa_data, priv->bssid, ETH_ALEN);
 	} else
-		memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu->ap_addr.sa_data);
 
 	IPW_DEBUG_WX("Getting WAP BSSID: %pM\n", wrqu->ap_addr.sa_data);
 	return 0;
@@ -8300,7 +8300,7 @@ static void ipw2100_wx_event_work(struct work_struct *work)
 	    priv->status & STATUS_RF_KILL_MASK ||
 	    ipw2100_get_ordinal(priv, IPW_ORD_STAT_ASSN_AP_BSSID,
 				&priv->bssid, &len)) {
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 	} else {
 		/* We now have the BSSID, so can finish setting to the full
 		 * associated state */
diff --git a/drivers/net/wireless/ipw2x00/ipw2200.c b/drivers/net/wireless/ipw2x00/ipw2200.c
index 67cad9b..39f3e6f 100644
--- a/drivers/net/wireless/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/ipw2x00/ipw2200.c
@@ -1964,7 +1964,7 @@ static void notify_wx_assoc_event(struct ipw_priv *priv)
 	if (priv->status & STATUS_ASSOCIATED)
 		memcpy(wrqu.ap_addr.sa_data, priv->bssid, ETH_ALEN);
 	else
-		memset(wrqu.ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu.ap_addr.sa_data);
 	wireless_send_event(priv->net_dev, SIOCGIWAP, &wrqu, NULL);
 }
 
@@ -7400,7 +7400,7 @@ static int ipw_associate_network(struct ipw_priv *priv,
 	memcpy(priv->assoc_request.bssid, network->bssid, ETH_ALEN);
 
 	if (priv->ieee->iw_mode == IW_MODE_ADHOC) {
-		memset(&priv->assoc_request.dest, 0xFF, ETH_ALEN);
+		eth_broadcast_addr(priv->assoc_request.dest);
 		priv->assoc_request.atim_window = cpu_to_le16(network->atim_window);
 	} else {
 		memcpy(priv->assoc_request.dest, network->bssid, ETH_ALEN);
@@ -8986,7 +8986,7 @@ static int ipw_wx_get_wap(struct net_device *dev,
 		wrqu->ap_addr.sa_family = ARPHRD_ETHER;
 		memcpy(wrqu->ap_addr.sa_data, priv->bssid, ETH_ALEN);
 	} else
-		memset(wrqu->ap_addr.sa_data, 0, ETH_ALEN);
+		eth_zero_addr(wrqu->ap_addr.sa_data);
 
 	IPW_DEBUG_WX("Getting WAP BSSID: %pM\n",
 		     wrqu->ap_addr.sa_data);
diff --git a/drivers/net/wireless/iwlegacy/common.c b/drivers/net/wireless/iwlegacy/common.c
index 2c4fa49..8871145 100644
--- a/drivers/net/wireless/iwlegacy/common.c
+++ b/drivers/net/wireless/iwlegacy/common.c
@@ -4634,7 +4634,7 @@ il_mac_remove_interface(struct ieee80211_hw *hw, struct ieee80211_vif *vif)
 	il->vif = NULL;
 	il->iw_mode = NL80211_IFTYPE_UNSPECIFIED;
 	il_teardown_interface(il, vif);
-	memset(il->bssid, 0, ETH_ALEN);
+	eth_zero_addr(il->bssid);
 
 	D_MAC80211("leave\n");
 	mutex_unlock(&il->mutex);
diff --git a/drivers/net/wireless/iwlwifi/mvm/power.c b/drivers/net/wireless/iwlwifi/mvm/power.c
index 2620dd0..33bbdde 100644
--- a/drivers/net/wireless/iwlwifi/mvm/power.c
+++ b/drivers/net/wireless/iwlwifi/mvm/power.c
@@ -66,6 +66,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/etherdevice.h>
 
 #include <net/mac80211.h>
 
@@ -491,7 +492,7 @@ void iwl_mvm_power_vif_assoc(struct iwl_mvm *mvm, struct ieee80211_vif *vif)
 
 	if (memcmp(vif->bss_conf.bssid, mvmvif->uapsd_misbehaving_bssid,
 		   ETH_ALEN))
-		memset(mvmvif->uapsd_misbehaving_bssid, 0, ETH_ALEN);
+		eth_zero_addr(mvmvif->uapsd_misbehaving_bssid);
 }
 
 static void iwl_mvm_power_uapsd_misbehav_ap_iterator(void *_data, u8 *mac,
diff --git a/drivers/net/wireless/libertas/main.c b/drivers/net/wireless/libertas/main.c
index 569b64e..8079560 100644
--- a/drivers/net/wireless/libertas/main.c
+++ b/drivers/net/wireless/libertas/main.c
@@ -667,7 +667,7 @@ static int lbs_setup_firmware(struct lbs_private *priv)
 	lbs_deb_enter(LBS_DEB_FW);
 
 	/* Read MAC address from firmware */
-	memset(priv->current_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->current_addr);
 	ret = lbs_update_hw_spec(priv);
 	if (ret)
 		goto done;
@@ -871,7 +871,7 @@ static int lbs_init_adapter(struct lbs_private *priv)
 
 	lbs_deb_enter(LBS_DEB_MAIN);
 
-	memset(priv->current_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->current_addr);
 
 	priv->connect_status = LBS_DISCONNECTED;
 	priv->channel = DEFAULT_AD_HOC_CHANNEL;
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 25c5acc..ed02e4b 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -152,7 +152,7 @@ static int lbtf_setup_firmware(struct lbtf_private *priv)
 	/*
 	 * Read priv address from HW
 	 */
-	memset(priv->current_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->current_addr);
 	ret = lbtf_update_hw_spec(priv);
 	if (ret) {
 		ret = -1;
@@ -199,7 +199,7 @@ out:
 static int lbtf_init_adapter(struct lbtf_private *priv)
 {
 	lbtf_deb_enter(LBTF_DEB_MAIN);
-	memset(priv->current_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->current_addr);
 	mutex_init(&priv->lock);
 
 	priv->vif = NULL;
diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 4a4c658..c1947c5 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -1908,7 +1908,7 @@ static void mac80211_hwsim_sw_scan_complete(struct ieee80211_hw *hw,
 
 	printk(KERN_DEBUG "hwsim sw_scan_complete\n");
 	hwsim->scanning = false;
-	memset(hwsim->scan_addr, 0, ETH_ALEN);
+	eth_zero_addr(hwsim->scan_addr);
 
 	mutex_unlock(&hwsim->mutex);
 }
@@ -2264,7 +2264,7 @@ static int mac80211_hwsim_new_radio(struct genl_info *info,
 	skb_queue_head_init(&data->pending);
 
 	SET_IEEE80211_DEV(hw, data->dev);
-	memset(addr, 0, ETH_ALEN);
+	eth_zero_addr(addr);
 	addr[0] = 0x02;
 	addr[3] = idx >> 8;
 	addr[4] = idx;
@@ -2597,7 +2597,7 @@ static void hwsim_mon_setup(struct net_device *dev)
 	ether_setup(dev);
 	dev->tx_queue_len = 0;
 	dev->type = ARPHRD_IEEE80211_RADIOTAP;
-	memset(dev->dev_addr, 0, ETH_ALEN);
+	eth_zero_addr(dev->dev_addr);
 	dev->dev_addr[0] = 0x12;
 }
 
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index 41c8e25..7c3ca2f 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1563,7 +1563,7 @@ mwifiex_cfg80211_del_station(struct wiphy *wiphy, struct net_device *dev,
 
 	wiphy_dbg(wiphy, "%s: mac address %pM\n", __func__, params->mac);
 
-	memset(deauth_mac, 0, ETH_ALEN);
+	eth_zero_addr(deauth_mac);
 
 	spin_lock_irqsave(&priv->sta_list_spinlock, flags);
 	sta_node = mwifiex_get_sta_entry(priv, params->mac);
@@ -1786,7 +1786,7 @@ mwifiex_cfg80211_disconnect(struct wiphy *wiphy, struct net_device *dev,
 	wiphy_dbg(wiphy, "info: successfully disconnected from %pM:"
 		" reason code %d\n", priv->cfg_bssid, reason_code);
 
-	memset(priv->cfg_bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->cfg_bssid);
 	priv->hs2_enabled = false;
 
 	return 0;
@@ -2046,7 +2046,7 @@ mwifiex_cfg80211_connect(struct wiphy *wiphy, struct net_device *dev,
 		dev_dbg(priv->adapter->dev,
 			"info: association to bssid %pM failed\n",
 			priv->cfg_bssid);
-		memset(priv->cfg_bssid, 0, ETH_ALEN);
+		eth_zero_addr(priv->cfg_bssid);
 
 		if (ret > 0)
 			cfg80211_connect_result(priv->netdev, priv->cfg_bssid,
@@ -2194,7 +2194,7 @@ mwifiex_cfg80211_leave_ibss(struct wiphy *wiphy, struct net_device *dev)
 	if (mwifiex_deauthenticate(priv, NULL))
 		return -EFAULT;
 
-	memset(priv->cfg_bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->cfg_bssid);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwifiex/init.c
index b77ba74..0978b1c 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -76,7 +76,7 @@ int mwifiex_init_priv(struct mwifiex_private *priv)
 	u32 i;
 
 	priv->media_connected = false;
-	memset(priv->curr_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->curr_addr);
 
 	priv->pkt_tx_ctrl = 0;
 	priv->bss_mode = NL80211_IFTYPE_UNSPECIFIED;
@@ -299,7 +299,7 @@ static void mwifiex_init_adapter(struct mwifiex_adapter *adapter)
 	adapter->ext_scan = false;
 	adapter->key_api_major_ver = 0;
 	adapter->key_api_minor_ver = 0;
-	memset(adapter->perm_addr, 0xff, ETH_ALEN);
+	eth_broadcast_addr(adapter->perm_addr);
 	adapter->iface_limit.sta_intf = MWIFIEX_MAX_STA_NUM;
 	adapter->iface_limit.uap_intf = MWIFIEX_MAX_UAP_NUM;
 	adapter->iface_limit.p2p_intf = MWIFIEX_MAX_P2P_NUM;
diff --git a/drivers/net/wireless/mwifiex/sta_event.c b/drivers/net/wireless/mwifiex/sta_event.c
index 80ffe741..64c4223 100644
--- a/drivers/net/wireless/mwifiex/sta_event.c
+++ b/drivers/net/wireless/mwifiex/sta_event.c
@@ -135,7 +135,7 @@ mwifiex_reset_connect_state(struct mwifiex_private *priv, u16 reason_code)
 		cfg80211_disconnected(priv->netdev, reason_code, NULL, 0,
 				      GFP_KERNEL);
 	}
-	memset(priv->cfg_bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->cfg_bssid);
 
 	mwifiex_stop_net_dev_queue(priv->netdev, adapter);
 	if (netif_carrier_ok(priv->netdev))
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwifiex/wmm.c
index ef717ac..0cd4f6b 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -730,7 +730,7 @@ mwifiex_wmm_add_buf_txqueue(struct mwifiex_private *priv,
 	} else {
 		memcpy(ra, skb->data, ETH_ALEN);
 		if (ra[0] & 0x01 || mwifiex_is_skb_mgmt_frame(skb))
-			memset(ra, 0xff, ETH_ALEN);
+			eth_broadcast_addr(ra);
 		ra_list = mwifiex_wmm_get_queue_raptr(priv, tid_down, ra);
 	}
 
diff --git a/drivers/net/wireless/mwl8k.c b/drivers/net/wireless/mwl8k.c
index f9b1218..9592116 100644
--- a/drivers/net/wireless/mwl8k.c
+++ b/drivers/net/wireless/mwl8k.c
@@ -1277,7 +1277,7 @@ static inline void mwl8k_save_beacon(struct ieee80211_hw *hw,
 	struct mwl8k_priv *priv = hw->priv;
 
 	priv->capture_beacon = false;
-	memset(priv->capture_bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->capture_bssid);
 
 	/*
 	 * Use GFP_ATOMIC as rxq_process is called from
diff --git a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
index 6abdaf0..1d4dae4 100644
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -168,7 +168,7 @@ static int orinoco_ioctl_setwap(struct net_device *dev,
 	if (is_zero_ether_addr(ap_addr->sa_data) ||
 	    is_broadcast_ether_addr(ap_addr->sa_data)) {
 		priv->bssid_fixed = 0;
-		memset(priv->desired_bssid, 0, ETH_ALEN);
+		eth_zero_addr(priv->desired_bssid);
 
 		/* "off" means keep existing connection */
 		if (ap_addr->sa_data[0] == 0) {
diff --git a/drivers/net/wireless/p54/fwio.c b/drivers/net/wireless/p54/fwio.c
index 5367d51..275408e 100644
--- a/drivers/net/wireless/p54/fwio.c
+++ b/drivers/net/wireless/p54/fwio.c
@@ -671,7 +671,7 @@ int p54_upload_key(struct p54_common *priv, u8 algo, int slot, u8 idx, u8 len,
 	if (addr)
 		memcpy(rxkey->mac, addr, ETH_ALEN);
 	else
-		memset(rxkey->mac, ~0, ETH_ALEN);
+		eth_broadcast_addr(rxkey->mac);
 
 	switch (algo) {
 	case P54_CRYPTO_WEP:
diff --git a/drivers/net/wireless/p54/main.c b/drivers/net/wireless/p54/main.c
index b9250d7..e79674f 100644
--- a/drivers/net/wireless/p54/main.c
+++ b/drivers/net/wireless/p54/main.c
@@ -182,7 +182,7 @@ static int p54_start(struct ieee80211_hw *dev)
 	if (err)
 		goto out;
 
-	memset(priv->bssid, ~0, ETH_ALEN);
+	eth_broadcast_addr(priv->bssid);
 	priv->mode = NL80211_IFTYPE_MONITOR;
 	err = p54_setup_mac(priv);
 	if (err) {
@@ -274,8 +274,8 @@ static void p54_remove_interface(struct ieee80211_hw *dev,
 		wait_for_completion_interruptible_timeout(&priv->beacon_comp, HZ);
 	}
 	priv->mode = NL80211_IFTYPE_MONITOR;
-	memset(priv->mac_addr, 0, ETH_ALEN);
-	memset(priv->bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->mac_addr);
+	eth_zero_addr(priv->bssid);
 	p54_setup_mac(priv);
 	mutex_unlock(&priv->conf_mutex);
 }
@@ -794,7 +794,7 @@ struct ieee80211_hw *p54_init_common(size_t priv_data_len)
 	init_completion(&priv->beacon_comp);
 	INIT_DELAYED_WORK(&priv->work, p54_work);
 
-	memset(&priv->mc_maclist[0], ~0, ETH_ALEN);
+	eth_broadcast_addr(priv->mc_maclist[0]);
 	priv->curchan = NULL;
 	p54_reset_stats(priv);
 	return dev;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 8330fa3..477f863 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -808,7 +808,7 @@ static int ray_dev_init(struct net_device *dev)
 
 	/* copy mac and broadcast addresses to linux device */
 	memcpy(dev->dev_addr, &local->sparm.b4.a_mac_addr, ADDRLEN);
-	memset(dev->broadcast, 0xff, ETH_ALEN);
+	eth_broadcast_addr(dev->broadcast);
 
 	dev_dbg(&link->dev, "ray_dev_init ending\n");
 	return 0;
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 60d44ce..d72ff8e 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -199,13 +199,13 @@ enum ndis_80211_pmkid_cand_list_flag_bits {
 
 struct ndis_80211_auth_request {
 	__le32 length;
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	u8 padding[2];
 	__le32 flags;
 } __packed;
 
 struct ndis_80211_pmkid_candidate {
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	u8 padding[2];
 	__le32 flags;
 } __packed;
@@ -248,7 +248,7 @@ struct ndis_80211_conf {
 
 struct ndis_80211_bssid_ex {
 	__le32 length;
-	u8 mac[6];
+	u8 mac[ETH_ALEN];
 	u8 padding[2];
 	struct ndis_80211_ssid ssid;
 	__le32 privacy;
@@ -283,7 +283,7 @@ struct ndis_80211_key {
 	__le32 size;
 	__le32 index;
 	__le32 length;
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	u8 padding[6];
 	u8 rsc[8];
 	u8 material[32];
@@ -292,7 +292,7 @@ struct ndis_80211_key {
 struct ndis_80211_remove_key {
 	__le32 size;
 	__le32 index;
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	u8 padding[2];
 } __packed;
 
@@ -310,7 +310,7 @@ struct ndis_80211_assoc_info {
 	struct req_ie {
 		__le16 capa;
 		__le16 listen_interval;
-		u8 cur_ap_address[6];
+		u8 cur_ap_address[ETH_ALEN];
 	} req_ie;
 	__le32 req_ie_length;
 	__le32 offset_req_ies;
@@ -338,7 +338,7 @@ struct ndis_80211_capability {
 } __packed;
 
 struct ndis_80211_bssid_info {
-	u8 bssid[6];
+	u8 bssid[ETH_ALEN];
 	u8 pmkid[16];
 } __packed;
 
@@ -1037,7 +1037,7 @@ static int get_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 			      bssid, &len);
 
 	if (ret != 0)
-		memset(bssid, 0, ETH_ALEN);
+		eth_zero_addr(bssid);
 
 	return ret;
 }
@@ -1391,7 +1391,7 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	priv->encr_keys[index].len = key_len;
 	priv->encr_keys[index].cipher = cipher;
 	memcpy(&priv->encr_keys[index].material, key, key_len);
-	memset(&priv->encr_keys[index].bssid, 0xff, ETH_ALEN);
+	eth_broadcast_addr(priv->encr_keys[index].bssid);
 
 	return 0;
 }
@@ -1466,7 +1466,7 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	} else {
 		/* group key */
 		if (priv->infra_mode == NDIS_80211_INFRA_ADHOC)
-			memset(ndis_key.bssid, 0xff, ETH_ALEN);
+			eth_broadcast_addr(ndis_key.bssid);
 		else
 			get_bssid(usbdev, ndis_key.bssid);
 	}
@@ -1486,7 +1486,7 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	if (flags & NDIS_80211_ADDKEY_PAIRWISE_KEY)
 		memcpy(&priv->encr_keys[index].bssid, ndis_key.bssid, ETH_ALEN);
 	else
-		memset(&priv->encr_keys[index].bssid, 0xff, ETH_ALEN);
+		eth_broadcast_addr(priv->encr_keys[index].bssid);
 
 	if (flags & NDIS_80211_ADDKEY_TRANSMIT_KEY)
 		priv->encr_tx_key_index = index;
@@ -2280,7 +2280,7 @@ static int rndis_disconnect(struct wiphy *wiphy, struct net_device *dev,
 	netdev_dbg(usbdev->net, "cfg80211.disconnect(%d)\n", reason_code);
 
 	priv->connected = false;
-	memset(priv->bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->bssid);
 
 	return deauthenticate(usbdev);
 }
@@ -2392,7 +2392,7 @@ static int rndis_leave_ibss(struct wiphy *wiphy, struct net_device *dev)
 	netdev_dbg(usbdev->net, "cfg80211.leave_ibss()\n");
 
 	priv->connected = false;
-	memset(priv->bssid, 0, ETH_ALEN);
+	eth_zero_addr(priv->bssid);
 
 	return deauthenticate(usbdev);
 }
@@ -2857,7 +2857,7 @@ static void rndis_wlan_do_link_down_work(struct usbnet *usbdev)
 
 	if (priv->connected) {
 		priv->connected = false;
-		memset(priv->bssid, 0, ETH_ALEN);
+		eth_zero_addr(priv->bssid);
 
 		deauthenticate(usbdev);
 
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtlwifi/core.c
index a31a127..3b3a88b 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -195,7 +195,7 @@ static void rtl_op_stop(struct ieee80211_hw *hw)
 	if (!(support_remote_wakeup &&
 	      rtlhal->enter_pnp_sleep)) {
 		mac->link_state = MAC80211_NOLINK;
-		memset(mac->bssid, 0, 6);
+		eth_zero_addr(mac->bssid);
 		mac->vendor = PEER_UNKNOWN;
 
 		/* reset sec info */
@@ -357,7 +357,7 @@ static void rtl_op_remove_interface(struct ieee80211_hw *hw,
 	mac->p2p = 0;
 	mac->vif = NULL;
 	mac->link_state = MAC80211_NOLINK;
-	memset(mac->bssid, 0, ETH_ALEN);
+	eth_zero_addr(mac->bssid);
 	mac->vendor = PEER_UNKNOWN;
 	mac->opmode = NL80211_IFTYPE_UNSPECIFIED;
 	rtlpriv->cfg->ops->set_network_type(hw, mac->opmode);
@@ -1157,7 +1157,7 @@ static void rtl_op_bss_info_changed(struct ieee80211_hw *hw,
 			if (ppsc->p2p_ps_info.p2p_ps_mode > P2P_PS_NONE)
 				rtl_p2p_ps_cmd(hw, P2P_PS_DISABLE);
 			mac->link_state = MAC80211_NOLINK;
-			memset(mac->bssid, 0, ETH_ALEN);
+			eth_zero_addr(mac->bssid);
 			mac->vendor = PEER_UNKNOWN;
 			mac->mode = 0;
 
diff --git a/drivers/net/wireless/ti/wl1251/main.c b/drivers/net/wireless/ti/wl1251/main.c
index d4ba009..d1e9a13 100644
--- a/drivers/net/wireless/ti/wl1251/main.c
+++ b/drivers/net/wireless/ti/wl1251/main.c
@@ -468,7 +468,7 @@ static void wl1251_op_stop(struct ieee80211_hw *hw)
 	wl1251_tx_flush(wl);
 	wl1251_power_off(wl);
 
-	memset(wl->bssid, 0, ETH_ALEN);
+	eth_zero_addr(wl->bssid);
 	wl->listen_int = 1;
 	wl->bss_type = MAX_BSS_TYPE;
 
@@ -547,7 +547,7 @@ static void wl1251_op_remove_interface(struct ieee80211_hw *hw,
 	mutex_lock(&wl->mutex);
 	wl1251_debug(DEBUG_MAC80211, "mac80211 remove interface");
 	wl->vif = NULL;
-	memset(wl->bssid, 0, ETH_ALEN);
+	eth_zero_addr(wl->bssid);
 	mutex_unlock(&wl->mutex);
 }
 
diff --git a/drivers/net/wireless/ti/wlcore/cmd.c b/drivers/net/wireless/ti/wlcore/cmd.c
index c26fc21..68919f8 100644
--- a/drivers/net/wireless/ti/wlcore/cmd.c
+++ b/drivers/net/wireless/ti/wlcore/cmd.c
@@ -367,7 +367,7 @@ void wl12xx_free_link(struct wl1271 *wl, struct wl12xx_vif *wlvif, u8 *hlid)
 	wl->links[*hlid].allocated_pkts = 0;
 	wl->links[*hlid].prev_freed_pkts = 0;
 	wl->links[*hlid].ba_bitmap = 0;
-	memset(wl->links[*hlid].addr, 0, ETH_ALEN);
+	eth_zero_addr(wl->links[*hlid].addr);
 
 	/*
 	 * At this point op_tx() will not add more packets to the queues. We
@@ -1293,7 +1293,7 @@ int wl1271_cmd_build_arp_rsp(struct wl1271 *wl, struct wl12xx_vif *wlvif)
 	hdr->frame_control = cpu_to_le16(fc);
 	memcpy(hdr->addr1, vif->bss_conf.bssid, ETH_ALEN);
 	memcpy(hdr->addr2, vif->addr, ETH_ALEN);
-	memset(hdr->addr3, 0xff, ETH_ALEN);
+	eth_broadcast_addr(hdr->addr3);
 
 	ret = wl1271_cmd_template_set(wl, wlvif->role_id, CMD_TEMPL_ARP_RSP,
 				      skb->data, skb->len, 0,
-- 
2.1.2
