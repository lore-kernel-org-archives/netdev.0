From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-06-27
Date: Fri, 27 Jun 2014 14:43:06 -0400
Message-ID: <20140627184306.GB8631@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="8t9RHnE3ZwKMSgU+"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--8t9RHnE3ZwKMSgU+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull the following batch of fixes for the 3.16 stream...

For the mac80211 bits, Johannes says:

"We have a fix from Eliad for a time calculation, a fix from Max for
head/tailroom when sending authentication packets, a revert that Felix
requested since the patch in question broke regulatory and a fix from
myself for an issue with a new command that we advertised in the wrong
place."

For the bluetooth bits, Gustavo says:

"A few fixes for 3.16. This pull request contains a NULL dereference fix,
and some security/pairing fixes."

For the iwlwifi bits, Emmanuel says:

"I have here a fix from Eliad for scheduled scan: it fixes a firmware
assertion. Arik reverts a patch I made that didn't take into account
that 3160 doesn't have UAPSD and hence, we can't assume that all
newer firmwares support the feature. Here too, the visible effect
is a firmware assertion. Along with that, we have a few fixes and
additions to the device list."

For the ath10k bits, Kalle says:

"Bartosz fixed an issue where we were not able to create 8 vdevs when
using DFS. Michal removed a false warning which was just confusing
people."

On top of that...

Arend van Spriel fixes a 'divide by zero' regression in brcmfmac.

Amitkumar Karwar corrects a transmit timeout in mwifiex.

---

The following changes since commit e940f5d6ba6a01f8dbb870854d5205d322452730:

  ipv6: Fix MLD Query message check (2014-06-27 00:21:50 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to f9fa39e9ace5a8abbe9597c2970828ced67261da:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-06-27 13:35:56 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: fix Tx timeout issue

Arend van Spriel (1):
      brcmfmac: assign chip id and rev in bus interface after brcmf_usb_dln=
eeded

Arik Nemtsov (1):
      Revert "iwlwifi: remove IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT flag"

Bartosz Markowski (1):
      ath10k: fix 8th virtual AP interface with DFS

Eliad Peller (2):
      cfg80211: fix elapsed_jiffies calculation
      iwlwifi: mvm: rework sched scan channel configuration

Johan Hedberg (3):
      Bluetooth: Fix overriding higher security level in SMP
      Bluetooth: Refactor authentication method lookup into its own function
      Bluetooth: Fix rejecting pairing in case of insufficient capabilities

Johannes Berg (2):
      Revert "cfg80211: Use 5MHz bandwidth by default when checking usable =
channels"
      nl80211: move set_qos_map command into split state

John W. Linville (5):
      Merge git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'for-upstream' of git://git.kernel.org/.../bluetooth/blu=
etooth
      Merge branch 'ath-current' of git://github.com/kvalo/ath
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Loic Poulain (1):
      Bluetooth: Ignore H5 non-link packets in non-active state

Lukasz Rymanowski (1):
      Bluetooth: Fix for ACL disconnect when pairing fails

Marcel Holtmann (1):
      Revert "Bluetooth: Add a new PID/VID 0cf3/e005 for AR3012."

Max Stepanov (1):
      mac80211: WEP extra head/tail room in ieee80211_send_auth

Michal Kazior (1):
      ath10k: remove unnecessary htt rx corruption check

Oren Givon (1):
      iwlwifi: update the 7265 series HW IDs

 drivers/bluetooth/ath3k.c                     |  2 -
 drivers/bluetooth/btusb.c                     |  1 -
 drivers/bluetooth/hci_h5.c                    |  1 +
 drivers/net/wireless/ath/ath10k/core.c        |  6 ++-
 drivers/net/wireless/ath/ath10k/htt_rx.c      | 18 --------
 drivers/net/wireless/brcm80211/brcmfmac/usb.c |  5 ++-
 drivers/net/wireless/iwlwifi/iwl-fw.h         |  1 +
 drivers/net/wireless/iwlwifi/mvm/mac80211.c   |  7 +++
 drivers/net/wireless/iwlwifi/mvm/scan.c       | 65 ++++++++---------------=
----
 drivers/net/wireless/iwlwifi/pcie/drv.c       |  3 +-
 drivers/net/wireless/mwifiex/main.c           |  1 +
 net/bluetooth/hci_conn.c                      | 12 ++++-
 net/bluetooth/smp.c                           | 60 +++++++++++++++++++----=
--
 net/mac80211/util.c                           |  5 ++-
 net/wireless/core.h                           |  2 +-
 net/wireless/nl80211.c                        | 11 +++--
 net/wireless/reg.c                            | 22 +++------
 17 files changed, 112 insertions(+), 110 deletions(-)

diff --git a/drivers/bluetooth/ath3k.c b/drivers/bluetooth/ath3k.c
index f98380648cb3..f50dffc0374f 100644
--- a/drivers/bluetooth/ath3k.c
+++ b/drivers/bluetooth/ath3k.c
@@ -90,7 +90,6 @@ static const struct usb_device_id ath3k_table[] =3D {
 	{ USB_DEVICE(0x0b05, 0x17d0) },
 	{ USB_DEVICE(0x0CF3, 0x0036) },
 	{ USB_DEVICE(0x0CF3, 0x3004) },
-	{ USB_DEVICE(0x0CF3, 0x3005) },
 	{ USB_DEVICE(0x0CF3, 0x3008) },
 	{ USB_DEVICE(0x0CF3, 0x311D) },
 	{ USB_DEVICE(0x0CF3, 0x311E) },
@@ -140,7 +139,6 @@ static const struct usb_device_id ath3k_blist_tbl[] =3D=
 {
 	{ USB_DEVICE(0x0b05, 0x17d0), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0CF3, 0x0036), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
-	{ USB_DEVICE(0x0cf3, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311D), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311E), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/btusb.c b/drivers/bluetooth/btusb.c
index a1c80b0c7663..6250fc2fb93a 100644
--- a/drivers/bluetooth/btusb.c
+++ b/drivers/bluetooth/btusb.c
@@ -162,7 +162,6 @@ static const struct usb_device_id blacklist_table[] =3D=
 {
 	{ USB_DEVICE(0x0b05, 0x17d0), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x0036), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3004), .driver_info =3D BTUSB_ATH3012 },
-	{ USB_DEVICE(0x0cf3, 0x3005), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x3008), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311d), .driver_info =3D BTUSB_ATH3012 },
 	{ USB_DEVICE(0x0cf3, 0x311e), .driver_info =3D BTUSB_ATH3012 },
diff --git a/drivers/bluetooth/hci_h5.c b/drivers/bluetooth/hci_h5.c
index 04680ead9275..fede8ca7147c 100644
--- a/drivers/bluetooth/hci_h5.c
+++ b/drivers/bluetooth/hci_h5.c
@@ -406,6 +406,7 @@ static int h5_rx_3wire_hdr(struct hci_uart *hu, unsigne=
d char c)
 	    H5_HDR_PKT_TYPE(hdr) !=3D HCI_3WIRE_LINK_PKT) {
 		BT_ERR("Non-link packet received in non-active state");
 		h5_reset_rx(h5);
+		return 0;
 	}
=20
 	h5->rx_func =3D h5_rx_payload;
diff --git a/drivers/net/wireless/ath/ath10k/core.c b/drivers/net/wireless/=
ath/ath10k/core.c
index 82017f56e661..e6c56c5bb0f6 100644
--- a/drivers/net/wireless/ath/ath10k/core.c
+++ b/drivers/net/wireless/ath/ath10k/core.c
@@ -795,7 +795,11 @@ int ath10k_core_start(struct ath10k *ar)
 	if (status)
 		goto err_htc_stop;
=20
-	ar->free_vdev_map =3D (1 << TARGET_NUM_VDEVS) - 1;
+	if (test_bit(ATH10K_FW_FEATURE_WMI_10X, ar->fw_features))
+		ar->free_vdev_map =3D (1 << TARGET_10X_NUM_VDEVS) - 1;
+	else
+		ar->free_vdev_map =3D (1 << TARGET_NUM_VDEVS) - 1;
+
 	INIT_LIST_HEAD(&ar->arvifs);
=20
 	if (!test_bit(ATH10K_FLAG_FIRST_BOOT_DONE, &ar->dev_flags))
diff --git a/drivers/net/wireless/ath/ath10k/htt_rx.c b/drivers/net/wireles=
s/ath/ath10k/htt_rx.c
index 6c102b1312ff..eebc860c3655 100644
--- a/drivers/net/wireless/ath/ath10k/htt_rx.c
+++ b/drivers/net/wireless/ath/ath10k/htt_rx.c
@@ -312,7 +312,6 @@ static int ath10k_htt_rx_amsdu_pop(struct ath10k_htt *h=
tt,
 	int msdu_len, msdu_chaining =3D 0;
 	struct sk_buff *msdu;
 	struct htt_rx_desc *rx_desc;
-	bool corrupted =3D false;
=20
 	lockdep_assert_held(&htt->rx_ring.lock);
=20
@@ -439,9 +438,6 @@ static int ath10k_htt_rx_amsdu_pop(struct ath10k_htt *h=
tt,
 		last_msdu =3D __le32_to_cpu(rx_desc->msdu_end.info0) &
 				RX_MSDU_END_INFO0_LAST_MSDU;
=20
-		if (msdu_chaining && !last_msdu)
-			corrupted =3D true;
-
 		if (last_msdu) {
 			msdu->next =3D NULL;
 			break;
@@ -457,20 +453,6 @@ static int ath10k_htt_rx_amsdu_pop(struct ath10k_htt *=
htt,
 		msdu_chaining =3D -1;
=20
 	/*
-	 * Apparently FW sometimes reports weird chained MSDU sequences with
-	 * more than one rx descriptor. This seems like a bug but needs more
-	 * analyzing. For the time being fix it by dropping such sequences to
-	 * avoid blowing up the host system.
-	 */
-	if (corrupted) {
-		ath10k_warn("failed to pop chained msdus, dropping\n");
-		ath10k_htt_rx_free_msdu_chain(*head_msdu);
-		*head_msdu =3D NULL;
-		*tail_msdu =3D NULL;
-		msdu_chaining =3D -EINVAL;
-	}
-
-	/*
 	 * Don't refill the ring yet.
 	 *
 	 * First, the elements popped here are still in use - it is not
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/usb.c b/drivers/net/wi=
reless/brcm80211/brcmfmac/usb.c
index 6db51a666f61..d06fcb05adf2 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/usb.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/usb.c
@@ -1184,8 +1184,6 @@ static int brcmf_usb_probe_cb(struct brcmf_usbdev_inf=
o *devinfo)
 	bus->bus_priv.usb =3D bus_pub;
 	dev_set_drvdata(dev, bus);
 	bus->ops =3D &brcmf_usb_bus_ops;
-	bus->chip =3D bus_pub->devid;
-	bus->chiprev =3D bus_pub->chiprev;
 	bus->proto_type =3D BRCMF_PROTO_BCDC;
 	bus->always_use_fws_queue =3D true;
=20
@@ -1194,6 +1192,9 @@ static int brcmf_usb_probe_cb(struct brcmf_usbdev_inf=
o *devinfo)
 		if (ret)
 			goto fail;
 	}
+	bus->chip =3D bus_pub->devid;
+	bus->chiprev =3D bus_pub->chiprev;
+
 	/* request firmware here */
 	brcmf_fw_get_firmwares(dev, 0, brcmf_usb_get_fwname(devinfo), NULL,
 			       brcmf_usb_probe_phase2);
diff --git a/drivers/net/wireless/iwlwifi/iwl-fw.h b/drivers/net/wireless/i=
wlwifi/iwl-fw.h
index 0aa7c0085c9f..b1a33322b9ba 100644
--- a/drivers/net/wireless/iwlwifi/iwl-fw.h
+++ b/drivers/net/wireless/iwlwifi/iwl-fw.h
@@ -88,6 +88,7 @@
  *	P2P client interfaces simultaneously if they are in different bindings.
  * @IWL_UCODE_TLV_FLAGS_P2P_BSS_PS_SCM: support power save on BSS station =
and
  *	P2P client interfaces simultaneously if they are in same bindings.
+ * @IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT: General support for uAPSD
  * @IWL_UCODE_TLV_FLAGS_P2P_PS_UAPSD: P2P client supports uAPSD power save
  * @IWL_UCODE_TLV_FLAGS_BCAST_FILTERING: uCode supports broadcast filterin=
g.
  * @IWL_UCODE_TLV_FLAGS_GO_UAPSD: AP/GO interfaces support uAPSD clients
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 7215f5980186..1cef708cb74d 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -303,6 +303,13 @@ int iwl_mvm_mac_setup_register(struct iwl_mvm *mvm)
 		hw->uapsd_max_sp_len =3D IWL_UAPSD_MAX_SP;
 	}
=20
+	if (mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_UAPSD_SUPPORT &&
+	    !iwlwifi_mod_params.uapsd_disable) {
+		hw->flags |=3D IEEE80211_HW_SUPPORTS_UAPSD;
+		hw->uapsd_queues =3D IWL_UAPSD_AC_INFO;
+		hw->uapsd_max_sp_len =3D IWL_UAPSD_MAX_SP;
+	}
+
 	hw->sta_data_size =3D sizeof(struct iwl_mvm_sta);
 	hw->vif_data_size =3D sizeof(struct iwl_mvm_vif);
 	hw->chanctx_data_size =3D sizeof(u16);
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index 4b6c7d4bd199..eac2b424f6a0 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -588,9 +588,7 @@ static void iwl_build_scan_cmd(struct iwl_mvm *mvm,
 			       struct iwl_scan_offload_cmd *scan,
 			       struct iwl_mvm_scan_params *params)
 {
-	scan->channel_count =3D
-		mvm->nvm_data->bands[IEEE80211_BAND_2GHZ].n_channels +
-		mvm->nvm_data->bands[IEEE80211_BAND_5GHZ].n_channels;
+	scan->channel_count =3D req->n_channels;
 	scan->quiet_time =3D cpu_to_le16(IWL_ACTIVE_QUIET_TIME);
 	scan->quiet_plcp_th =3D cpu_to_le16(IWL_PLCP_QUIET_THRESH);
 	scan->good_CRC_th =3D IWL_GOOD_CRC_TH_DEFAULT;
@@ -669,61 +667,37 @@ static void iwl_build_channel_cfg(struct iwl_mvm *mvm,
 				  struct cfg80211_sched_scan_request *req,
 				  struct iwl_scan_channel_cfg *channels,
 				  enum ieee80211_band band,
-				  int *head, int *tail,
+				  int *head,
 				  u32 ssid_bitmap,
 				  struct iwl_mvm_scan_params *params)
 {
-	struct ieee80211_supported_band *s_band;
-	int n_channels =3D req->n_channels;
-	int i, j, index =3D 0;
-	bool partial;
+	int i, index =3D 0;
=20
-	/*
-	 * We have to configure all supported channels, even if we don't want to
-	 * scan on them, but we have to send channels in the order that we want
-	 * to scan. So add requested channels to head of the list and others to
-	 * the end.
-	*/
-	s_band =3D &mvm->nvm_data->bands[band];
-
-	for (i =3D 0; i < s_band->n_channels && *head <=3D *tail; i++) {
-		partial =3D false;
-		for (j =3D 0; j < n_channels; j++)
-			if (s_band->channels[i].center_freq =3D=3D
-						req->channels[j]->center_freq) {
-				index =3D *head;
-				(*head)++;
-				/*
-				 * Channels that came with the request will be
-				 * in partial scan .
-				 */
-				partial =3D true;
-				break;
-			}
-		if (!partial) {
-			index =3D *tail;
-			(*tail)--;
-		}
-		channels->channel_number[index] =3D
-			cpu_to_le16(ieee80211_frequency_to_channel(
-					s_band->channels[i].center_freq));
+	for (i =3D 0; i < req->n_channels; i++) {
+		struct ieee80211_channel *chan =3D req->channels[i];
+
+		if (chan->band !=3D band)
+			continue;
+
+		index =3D *head;
+		(*head)++;
+
+		channels->channel_number[index] =3D cpu_to_le16(chan->hw_value);
 		channels->dwell_time[index][0] =3D params->dwell[band].active;
 		channels->dwell_time[index][1] =3D params->dwell[band].passive;
=20
 		channels->iter_count[index] =3D cpu_to_le16(1);
 		channels->iter_interval[index] =3D 0;
=20
-		if (!(s_band->channels[i].flags & IEEE80211_CHAN_NO_IR))
+		if (!(chan->flags & IEEE80211_CHAN_NO_IR))
 			channels->type[index] |=3D
 				cpu_to_le32(IWL_SCAN_OFFLOAD_CHANNEL_ACTIVE);
=20
 		channels->type[index] |=3D
-				cpu_to_le32(IWL_SCAN_OFFLOAD_CHANNEL_FULL);
-		if (partial)
-			channels->type[index] |=3D
-				cpu_to_le32(IWL_SCAN_OFFLOAD_CHANNEL_PARTIAL);
+				cpu_to_le32(IWL_SCAN_OFFLOAD_CHANNEL_FULL |
+					    IWL_SCAN_OFFLOAD_CHANNEL_PARTIAL);
=20
-		if (s_band->channels[i].flags & IEEE80211_CHAN_NO_HT40)
+		if (chan->flags & IEEE80211_CHAN_NO_HT40)
 			channels->type[index] |=3D
 				cpu_to_le32(IWL_SCAN_OFFLOAD_CHANNEL_NARROW);
=20
@@ -740,7 +714,6 @@ int iwl_mvm_config_sched_scan(struct iwl_mvm *mvm,
 	int band_2ghz =3D mvm->nvm_data->bands[IEEE80211_BAND_2GHZ].n_channels;
 	int band_5ghz =3D mvm->nvm_data->bands[IEEE80211_BAND_5GHZ].n_channels;
 	int head =3D 0;
-	int tail =3D band_2ghz + band_5ghz - 1;
 	u32 ssid_bitmap;
 	int cmd_len;
 	int ret;
@@ -772,7 +745,7 @@ int iwl_mvm_config_sched_scan(struct iwl_mvm *mvm,
 					      &scan_cfg->scan_cmd.tx_cmd[0],
 					      scan_cfg->data);
 		iwl_build_channel_cfg(mvm, req, &scan_cfg->channel_cfg,
-				      IEEE80211_BAND_2GHZ, &head, &tail,
+				      IEEE80211_BAND_2GHZ, &head,
 				      ssid_bitmap, &params);
 	}
 	if (band_5ghz) {
@@ -782,7 +755,7 @@ int iwl_mvm_config_sched_scan(struct iwl_mvm *mvm,
 					      scan_cfg->data +
 						SCAN_OFFLOAD_PROBE_REQ_SIZE);
 		iwl_build_channel_cfg(mvm, req, &scan_cfg->channel_cfg,
-				      IEEE80211_BAND_5GHZ, &head, &tail,
+				      IEEE80211_BAND_5GHZ, &head,
 				      ssid_bitmap, &params);
 	}
=20
diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless=
/iwlwifi/pcie/drv.c
index 7091a18d5a72..98950e45c7b0 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -367,6 +367,7 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x095A, 0x5012, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5412, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5410, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095A, 0x5510, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5400, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x1010, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x5000, iwl7265_2n_cfg)},
@@ -380,7 +381,7 @@ static DEFINE_PCI_DEVICE_TABLE(iwl_hw_card_ids) =3D {
 	{IWL_PCI_DEVICE(0x095A, 0x9110, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9112, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9210, iwl7265_2ac_cfg)},
-	{IWL_PCI_DEVICE(0x095A, 0x9200, iwl7265_2ac_cfg)},
+	{IWL_PCI_DEVICE(0x095B, 0x9200, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9510, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9310, iwl7265_2ac_cfg)},
 	{IWL_PCI_DEVICE(0x095A, 0x9410, iwl7265_2ac_cfg)},
diff --git a/drivers/net/wireless/mwifiex/main.c b/drivers/net/wireless/mwi=
fiex/main.c
index cbabc12fbda3..e91cd0fa5ca8 100644
--- a/drivers/net/wireless/mwifiex/main.c
+++ b/drivers/net/wireless/mwifiex/main.c
@@ -645,6 +645,7 @@ mwifiex_hard_start_xmit(struct sk_buff *skb, struct net=
_device *dev)
 	}
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
 	tx_info->pkt_len =3D skb->len;
diff --git a/net/bluetooth/hci_conn.c b/net/bluetooth/hci_conn.c
index ca01d1861854..a7a27bc2c0b1 100644
--- a/net/bluetooth/hci_conn.c
+++ b/net/bluetooth/hci_conn.c
@@ -289,10 +289,20 @@ static void hci_conn_timeout(struct work_struct *work)
 {
 	struct hci_conn *conn =3D container_of(work, struct hci_conn,
 					     disc_work.work);
+	int refcnt =3D atomic_read(&conn->refcnt);
=20
 	BT_DBG("hcon %p state %s", conn, state_to_string(conn->state));
=20
-	if (atomic_read(&conn->refcnt))
+	WARN_ON(refcnt < 0);
+
+	/* FIXME: It was observed that in pairing failed scenario, refcnt
+	 * drops below 0. Probably this is because l2cap_conn_del calls
+	 * l2cap_chan_del for each channel, and inside l2cap_chan_del conn is
+	 * dropped. After that loop hci_chan_del is called which also drops
+	 * conn. For now make sure that ACL is alive if refcnt is higher then 0,
+	 * otherwise drop it.
+	 */
+	if (refcnt > 0)
 		return;
=20
 	switch (conn->state) {
diff --git a/net/bluetooth/smp.c b/net/bluetooth/smp.c
index f2829a7932e2..e33a982161c1 100644
--- a/net/bluetooth/smp.c
+++ b/net/bluetooth/smp.c
@@ -385,6 +385,16 @@ static const u8 gen_method[5][5] =3D {
 	{ CFM_PASSKEY, CFM_PASSKEY, REQ_PASSKEY, JUST_WORKS, OVERLAP     },
 };
=20
+static u8 get_auth_method(struct smp_chan *smp, u8 local_io, u8 remote_io)
+{
+	/* If either side has unknown io_caps, use JUST WORKS */
+	if (local_io > SMP_IO_KEYBOARD_DISPLAY ||
+	    remote_io > SMP_IO_KEYBOARD_DISPLAY)
+		return JUST_WORKS;
+
+	return gen_method[remote_io][local_io];
+}
+
 static int tk_request(struct l2cap_conn *conn, u8 remote_oob, u8 auth,
 						u8 local_io, u8 remote_io)
 {
@@ -401,14 +411,11 @@ static int tk_request(struct l2cap_conn *conn, u8 rem=
ote_oob, u8 auth,
 	BT_DBG("tk_request: auth:%d lcl:%d rem:%d", auth, local_io, remote_io);
=20
 	/* If neither side wants MITM, use JUST WORKS */
-	/* If either side has unknown io_caps, use JUST WORKS */
 	/* Otherwise, look up method from the table */
-	if (!(auth & SMP_AUTH_MITM) ||
-	    local_io > SMP_IO_KEYBOARD_DISPLAY ||
-	    remote_io > SMP_IO_KEYBOARD_DISPLAY)
+	if (!(auth & SMP_AUTH_MITM))
 		method =3D JUST_WORKS;
 	else
-		method =3D gen_method[remote_io][local_io];
+		method =3D get_auth_method(smp, local_io, remote_io);
=20
 	/* If not bonding, don't ask user to confirm a Zero TK */
 	if (!(auth & SMP_AUTH_BONDING) && method =3D=3D JUST_CFM)
@@ -669,7 +676,7 @@ static u8 smp_cmd_pairing_req(struct l2cap_conn *conn, =
struct sk_buff *skb)
 {
 	struct smp_cmd_pairing rsp, *req =3D (void *) skb->data;
 	struct smp_chan *smp;
-	u8 key_size, auth;
+	u8 key_size, auth, sec_level;
 	int ret;
=20
 	BT_DBG("conn %p", conn);
@@ -695,7 +702,19 @@ static u8 smp_cmd_pairing_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
 	/* We didn't start the pairing, so match remote */
 	auth =3D req->auth_req;
=20
-	conn->hcon->pending_sec_level =3D authreq_to_seclevel(auth);
+	sec_level =3D authreq_to_seclevel(auth);
+	if (sec_level > conn->hcon->pending_sec_level)
+		conn->hcon->pending_sec_level =3D sec_level;
+
+	/* If we need MITM check that it can be acheived */
+	if (conn->hcon->pending_sec_level >=3D BT_SECURITY_HIGH) {
+		u8 method;
+
+		method =3D get_auth_method(smp, conn->hcon->io_capability,
+					 req->io_capability);
+		if (method =3D=3D JUST_WORKS || method =3D=3D JUST_CFM)
+			return SMP_AUTH_REQUIREMENTS;
+	}
=20
 	build_pairing_cmd(conn, req, &rsp, auth);
=20
@@ -743,6 +762,16 @@ static u8 smp_cmd_pairing_rsp(struct l2cap_conn *conn,=
 struct sk_buff *skb)
 	if (check_enc_key_size(conn, key_size))
 		return SMP_ENC_KEY_SIZE;
=20
+	/* If we need MITM check that it can be acheived */
+	if (conn->hcon->pending_sec_level >=3D BT_SECURITY_HIGH) {
+		u8 method;
+
+		method =3D get_auth_method(smp, req->io_capability,
+					 rsp->io_capability);
+		if (method =3D=3D JUST_WORKS || method =3D=3D JUST_CFM)
+			return SMP_AUTH_REQUIREMENTS;
+	}
+
 	get_random_bytes(smp->prnd, sizeof(smp->prnd));
=20
 	smp->prsp[0] =3D SMP_CMD_PAIRING_RSP;
@@ -838,6 +867,7 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
 	struct smp_cmd_pairing cp;
 	struct hci_conn *hcon =3D conn->hcon;
 	struct smp_chan *smp;
+	u8 sec_level;
=20
 	BT_DBG("conn %p", conn);
=20
@@ -847,7 +877,9 @@ static u8 smp_cmd_security_req(struct l2cap_conn *conn,=
 struct sk_buff *skb)
 	if (!(conn->hcon->link_mode & HCI_LM_MASTER))
 		return SMP_CMD_NOTSUPP;
=20
-	hcon->pending_sec_level =3D authreq_to_seclevel(rp->auth_req);
+	sec_level =3D authreq_to_seclevel(rp->auth_req);
+	if (sec_level > hcon->pending_sec_level)
+		hcon->pending_sec_level =3D sec_level;
=20
 	if (smp_ltk_encrypt(conn, hcon->pending_sec_level))
 		return 0;
@@ -901,9 +933,12 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec_=
level)
 	if (smp_sufficient_security(hcon, sec_level))
 		return 1;
=20
+	if (sec_level > hcon->pending_sec_level)
+		hcon->pending_sec_level =3D sec_level;
+
 	if (hcon->link_mode & HCI_LM_MASTER)
-		if (smp_ltk_encrypt(conn, sec_level))
-			goto done;
+		if (smp_ltk_encrypt(conn, hcon->pending_sec_level))
+			return 0;
=20
 	if (test_and_set_bit(HCI_CONN_LE_SMP_PEND, &hcon->flags))
 		return 0;
@@ -918,7 +953,7 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec_l=
evel)
 	 * requires it.
 	 */
 	if (hcon->io_capability !=3D HCI_IO_NO_INPUT_OUTPUT ||
-	    sec_level > BT_SECURITY_MEDIUM)
+	    hcon->pending_sec_level > BT_SECURITY_MEDIUM)
 		authreq |=3D SMP_AUTH_MITM;
=20
 	if (hcon->link_mode & HCI_LM_MASTER) {
@@ -937,9 +972,6 @@ int smp_conn_security(struct hci_conn *hcon, __u8 sec_l=
evel)
=20
 	set_bit(SMP_FLAG_INITIATOR, &smp->flags);
=20
-done:
-	hcon->pending_sec_level =3D sec_level;
-
 	return 0;
 }
=20
diff --git a/net/mac80211/util.c b/net/mac80211/util.c
index 6886601afe1c..a6cda52ed920 100644
--- a/net/mac80211/util.c
+++ b/net/mac80211/util.c
@@ -1096,11 +1096,12 @@ void ieee80211_send_auth(struct ieee80211_sub_if_da=
ta *sdata,
 	int err;
=20
 	/* 24 + 6 =3D header + auth_algo + auth_transaction + status_code */
-	skb =3D dev_alloc_skb(local->hw.extra_tx_headroom + 24 + 6 + extra_len);
+	skb =3D dev_alloc_skb(local->hw.extra_tx_headroom + IEEE80211_WEP_IV_LEN +
+			    24 + 6 + extra_len + IEEE80211_WEP_ICV_LEN);
 	if (!skb)
 		return;
=20
-	skb_reserve(skb, local->hw.extra_tx_headroom);
+	skb_reserve(skb, local->hw.extra_tx_headroom + IEEE80211_WEP_IV_LEN);
=20
 	mgmt =3D (struct ieee80211_mgmt *) skb_put(skb, 24 + 6);
 	memset(mgmt, 0, 24 + 6);
diff --git a/net/wireless/core.h b/net/wireless/core.h
index e9afbf10e756..7e3a3cef7df9 100644
--- a/net/wireless/core.h
+++ b/net/wireless/core.h
@@ -424,7 +424,7 @@ static inline unsigned int elapsed_jiffies_msecs(unsign=
ed long start)
 	if (end >=3D start)
 		return jiffies_to_msecs(end - start);
=20
-	return jiffies_to_msecs(end + (MAX_JIFFY_OFFSET - start) + 1);
+	return jiffies_to_msecs(end + (ULONG_MAX - start) + 1);
 }
=20
 void
diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index ba4f1723c83a..6668daf69326 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1497,18 +1497,17 @@ static int nl80211_send_wiphy(struct cfg80211_regis=
tered_device *rdev,
 		}
 		CMD(start_p2p_device, START_P2P_DEVICE);
 		CMD(set_mcast_rate, SET_MCAST_RATE);
+#ifdef CONFIG_NL80211_TESTMODE
+		CMD(testmode_cmd, TESTMODE);
+#endif
 		if (state->split) {
 			CMD(crit_proto_start, CRIT_PROTOCOL_START);
 			CMD(crit_proto_stop, CRIT_PROTOCOL_STOP);
 			if (rdev->wiphy.flags & WIPHY_FLAG_HAS_CHANNEL_SWITCH)
 				CMD(channel_switch, CHANNEL_SWITCH);
+			CMD(set_qos_map, SET_QOS_MAP);
 		}
-		CMD(set_qos_map, SET_QOS_MAP);
-
-#ifdef CONFIG_NL80211_TESTMODE
-		CMD(testmode_cmd, TESTMODE);
-#endif
-
+		/* add into the if now */
 #undef CMD
=20
 		if (rdev->ops->connect || rdev->ops->auth) {
diff --git a/net/wireless/reg.c b/net/wireless/reg.c
index 558b0e3a02d8..1afdf45db38f 100644
--- a/net/wireless/reg.c
+++ b/net/wireless/reg.c
@@ -935,7 +935,7 @@ freq_reg_info_regd(struct wiphy *wiphy, u32 center_freq,
 		if (!band_rule_found)
 			band_rule_found =3D freq_in_rule_band(fr, center_freq);
=20
-		bw_fits =3D reg_does_bw_fit(fr, center_freq, MHZ_TO_KHZ(5));
+		bw_fits =3D reg_does_bw_fit(fr, center_freq, MHZ_TO_KHZ(20));
=20
 		if (band_rule_found && bw_fits)
 			return rr;
@@ -1019,10 +1019,10 @@ static void chan_reg_rule_print_dbg(const struct ie=
ee80211_regdomain *regd,
 }
 #endif
=20
-/* Find an ieee80211_reg_rule such that a 5MHz channel with frequency
- * chan->center_freq fits there.
- * If there is no such reg_rule, disable the channel, otherwise set the
- * flags corresponding to the bandwidths allowed in the particular reg_rule
+/*
+ * Note that right now we assume the desired channel bandwidth
+ * is always 20 MHz for each individual channel (HT40 uses 20 MHz
+ * per channel, the primary and the extension channel).
  */
 static void handle_channel(struct wiphy *wiphy,
 			   enum nl80211_reg_initiator initiator,
@@ -1083,12 +1083,8 @@ static void handle_channel(struct wiphy *wiphy,
 	if (reg_rule->flags & NL80211_RRF_AUTO_BW)
 		max_bandwidth_khz =3D reg_get_max_bandwidth(regd, reg_rule);
=20
-	if (max_bandwidth_khz < MHZ_TO_KHZ(10))
-		bw_flags =3D IEEE80211_CHAN_NO_10MHZ;
-	if (max_bandwidth_khz < MHZ_TO_KHZ(20))
-		bw_flags |=3D IEEE80211_CHAN_NO_20MHZ;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(40))
-		bw_flags |=3D IEEE80211_CHAN_NO_HT40;
+		bw_flags =3D IEEE80211_CHAN_NO_HT40;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(80))
 		bw_flags |=3D IEEE80211_CHAN_NO_80MHZ;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(160))
@@ -1522,12 +1518,8 @@ static void handle_channel_custom(struct wiphy *wiph=
y,
 	if (reg_rule->flags & NL80211_RRF_AUTO_BW)
 		max_bandwidth_khz =3D reg_get_max_bandwidth(regd, reg_rule);
=20
-	if (max_bandwidth_khz < MHZ_TO_KHZ(10))
-		bw_flags =3D IEEE80211_CHAN_NO_10MHZ;
-	if (max_bandwidth_khz < MHZ_TO_KHZ(20))
-		bw_flags |=3D IEEE80211_CHAN_NO_20MHZ;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(40))
-		bw_flags |=3D IEEE80211_CHAN_NO_HT40;
+		bw_flags =3D IEEE80211_CHAN_NO_HT40;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(80))
 		bw_flags |=3D IEEE80211_CHAN_NO_80MHZ;
 	if (max_bandwidth_khz < MHZ_TO_KHZ(160))
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--8t9RHnE3ZwKMSgU+
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTrbs5AAoJEJctW/TcYTgGwnAP/RRuFJGK//Ax20vT6iS7Bznx
EOVuI2z5/uIJwJaEHHFoLc1XoANDVBgTt+AbAPIeekVdgh2mFG5sw0DG2XRk9NbI
KhvdESco4GhUB/jqh/NkOw3W5+Ik0BV08zEA1wpBRyFbY6AnA7/dfHQmEpPdUz1L
XEG3mDF5cmeW5KQOUoFzBdYAd+fSLhRo/cF0t/rG3C0FCiEu2xfDGb5pwiZBpOqb
aeEOJYoEhkhUFcgU0clsURFp8Nj4CL4iFq1uxzUIBdtsQzVBI56JEVKyJ4mHiX5W
LxCUfzAq5a13J4/IIVDZrFFUV39Xbr0Y4xUe6Vf8+Z3O0+548Lfp0KAfwe9vAsbp
VRk/EG92RUR81ZRW4+sUu36HkxTS3eUTVJl64mW/YBzMmoeUrO4iYzyz9FGqZTyv
M5wMy5AN2Y486QoPwInuUX6SWvaa+TohUsEp5phVXZrZvBPkqljJ+x/W4PBBYmsN
Ca1PPsiiSEKhOM42pCWLdTs+bt5/O9uPdVQsK6giojIu5aaHGw7AG33kOhRq4GSa
Z1mJA0OUc9BgfdUasgG+4vLhT+hWIbsB2g4yaMSbmRYFpZcXWw/bQ8XNCkNrm+uk
3w9GMxq8XMWFoZRy6rhf0dODz8pzMdJGf1Ow6utrkSvaBzqwdi5QQFObkqoXJHhi
0B8GLaqm+dRXBQiVhR8q
=YL4c
-----END PGP SIGNATURE-----

--8t9RHnE3ZwKMSgU+--
