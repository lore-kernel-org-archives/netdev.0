From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 1/2] wireless: Remove casts of void *
Date: Mon, 13 Jun 2011 21:02:38 -0700
Message-ID: <337c22b774ff7f007b90b266b25c9a33ff555c48.1308024069.git.joe@perches.com>
References: <cover.1308024069.git.joe@perches.com>
Cc: "Luis R. Rodriguez" <lrodriguez@atheros.com>,
	Jouni Malinen <jmalinen@atheros.com>,
	Vasanthakumar Thiagarajan <vasanth@atheros.com>,
	Senthil Balasubramanian <senthilkumar@atheros.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1308024069.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Unnecessary casts of void * clutter the code.

These are the remainder casts after several specific
patches to remove netdev_priv and dev_priv.

Done via coccinelle script:

$ cat cast_void_pointer.cocci
@@
type T;
T *pt;
void *pv;
@@

- pt = (T *)pv;
+ pt = pv;

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/ath/ath9k/ar9003_mac.c    |    2 +-
 drivers/net/wireless/ath/ath9k/htc_hst.c       |    6 ++----
 drivers/net/wireless/ath/ath9k/init.c          |    2 +-
 drivers/net/wireless/ath/ath9k/wmi.c           |    2 +-
 drivers/net/wireless/ath/carl9170/usb.c        |    2 +-
 drivers/net/wireless/hostap/hostap_cs.c        |    4 ++--
 drivers/net/wireless/hostap/hostap_pci.c       |    4 ++--
 drivers/net/wireless/hostap/hostap_plx.c       |    4 ++--
 drivers/net/wireless/ipw2x00/ipw2100.c         |    6 ++----
 drivers/net/wireless/iwlegacy/iwl-4965-rs.c    |    2 +-
 drivers/net/wireless/iwlegacy/iwl-4965-ucode.c |    8 ++++----
 drivers/net/wireless/iwlegacy/iwl3945-base.c   |    8 ++++----
 drivers/net/wireless/iwlegacy/iwl4965-base.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c      |    2 +-
 drivers/net/wireless/mwifiex/11n.c             |    5 ++---
 drivers/net/wireless/mwifiex/cmdevt.c          |    3 +--
 drivers/net/wireless/mwifiex/join.c            |    2 +-
 drivers/net/wireless/mwifiex/scan.c            |    2 +-
 drivers/net/wireless/mwifiex/sta_cmd.c         |    4 ++--
 drivers/net/wireless/mwifiex/sta_cmdresp.c     |   12 ++++++------
 drivers/net/wireless/mwifiex/txrx.c            |    2 +-
 drivers/net/wireless/p54/eeprom.c              |    4 ++--
 22 files changed, 41 insertions(+), 47 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_mac.c b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
index 04e6be0..2321e5b 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_mac.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_mac.c
@@ -654,7 +654,7 @@ void ath9k_hw_setup_statusring(struct ath_hw *ah, void *ts_start,
 	ah->ts_paddr_start = ts_paddr_start;
 	ah->ts_paddr_end = ts_paddr_start + (size * sizeof(struct ar9003_txs));
 	ah->ts_size = size;
-	ah->ts_ring = (struct ar9003_txs *) ts_start;
+	ah->ts_ring = ts_start;
 
 	ath9k_hw_reset_txstatus_ring(ah);
 }
diff --git a/drivers/net/wireless/ath/ath9k/htc_hst.c b/drivers/net/wireless/ath/ath9k/htc_hst.c
index 1b90ed8..34e42c8 100644
--- a/drivers/net/wireless/ath/ath9k/htc_hst.c
+++ b/drivers/net/wireless/ath/ath9k/htc_hst.c
@@ -107,8 +107,7 @@ static void htc_process_conn_rsp(struct htc_target *target,
 	u16 max_msglen;
 	enum htc_endpoint_id epid, tepid;
 
-	svc_rspmsg = (struct htc_conn_svc_rspmsg *)
-		((void *) htc_hdr + sizeof(struct htc_frame_hdr));
+	svc_rspmsg = (void *)htc_hdr + sizeof(struct htc_frame_hdr);
 
 	if (svc_rspmsg->status == HTC_SERVICE_SUCCESS) {
 		epid = svc_rspmsg->endpoint_id;
@@ -393,8 +392,7 @@ void ath9k_htc_rx_msg(struct htc_target *htc_handle,
 		}
 
 		/* Get the message ID */
-		msg_id = (__be16 *) ((void *) htc_hdr +
-				     sizeof(struct htc_frame_hdr));
+		msg_id = (void *)htc_hdr + sizeof(struct htc_frame_hdr);
 
 		/* Now process HTC messages */
 		switch (be16_to_cpu(*msg_id)) {
diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index d4b166c..d4b44a8 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -352,7 +352,7 @@ int ath_descdma_setup(struct ath_softc *sc, struct ath_descdma *dd,
 		error = -ENOMEM;
 		goto fail;
 	}
-	ds = (u8 *) dd->dd_desc;
+	ds = dd->dd_desc;
 	ath_dbg(common, ATH_DBG_CONFIG, "%s DMA map: %p (%u) -> %llx (%u)\n",
 		name, ds, (u32) dd->dd_desc_len,
 		ito64(dd->dd_desc_paddr), /*XXX*/(u32) dd->dd_desc_len);
diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index 35422fc..0934b38 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -156,7 +156,7 @@ void ath9k_wmi_event_tasklet(unsigned long data)
 
 		switch (cmd_id) {
 		case WMI_SWBA_EVENTID:
-			swba = (struct wmi_event_swba *) wmi_event;
+			swba = wmi_event;
 			ath9k_htc_swba(priv, swba);
 			break;
 		case WMI_FATAL_EVENTID:
diff --git a/drivers/net/wireless/ath/carl9170/usb.c b/drivers/net/wireless/ath/carl9170/usb.c
index 2fb53d0..7f1d13a 100644
--- a/drivers/net/wireless/ath/carl9170/usb.c
+++ b/drivers/net/wireless/ath/carl9170/usb.c
@@ -649,7 +649,7 @@ int carl9170_exec_cmd(struct ar9170 *ar, const enum carl9170_cmd_oids cmd,
 		memcpy(ar->cmd.data, payload, plen);
 
 	spin_lock_bh(&ar->cmd_lock);
-	ar->readbuf = (u8 *)out;
+	ar->readbuf = out;
 	ar->readlen = outlen;
 	spin_unlock_bh(&ar->cmd_lock);
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index c052a0d..4273b96 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -160,7 +160,7 @@ static int hfa384x_from_bap(struct net_device *dev, u16 bap, void *buf,
 	u16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (u16 *) buf;
+	pos = buf;
 
 	if (len / 2)
 		HFA384X_INSW(d_off, buf, len / 2);
@@ -179,7 +179,7 @@ static int hfa384x_to_bap(struct net_device *dev, u16 bap, void *buf, int len)
 	u16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (u16 *) buf;
+	pos = buf;
 
 	if (len / 2)
 		HFA384X_OUTSW(d_off, buf, len / 2);
diff --git a/drivers/net/wireless/hostap/hostap_pci.c b/drivers/net/wireless/hostap/hostap_pci.c
index 972a9c3..ec723e5 100644
--- a/drivers/net/wireless/hostap/hostap_pci.c
+++ b/drivers/net/wireless/hostap/hostap_pci.c
@@ -187,7 +187,7 @@ static int hfa384x_from_bap(struct net_device *dev, u16 bap, void *buf,
 	__le16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (__le16 *) buf;
+	pos = buf;
 
 	for ( ; len > 1; len -= 2)
 		*pos++ = HFA384X_INW_DATA(d_off);
@@ -205,7 +205,7 @@ static int hfa384x_to_bap(struct net_device *dev, u16 bap, void *buf, int len)
 	__le16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (__le16 *) buf;
+	pos = buf;
 
 	for ( ; len > 1; len -= 2)
 		HFA384X_OUTW_DATA(*pos++, d_off);
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index 33e7903..8f6bdd0 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -228,7 +228,7 @@ static int hfa384x_from_bap(struct net_device *dev, u16 bap, void *buf,
 	u16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (u16 *) buf;
+	pos = buf;
 
 	if (len / 2)
 		HFA384X_INSW(d_off, buf, len / 2);
@@ -247,7 +247,7 @@ static int hfa384x_to_bap(struct net_device *dev, u16 bap, void *buf, int len)
 	u16 *pos;
 
 	d_off = (bap == 1) ? HFA384X_DATA1_OFF : HFA384X_DATA0_OFF;
-	pos = (u16 *) buf;
+	pos = buf;
 
 	if (len / 2)
 		HFA384X_OUTSW(d_off, buf, len / 2);
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 4430775..4bb90d1 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -3482,8 +3482,7 @@ static int ipw2100_msg_allocate(struct ipw2100_priv *priv)
 		memset(v, 0, sizeof(struct ipw2100_cmd_header));
 
 		priv->msg_buffers[i].type = COMMAND;
-		priv->msg_buffers[i].info.c_struct.cmd =
-		    (struct ipw2100_cmd_header *)v;
+		priv->msg_buffers[i].info.c_struct.cmd = v;
 		priv->msg_buffers[i].info.c_struct.cmd_phys = p;
 	}
 
@@ -4510,8 +4509,7 @@ static int ipw2100_tx_allocate(struct ipw2100_priv *priv)
 		}
 
 		priv->tx_buffers[i].type = DATA;
-		priv->tx_buffers[i].info.d_struct.data =
-		    (struct ipw2100_data_header *)v;
+		priv->tx_buffers[i].info.d_struct.data = v;
 		priv->tx_buffers[i].info.d_struct.data_phys = p;
 		priv->tx_buffers[i].info.d_struct.txb = NULL;
 	}
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
index 9b65153..d850fdc 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-rs.c
@@ -2323,7 +2323,7 @@ static void *iwl4965_rs_alloc_sta(void *priv_rate, struct ieee80211_sta *sta,
 				(struct iwl_station_priv *) sta->drv_priv;
 	struct iwl_priv *priv;
 
-	priv = (struct iwl_priv *)priv_rate;
+	priv = priv_rate;
 	IWL_DEBUG_RATE(priv, "create station rate scale window\n");
 
 	lq_sta = &sta_priv->lq_sta;
diff --git a/drivers/net/wireless/iwlegacy/iwl-4965-ucode.c b/drivers/net/wireless/iwlegacy/iwl-4965-ucode.c
index 001d148..35b6ca2 100644
--- a/drivers/net/wireless/iwlegacy/iwl-4965-ucode.c
+++ b/drivers/net/wireless/iwlegacy/iwl-4965-ucode.c
@@ -127,7 +127,7 @@ int iwl4965_verify_ucode(struct iwl_priv *priv)
 	int ret;
 
 	/* Try bootstrap */
-	image = (__le32 *)priv->ucode_boot.v_addr;
+	image = priv->ucode_boot.v_addr;
 	len = priv->ucode_boot.len;
 	ret = iwl4965_verify_inst_sparse(priv, image, len);
 	if (!ret) {
@@ -136,7 +136,7 @@ int iwl4965_verify_ucode(struct iwl_priv *priv)
 	}
 
 	/* Try initialize */
-	image = (__le32 *)priv->ucode_init.v_addr;
+	image = priv->ucode_init.v_addr;
 	len = priv->ucode_init.len;
 	ret = iwl4965_verify_inst_sparse(priv, image, len);
 	if (!ret) {
@@ -145,7 +145,7 @@ int iwl4965_verify_ucode(struct iwl_priv *priv)
 	}
 
 	/* Try runtime/protocol */
-	image = (__le32 *)priv->ucode_code.v_addr;
+	image = priv->ucode_code.v_addr;
 	len = priv->ucode_code.len;
 	ret = iwl4965_verify_inst_sparse(priv, image, len);
 	if (!ret) {
@@ -158,7 +158,7 @@ int iwl4965_verify_ucode(struct iwl_priv *priv)
 	/* Since nothing seems to match, show first several data entries in
 	 * instruction SRAM, so maybe visual inspection will give a clue.
 	 * Selection of bootstrap image (vs. other images) is arbitrary. */
-	image = (__le32 *)priv->ucode_boot.v_addr;
+	image = priv->ucode_boot.v_addr;
 	len = priv->ucode_boot.len;
 	ret = iwl4965_verify_inst_full(priv, image, len);
 
diff --git a/drivers/net/wireless/iwlegacy/iwl3945-base.c b/drivers/net/wireless/iwlegacy/iwl3945-base.c
index 0ee6be6..13b41b2 100644
--- a/drivers/net/wireless/iwlegacy/iwl3945-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl3945-base.c
@@ -2029,7 +2029,7 @@ static int iwl3945_verify_ucode(struct iwl_priv *priv)
 	int rc = 0;
 
 	/* Try bootstrap */
-	image = (__le32 *)priv->ucode_boot.v_addr;
+	image = priv->ucode_boot.v_addr;
 	len = priv->ucode_boot.len;
 	rc = iwl3945_verify_inst_sparse(priv, image, len);
 	if (rc == 0) {
@@ -2038,7 +2038,7 @@ static int iwl3945_verify_ucode(struct iwl_priv *priv)
 	}
 
 	/* Try initialize */
-	image = (__le32 *)priv->ucode_init.v_addr;
+	image = priv->ucode_init.v_addr;
 	len = priv->ucode_init.len;
 	rc = iwl3945_verify_inst_sparse(priv, image, len);
 	if (rc == 0) {
@@ -2047,7 +2047,7 @@ static int iwl3945_verify_ucode(struct iwl_priv *priv)
 	}
 
 	/* Try runtime/protocol */
-	image = (__le32 *)priv->ucode_code.v_addr;
+	image = priv->ucode_code.v_addr;
 	len = priv->ucode_code.len;
 	rc = iwl3945_verify_inst_sparse(priv, image, len);
 	if (rc == 0) {
@@ -2060,7 +2060,7 @@ static int iwl3945_verify_ucode(struct iwl_priv *priv)
 	/* Since nothing seems to match, show first several data entries in
 	 * instruction SRAM, so maybe visual inspection will give a clue.
 	 * Selection of bootstrap image (vs. other images) is arbitrary. */
-	image = (__le32 *)priv->ucode_boot.v_addr;
+	image = priv->ucode_boot.v_addr;
 	len = priv->ucode_boot.len;
 	rc = iwl3945_verify_inst_full(priv, image, len);
 
diff --git a/drivers/net/wireless/iwlegacy/iwl4965-base.c b/drivers/net/wireless/iwlegacy/iwl4965-base.c
index af2ae22..3a6d5df 100644
--- a/drivers/net/wireless/iwlegacy/iwl4965-base.c
+++ b/drivers/net/wireless/iwlegacy/iwl4965-base.c
@@ -379,7 +379,7 @@ int iwl4965_hw_txq_attach_buf_to_tfd(struct iwl_priv *priv,
 	u32 num_tbs;
 
 	q = &txq->q;
-	tfd_tmp = (struct iwl_tfd *)txq->tfds;
+	tfd_tmp = txq->tfds;
 	tfd = &tfd_tmp[q->write_ptr];
 
 	if (reset)
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
index 85e0828..f546045 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-rs.c
@@ -2799,7 +2799,7 @@ static void *rs_alloc_sta(void *priv_rate, struct ieee80211_sta *sta,
 	struct iwl_station_priv *sta_priv = (struct iwl_station_priv *) sta->drv_priv;
 	struct iwl_priv *priv;
 
-	priv = (struct iwl_priv *)priv_rate;
+	priv = priv_rate;
 	IWL_DEBUG_RATE(priv, "create station rate scale window\n");
 
 	return &sta_priv->lq_sta;
diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
index 916183d..6378c04 100644
--- a/drivers/net/wireless/mwifiex/11n.c
+++ b/drivers/net/wireless/mwifiex/11n.c
@@ -191,7 +191,7 @@ int mwifiex_ret_11n_cfg(struct host_cmd_ds_command *resp, void *data_buf)
 	struct host_cmd_ds_11n_cfg *htcfg = &resp->params.htcfg;
 
 	if (data_buf) {
-		tx_cfg = (struct mwifiex_ds_11n_tx_cfg *) data_buf;
+		tx_cfg = data_buf;
 		tx_cfg->tx_htcap = le16_to_cpu(htcfg->ht_tx_cap);
 		tx_cfg->tx_htinfo = le16_to_cpu(htcfg->ht_tx_info);
 	}
@@ -279,8 +279,7 @@ int mwifiex_ret_amsdu_aggr_ctrl(struct host_cmd_ds_command *resp,
 		&resp->params.amsdu_aggr_ctrl;
 
 	if (data_buf) {
-		amsdu_aggr_ctrl =
-			(struct mwifiex_ds_11n_amsdu_aggr_ctrl *) data_buf;
+		amsdu_aggr_ctrl = data_buf;
 		amsdu_aggr_ctrl->enable = le16_to_cpu(amsdu_ctrl->enable);
 		amsdu_aggr_ctrl->curr_buf_size =
 			le16_to_cpu(amsdu_ctrl->curr_buf_size);
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/mwifiex/cmdevt.c
index cd89fed..c5be38d 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -712,8 +712,7 @@ int mwifiex_process_cmdresp(struct mwifiex_adapter *adapter)
 		dev_dbg(adapter->dev, "info: host cmd resp size = %d\n", size);
 		size = min_t(u16, size, MWIFIEX_SIZE_OF_CMD_BUFFER);
 		if (adapter->curr_cmd->data_buf) {
-			hostcmd = (struct mwifiex_ds_misc_cmd *)
-						adapter->curr_cmd->data_buf;
+			hostcmd = adapter->curr_cmd->data_buf;
 			hostcmd->len = size;
 			memcpy(hostcmd->cmd, (void *) resp, size);
 		}
diff --git a/drivers/net/wireless/mwifiex/join.c b/drivers/net/wireless/mwifiex/join.c
index 5eab3dc..91c7eca 100644
--- a/drivers/net/wireless/mwifiex/join.c
+++ b/drivers/net/wireless/mwifiex/join.c
@@ -380,7 +380,7 @@ int mwifiex_cmd_802_11_associate(struct mwifiex_private *priv,
 	u8 *pos;
 	int rsn_ie_len = 0;
 
-	bss_desc = (struct mwifiex_bssdescriptor *) data_buf;
+	bss_desc = data_buf;
 	pos = (u8 *) assoc;
 
 	mwifiex_cfg_tx_buf(priv, bss_desc);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 5c22860..a20dcb8 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -2362,7 +2362,7 @@ int mwifiex_cmd_802_11_scan(struct host_cmd_ds_command *cmd, void *data_buf)
 	struct host_cmd_ds_802_11_scan *scan_cmd = &cmd->params.scan;
 	struct mwifiex_scan_cmd_config *scan_cfg;
 
-	scan_cfg = (struct mwifiex_scan_cmd_config *) data_buf;
+	scan_cfg = data_buf;
 
 	/* Set fixed field variables in scan command */
 	scan_cmd->bss_mode = scan_cfg->bss_mode;
diff --git a/drivers/net/wireless/mwifiex/sta_cmd.c b/drivers/net/wireless/mwifiex/sta_cmd.c
index 8af3a78..5571a4d 100644
--- a/drivers/net/wireless/mwifiex/sta_cmd.c
+++ b/drivers/net/wireless/mwifiex/sta_cmd.c
@@ -283,7 +283,7 @@ static int mwifiex_cmd_tx_power_cfg(struct host_cmd_ds_command *cmd,
 		cpu_to_le16(S_DS_GEN + sizeof(struct host_cmd_ds_txpwr_cfg));
 	switch (cmd_action) {
 	case HostCmd_ACT_GEN_SET:
-		txp = (struct host_cmd_ds_txpwr_cfg *) data_buf;
+		txp = data_buf;
 		if (txp->mode) {
 			pg_tlv = (struct mwifiex_types_power_group
 				  *) ((unsigned long) data_buf +
@@ -824,7 +824,7 @@ static int mwifiex_cmd_reg_access(struct host_cmd_ds_command *cmd,
 {
 	struct mwifiex_ds_reg_rw *reg_rw;
 
-	reg_rw = (struct mwifiex_ds_reg_rw *) data_buf;
+	reg_rw = data_buf;
 	switch (le16_to_cpu(cmd->command)) {
 	case HostCmd_CMD_MAC_REG_ACCESS:
 	{
diff --git a/drivers/net/wireless/mwifiex/sta_cmdresp.c b/drivers/net/wireless/mwifiex/sta_cmdresp.c
index d08f764..f495627 100644
--- a/drivers/net/wireless/mwifiex/sta_cmdresp.c
+++ b/drivers/net/wireless/mwifiex/sta_cmdresp.c
@@ -140,7 +140,7 @@ static int mwifiex_ret_802_11_rssi_info(struct mwifiex_private *priv,
 
 	/* Need to indicate IOCTL complete */
 	if (data_buf) {
-		signal = (struct mwifiex_ds_get_signal *) data_buf;
+		signal = data_buf;
 		memset(signal, 0, sizeof(struct mwifiex_ds_get_signal));
 
 		signal->selector = ALL_RSSI_INFO_MASK;
@@ -235,7 +235,7 @@ static int mwifiex_ret_get_log(struct mwifiex_private *priv,
 	struct mwifiex_ds_get_stats *stats;
 
 	if (data_buf) {
-		stats = (struct mwifiex_ds_get_stats *) data_buf;
+		stats = data_buf;
 		stats->mcast_tx_frame = le32_to_cpu(get_log->mcast_tx_frame);
 		stats->failed = le32_to_cpu(get_log->failed);
 		stats->retry = le32_to_cpu(get_log->retry);
@@ -330,7 +330,7 @@ static int mwifiex_ret_tx_rate_cfg(struct mwifiex_private *priv,
 					  HostCmd_ACT_GEN_GET, 0, NULL);
 
 	if (data_buf) {
-		ds_rate = (struct mwifiex_rate_cfg *) data_buf;
+		ds_rate = data_buf;
 		if (le16_to_cpu(rate_cfg->action) == HostCmd_ACT_GEN_GET) {
 			if (priv->is_data_rate_auto) {
 				ds_rate->is_rate_auto = 1;
@@ -664,7 +664,7 @@ static int mwifiex_ret_ver_ext(struct mwifiex_private *priv,
 	struct host_cmd_ds_version_ext *version_ext;
 
 	if (data_buf) {
-		version_ext = (struct host_cmd_ds_version_ext *)data_buf;
+		version_ext = data_buf;
 		version_ext->version_str_sel = ver_ext->version_str_sel;
 		memcpy(version_ext->version_str, ver_ext->version_str,
 		       sizeof(char) * 128);
@@ -686,8 +686,8 @@ static int mwifiex_ret_reg_access(u16 type, struct host_cmd_ds_command *resp,
 	struct mwifiex_ds_read_eeprom *eeprom;
 
 	if (data_buf) {
-		reg_rw = (struct mwifiex_ds_reg_rw *) data_buf;
-		eeprom = (struct mwifiex_ds_read_eeprom *) data_buf;
+		reg_rw = data_buf;
+		eeprom = data_buf;
 		switch (type) {
 		case HostCmd_CMD_MAC_REG_ACCESS:
 			{
diff --git a/drivers/net/wireless/mwifiex/txrx.c b/drivers/net/wireless/mwifiex/txrx.c
index aaa50c0..6190b2f 100644
--- a/drivers/net/wireless/mwifiex/txrx.c
+++ b/drivers/net/wireless/mwifiex/txrx.c
@@ -71,7 +71,7 @@ int mwifiex_process_tx(struct mwifiex_private *priv, struct sk_buff *skb,
 	u8 *head_ptr;
 	struct txpd *local_tx_pd = NULL;
 
-	head_ptr = (u8 *) mwifiex_process_sta_txpd(priv, skb);
+	head_ptr = mwifiex_process_sta_txpd(priv, skb);
 	if (head_ptr) {
 		if (GET_BSS_ROLE(priv) == MWIFIEX_BSS_ROLE_STA)
 			local_tx_pd =
diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index 54cc0bb..bdb571f 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -570,7 +570,7 @@ static void p54_parse_default_country(struct ieee80211_hw *dev,
 		return;
 	}
 
-	country = (struct pda_country *) data;
+	country = data;
 	if (country->flags == PDR_COUNTRY_CERT_CODE_PSEUDO)
 		regulatory_hint(dev->wiphy, country->alpha2);
 	else {
@@ -659,7 +659,7 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 	u16 synth = 0;
 	u16 crc16 = ~0;
 
-	wrap = (struct eeprom_pda_wrap *) eeprom;
+	wrap = eeprom;
 	entry = (void *)wrap->data + le16_to_cpu(wrap->len);
 
 	/* verify that at least the entry length/code fits */
-- 
1.7.6.rc0
