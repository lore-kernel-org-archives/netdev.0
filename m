From: Joe Perches <joe@perches.com>
Subject: [PATCH 7/8] wireless: Remove unnecessary alloc/OOM messages, alloc cleanups
Date: Sun,  3 Feb 2013 19:28:14 -0800
Message-ID: <2ca85734ebca68ba90b331355ada00df48ad0724.1359939013.git.joe@perches.com>
References: <cover.1359939012.git.joe@perches.com>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	Simon Kelley <simon@thekelleys.org.uk>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Dan Williams <dcbw@redhat.com>, Bing Zhao <bzhao@marvell.com>,
	Christian Lamparter <chunkeey@googlemail.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Luciano Coelho <coelho@ti.com>, Daniel Drake <dsd@gentoo.org>,
	Ulrich Kunitz <kune@deine-taler.de>,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ath9k-devel@lists.ath9k.org, libertas-dev@lists.infradead.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1359939012.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

alloc failures already get standardized OOM
messages and a dump_stack.

Convert kzalloc's with multiplies to kcalloc.
Convert kmalloc's with multiplies to kmalloc_array.
Remove now unused variables.
Remove unnecessary memset after kzalloc->kcalloc.
Whitespace cleanups for these changes.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/airo_cs.c                     |  5 ++--
 drivers/net/wireless/at76c50x-usb.c                |  4 +---
 .../net/wireless/ath/ath9k/dfs_pattern_detector.c  |  6 ++---
 drivers/net/wireless/atmel_cs.c                    |  5 ++--
 drivers/net/wireless/ipw2x00/ipw2100.c             |  9 +++-----
 drivers/net/wireless/libertas/cfg.c                |  4 +---
 drivers/net/wireless/mwifiex/11n.c                 |  5 +---
 drivers/net/wireless/mwifiex/11n_rxreorder.c       |  5 +---
 drivers/net/wireless/mwifiex/cfg80211.c            |  4 +---
 drivers/net/wireless/mwifiex/cmdevt.c              | 11 +++------
 drivers/net/wireless/mwifiex/init.c                |  5 +---
 drivers/net/wireless/mwifiex/scan.c                | 27 +++++++---------------
 drivers/net/wireless/mwifiex/sdio.c                | 11 ++-------
 drivers/net/wireless/mwifiex/sta_ioctl.c           | 11 +++------
 drivers/net/wireless/mwifiex/wmm.c                 |  7 ++----
 drivers/net/wireless/orinoco/main.c                | 16 ++++---------
 drivers/net/wireless/p54/p54usb.c                  | 10 ++------
 drivers/net/wireless/prism54/islpci_mgt.c          | 14 ++++-------
 drivers/net/wireless/rndis_wlan.c                  |  5 +---
 drivers/net/wireless/ti/wlcore/sdio.c              |  4 +---
 drivers/net/wireless/ti/wlcore/spi.c               | 14 +++--------
 drivers/net/wireless/zd1211rw/zd_usb.c             |  1 -
 22 files changed, 50 insertions(+), 133 deletions(-)

diff --git a/drivers/net/wireless/airo_cs.c b/drivers/net/wireless/airo_cs.c
index 630577d..956024a 100644
--- a/drivers/net/wireless/airo_cs.c
+++ b/drivers/net/wireless/airo_cs.c
@@ -69,10 +69,9 @@ static int airo_probe(struct pcmcia_device *p_dev)
 
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
-	if (!local) {
-		printk(KERN_ERR "airo_cs: no memory for new device\n");
+	if (!local)
 		return -ENOMEM;
-	}
+
 	p_dev->priv = local;
 
 	return airo_config(p_dev);
diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 77fa428..5ac5f7a 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2164,10 +2164,8 @@ static int at76_alloc_urbs(struct at76_priv *priv,
 
 	buffer_size = sizeof(struct at76_tx_buffer) + MAX_PADDING_SIZE;
 	priv->bulk_out_buffer = kmalloc(buffer_size, GFP_KERNEL);
-	if (!priv->bulk_out_buffer) {
-		dev_err(&interface->dev, "cannot allocate output buffer\n");
+	if (!priv->bulk_out_buffer)
 		return -ENOMEM;
-	}
 
 	at76_dbg(DBG_PROC_ENTRY, "%s: EXIT", __func__);
 
diff --git a/drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c b/drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c
index 24877b0..467b600 100644
--- a/drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c
+++ b/drivers/net/wireless/ath/ath9k/dfs_pattern_detector.c
@@ -288,11 +288,11 @@ struct dfs_pattern_detector *
 dfs_pattern_detector_init(enum nl80211_dfs_regions region)
 {
 	struct dfs_pattern_detector *dpd;
+
 	dpd = kmalloc(sizeof(*dpd), GFP_KERNEL);
-	if (dpd == NULL) {
-		pr_err("allocation of dfs_pattern_detector failed\n");
+	if (dpd == NULL)
 		return NULL;
-	}
+
 	*dpd = default_dpd;
 	INIT_LIST_HEAD(&dpd->channel_detectors);
 
diff --git a/drivers/net/wireless/atmel_cs.c b/drivers/net/wireless/atmel_cs.c
index ded03d2..b42930f 100644
--- a/drivers/net/wireless/atmel_cs.c
+++ b/drivers/net/wireless/atmel_cs.c
@@ -79,10 +79,9 @@ static int atmel_probe(struct pcmcia_device *p_dev)
 
 	/* Allocate space for private device-specific data */
 	local = kzalloc(sizeof(local_info_t), GFP_KERNEL);
-	if (!local) {
-		printk(KERN_ERR "atmel_cs: no memory for new device\n");
+	if (!local)
 		return -ENOMEM;
-	}
+
 	p_dev->priv = local;
 
 	return atmel_config(p_dev);
diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index d92b21a..04d5e64 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -4478,13 +4478,10 @@ static int ipw2100_tx_allocate(struct ipw2100_priv *priv)
 		return err;
 	}
 
-	priv->tx_buffers =
-	    kmalloc(TX_PENDED_QUEUE_LENGTH * sizeof(struct ipw2100_tx_packet),
-		    GFP_ATOMIC);
+	priv->tx_buffers = kmalloc_array(TX_PENDED_QUEUE_LENGTH,
+					 sizeof(struct ipw2100_tx_packet),
+					 GFP_ATOMIC);
 	if (!priv->tx_buffers) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: alloc failed form tx buffers.\n",
-		       priv->net_dev->name);
 		bd_queue_free(priv, &priv->tx_queue);
 		return -ENOMEM;
 	}
diff --git a/drivers/net/wireless/libertas/cfg.c b/drivers/net/wireless/libertas/cfg.c
index 230f8eb..a7dcb2e 100644
--- a/drivers/net/wireless/libertas/cfg.c
+++ b/drivers/net/wireless/libertas/cfg.c
@@ -2081,10 +2081,8 @@ struct wireless_dev *lbs_cfg_alloc(struct device *dev)
 	lbs_deb_enter(LBS_DEB_CFG80211);
 
 	wdev = kzalloc(sizeof(struct wireless_dev), GFP_KERNEL);
-	if (!wdev) {
-		dev_err(dev, "cannot allocate wireless device\n");
+	if (!wdev)
 		return ERR_PTR(-ENOMEM);
-	}
 
 	wdev->wiphy = wiphy_new(&lbs_cfg80211_ops, sizeof(struct lbs_private));
 	if (!wdev->wiphy) {
diff --git a/drivers/net/wireless/mwifiex/11n.c b/drivers/net/wireless/mwifiex/11n.c
index 48cc46b..25596ab 100644
--- a/drivers/net/wireless/mwifiex/11n.c
+++ b/drivers/net/wireless/mwifiex/11n.c
@@ -494,11 +494,8 @@ void mwifiex_create_ba_tbl(struct mwifiex_private *priv, u8 *ra, int tid,
 	if (!mwifiex_get_ba_tbl(priv, tid, ra)) {
 		new_node = kzalloc(sizeof(struct mwifiex_tx_ba_stream_tbl),
 				   GFP_ATOMIC);
-		if (!new_node) {
-			dev_err(priv->adapter->dev,
-				"%s: failed to alloc new_node\n", __func__);
+		if (!new_node)
 			return;
-		}
 
 		INIT_LIST_HEAD(&new_node->list);
 
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wireless/mwifiex/11n_rxreorder.c
index 4a97acd..5e796f8 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -272,11 +272,8 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_private *priv, u8 *ta,
 	}
 	/* if !tbl then create one */
 	new_node = kzalloc(sizeof(struct mwifiex_rx_reorder_tbl), GFP_KERNEL);
-	if (!new_node) {
-		dev_err(priv->adapter->dev, "%s: failed to alloc new_node\n",
-			__func__);
+	if (!new_node)
 		return;
-	}
 
 	INIT_LIST_HEAD(&new_node->list);
 	new_node->tid = tid;
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless/mwifiex/cfg80211.c
index ab92e79..8ba4819 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -1820,10 +1820,8 @@ mwifiex_cfg80211_scan(struct wiphy *wiphy,
 
 	priv->user_scan_cfg = kzalloc(sizeof(struct mwifiex_user_scan_cfg),
 				      GFP_KERNEL);
-	if (!priv->user_scan_cfg) {
-		dev_err(priv->adapter->dev, "failed to alloc scan_req\n");
+	if (!priv->user_scan_cfg)
 		return -ENOMEM;
-	}
 
 	priv->scan_request = request;
 
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/mwifiex/cmdevt.c
index 5f438e6..2b125be 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -334,20 +334,15 @@ static int mwifiex_dnld_sleep_confirm_cmd(struct mwifiex_adapter *adapter)
 int mwifiex_alloc_cmd_buffer(struct mwifiex_adapter *adapter)
 {
 	struct cmd_ctrl_node *cmd_array;
-	u32 buf_size;
 	u32 i;
 
 	/* Allocate and initialize struct cmd_ctrl_node */
-	buf_size = sizeof(struct cmd_ctrl_node) * MWIFIEX_NUM_OF_CMD_BUFFER;
-	cmd_array = kzalloc(buf_size, GFP_KERNEL);
-	if (!cmd_array) {
-		dev_err(adapter->dev, "%s: failed to alloc cmd_array\n",
-			__func__);
+	cmd_array = kcalloc(MWIFIEX_NUM_OF_CMD_BUFFER,
+			    sizeof(struct cmd_ctrl_node), GFP_KERNEL);
+	if (!cmd_array)
 		return -ENOMEM;
-	}
 
 	adapter->cmd_pool = cmd_array;
-	memset(adapter->cmd_pool, 0, buf_size);
 
 	/* Allocate and initialize command buffers */
 	for (i = 0; i < MWIFIEX_NUM_OF_CMD_BUFFER; i++) {
diff --git a/drivers/net/wireless/mwifiex/init.c b/drivers/net/wireless/mwifiex/init.c
index 820a19c..e38aa9b 100644
--- a/drivers/net/wireless/mwifiex/init.c
+++ b/drivers/net/wireless/mwifiex/init.c
@@ -39,11 +39,8 @@ static int mwifiex_add_bss_prio_tbl(struct mwifiex_private *priv)
 	unsigned long flags;
 
 	bss_prio = kzalloc(sizeof(struct mwifiex_bss_prio_node), GFP_KERNEL);
-	if (!bss_prio) {
-		dev_err(adapter->dev, "%s: failed to alloc bss_prio\n",
-			__func__);
+	if (!bss_prio)
 		return -ENOMEM;
-	}
 
 	bss_prio->priv = priv;
 	INIT_LIST_HEAD(&bss_prio->list);
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
index 973a9d9..d41f0e6 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1309,7 +1309,6 @@ int mwifiex_scan_networks(struct mwifiex_private *priv,
 	struct cmd_ctrl_node *cmd_node;
 	union mwifiex_scan_cmd_config_tlv *scan_cfg_out;
 	struct mwifiex_ie_types_chan_list_param_set *chan_list_out;
-	u32 buf_size;
 	struct mwifiex_chan_scan_param_set *scan_chan_list;
 	u8 filtered_scan;
 	u8 scan_current_chan_only;
@@ -1332,18 +1331,16 @@ int mwifiex_scan_networks(struct mwifiex_private *priv,
 	spin_unlock_irqrestore(&adapter->mwifiex_cmd_lock, flags);
 
 	scan_cfg_out = kzalloc(sizeof(union mwifiex_scan_cmd_config_tlv),
-								GFP_KERNEL);
+			       GFP_KERNEL);
 	if (!scan_cfg_out) {
-		dev_err(adapter->dev, "failed to alloc scan_cfg_out\n");
 		ret = -ENOMEM;
 		goto done;
 	}
 
-	buf_size = sizeof(struct mwifiex_chan_scan_param_set) *
-						MWIFIEX_USER_SCAN_CHAN_MAX;
-	scan_chan_list = kzalloc(buf_size, GFP_KERNEL);
+	scan_chan_list = kcalloc(MWIFIEX_USER_SCAN_CHAN_MAX,
+				 sizeof(struct mwifiex_chan_scan_param_set),
+				 GFP_KERNEL);
 	if (!scan_chan_list) {
-		dev_err(adapter->dev, "failed to alloc scan_chan_list\n");
 		kfree(scan_cfg_out);
 		ret = -ENOMEM;
 		goto done;
@@ -1461,12 +1458,9 @@ static int mwifiex_update_curr_bss_params(struct mwifiex_private *priv,
 	unsigned long flags;
 
 	/* Allocate and fill new bss descriptor */
-	bss_desc = kzalloc(sizeof(struct mwifiex_bssdescriptor),
-			GFP_KERNEL);
-	if (!bss_desc) {
-		dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
+	bss_desc = kzalloc(sizeof(struct mwifiex_bssdescriptor), GFP_KERNEL);
+	if (!bss_desc)
 		return -ENOMEM;
-	}
 
 	ret = mwifiex_fill_new_bss_desc(priv, bss, bss_desc);
 	if (ret)
@@ -1880,10 +1874,8 @@ static int mwifiex_scan_specific_ssid(struct mwifiex_private *priv,
 	}
 
 	scan_cfg = kzalloc(sizeof(struct mwifiex_user_scan_cfg), GFP_KERNEL);
-	if (!scan_cfg) {
-		dev_err(adapter->dev, "failed to alloc scan_cfg\n");
+	if (!scan_cfg)
 		return -ENOMEM;
-	}
 
 	scan_cfg->ssid_list = req_ssid;
 	scan_cfg->num_ssids = 1;
@@ -1997,11 +1989,8 @@ mwifiex_save_curr_bcn(struct mwifiex_private *priv)
 		kfree(priv->curr_bcn_buf);
 		priv->curr_bcn_buf = kmalloc(curr_bss->beacon_buf_size,
 					     GFP_ATOMIC);
-		if (!priv->curr_bcn_buf) {
-			dev_err(priv->adapter->dev,
-				"failed to alloc curr_bcn_buf\n");
+		if (!priv->curr_bcn_buf)
 			return;
-		}
 	}
 
 	memcpy(priv->curr_bcn_buf, curr_bss->beacon_buf,
diff --git a/drivers/net/wireless/mwifiex/sdio.c b/drivers/net/wireless/mwifiex/sdio.c
index 6ada6a8c..e63f646 100644
--- a/drivers/net/wireless/mwifiex/sdio.c
+++ b/drivers/net/wireless/mwifiex/sdio.c
@@ -716,11 +716,8 @@ static int mwifiex_prog_fw_w_helper(struct mwifiex_adapter *adapter,
 
 	/* Assume that the allocated buffer is 8-byte aligned */
 	fwbuf = kzalloc(MWIFIEX_UPLD_SIZE, GFP_KERNEL);
-	if (!fwbuf) {
-		dev_err(adapter->dev,
-			"unable to alloc buffer for FW. Terminating dnld\n");
+	if (!fwbuf)
 		return -ENOMEM;
-	}
 
 	/* Perform firmware data transfer */
 	do {
@@ -1518,7 +1515,6 @@ static int mwifiex_alloc_sdio_mpa_buffers(struct mwifiex_adapter *adapter,
 
 	card->mpa_tx.buf = kzalloc(mpa_tx_buf_size, GFP_KERNEL);
 	if (!card->mpa_tx.buf) {
-		dev_err(adapter->dev, "could not alloc buffer for MP-A TX\n");
 		ret = -1;
 		goto error;
 	}
@@ -1527,7 +1523,6 @@ static int mwifiex_alloc_sdio_mpa_buffers(struct mwifiex_adapter *adapter,
 
 	card->mpa_rx.buf = kzalloc(mpa_rx_buf_size, GFP_KERNEL);
 	if (!card->mpa_rx.buf) {
-		dev_err(adapter->dev, "could not alloc buffer for MP-A RX\n");
 		ret = -1;
 		goto error;
 	}
@@ -1680,10 +1675,8 @@ static int mwifiex_init_sdio(struct mwifiex_adapter *adapter)
 
 	/* Allocate buffers for SDIO MP-A */
 	card->mp_regs = kzalloc(MAX_MP_REGS, GFP_KERNEL);
-	if (!card->mp_regs) {
-		dev_err(adapter->dev, "failed to alloc mp_regs\n");
+	if (!card->mp_regs)
 		return -ENOMEM;
-	}
 
 	ret = mwifiex_alloc_sdio_mpa_buffers(adapter,
 					     SDIO_MP_TX_AGGR_DEF_BUF_SIZE,
diff --git a/drivers/net/wireless/mwifiex/sta_ioctl.c b/drivers/net/wireless/mwifiex/sta_ioctl.c
index f542bb8..b8fa76a 100644
--- a/drivers/net/wireless/mwifiex/sta_ioctl.c
+++ b/drivers/net/wireless/mwifiex/sta_ioctl.c
@@ -266,11 +266,9 @@ int mwifiex_bss_start(struct mwifiex_private *priv, struct cfg80211_bss *bss,
 
 		/* Allocate and fill new bss descriptor */
 		bss_desc = kzalloc(sizeof(struct mwifiex_bssdescriptor),
-				GFP_KERNEL);
-		if (!bss_desc) {
-			dev_err(priv->adapter->dev, " failed to alloc bss_desc\n");
+				   GFP_KERNEL);
+		if (!bss_desc)
 			return -ENOMEM;
-		}
 
 		ret = mwifiex_fill_new_bss_desc(priv, bss, bss_desc);
 		if (ret)
@@ -636,11 +634,8 @@ int mwifiex_set_tx_power(struct mwifiex_private *priv,
 		}
 	}
 	buf = kzalloc(MWIFIEX_SIZE_OF_CMD_BUFFER, GFP_KERNEL);
-	if (!buf) {
-		dev_err(priv->adapter->dev, "%s: failed to alloc cmd buffer\n",
-			__func__);
+	if (!buf)
 		return -ENOMEM;
-	}
 
 	txp_cfg = (struct host_cmd_ds_txpwr_cfg *) buf;
 	txp_cfg->action = cpu_to_le16(HostCmd_ACT_GEN_SET);
diff --git a/drivers/net/wireless/mwifiex/wmm.c b/drivers/net/wireless/mwifiex/wmm.c
index 135d96d..32adc87 100644
--- a/drivers/net/wireless/mwifiex/wmm.c
+++ b/drivers/net/wireless/mwifiex/wmm.c
@@ -109,12 +109,9 @@ mwifiex_wmm_allocate_ralist_node(struct mwifiex_adapter *adapter, u8 *ra)
 	struct mwifiex_ra_list_tbl *ra_list;
 
 	ra_list = kzalloc(sizeof(struct mwifiex_ra_list_tbl), GFP_ATOMIC);
-
-	if (!ra_list) {
-		dev_err(adapter->dev, "%s: failed to alloc ra_list\n",
-			__func__);
+	if (!ra_list)
 		return NULL;
-	}
+
 	INIT_LIST_HEAD(&ra_list->list);
 	skb_queue_head_init(&ra_list->skb_head);
 
diff --git a/drivers/net/wireless/orinoco/main.c b/drivers/net/wireless/orinoco/main.c
index 1e802f8..38ec8d1 100644
--- a/drivers/net/wireless/orinoco/main.c
+++ b/drivers/net/wireless/orinoco/main.c
@@ -853,12 +853,8 @@ void __orinoco_ev_rx(struct net_device *dev, struct hermes *hw)
 	int err;
 
 	desc = kmalloc(sizeof(*desc), GFP_ATOMIC);
-	if (!desc) {
-		printk(KERN_WARNING
-		       "%s: Can't allocate space for RX descriptor\n",
-		       dev->name);
+	if (!desc)
 		goto update_stats;
-	}
 
 	rxfid = hermes_read_regn(hw, RXFID);
 
@@ -1336,10 +1332,9 @@ static void qbuf_scan(struct orinoco_private *priv, void *buf,
 	unsigned long flags;
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
-	if (!sd) {
-		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+	if (!sd)
 		return;
-	}
+
 	sd->buf = buf;
 	sd->len = len;
 	sd->type = type;
@@ -1357,10 +1352,9 @@ static void qabort_scan(struct orinoco_private *priv)
 	unsigned long flags;
 
 	sd = kmalloc(sizeof(*sd), GFP_ATOMIC);
-	if (!sd) {
-		printk(KERN_ERR "%s: failed to alloc memory\n", __func__);
+	if (!sd)
 		return;
-	}
+
 	sd->len = -1; /* Abort */
 
 	spin_lock_irqsave(&priv->scan_lock, flags);
diff --git a/drivers/net/wireless/p54/p54usb.c b/drivers/net/wireless/p54/p54usb.c
index 800a165..62ac607 100644
--- a/drivers/net/wireless/p54/p54usb.c
+++ b/drivers/net/wireless/p54/p54usb.c
@@ -510,11 +510,8 @@ static int p54u_upload_firmware_3887(struct ieee80211_hw *dev)
 		return err;
 
 	tmp = buf = kmalloc(P54U_FW_BLOCK, GFP_KERNEL);
-	if (!buf) {
-		dev_err(&priv->udev->dev, "(p54usb) cannot allocate firmware"
-					  "upload buffer!\n");
+	if (!buf)
 		return -ENOMEM;
-	}
 
 	left = block_size = min((size_t)P54U_FW_BLOCK, priv->fw->size);
 	strcpy(buf, p54u_firmware_upload_3887);
@@ -637,11 +634,8 @@ static int p54u_upload_firmware_net2280(struct ieee80211_hw *dev)
 	const u8 *data;
 
 	buf = kmalloc(512, GFP_KERNEL);
-	if (!buf) {
-		dev_err(&priv->udev->dev, "(p54usb) firmware buffer "
-					  "alloc failed!\n");
+	if (!buf)
 		return -ENOMEM;
-	}
 
 #define P54U_WRITE(type, addr, data) \
 	do {\
diff --git a/drivers/net/wireless/prism54/islpci_mgt.c b/drivers/net/wireless/prism54/islpci_mgt.c
index c5404cb..9f19cce 100644
--- a/drivers/net/wireless/prism54/islpci_mgt.c
+++ b/drivers/net/wireless/prism54/islpci_mgt.c
@@ -123,11 +123,8 @@ islpci_mgmt_rx_fill(struct net_device *ndev)
 
 		if (buf->mem == NULL) {
 			buf->mem = kmalloc(MGMT_FRAME_SIZE, GFP_ATOMIC);
-			if (!buf->mem) {
-				printk(KERN_WARNING
-				       "Error allocating management frame.\n");
+			if (!buf->mem)
 				return -ENOMEM;
-			}
 			buf->size = MGMT_FRAME_SIZE;
 		}
 		if (buf->pci_addr == 0) {
@@ -356,14 +353,11 @@ islpci_mgt_receive(struct net_device *ndev)
 
 		/* Determine frame size, skipping OID_INL_TUNNEL headers. */
 		size = PIMFOR_HEADER_SIZE + header->length;
-		frame = kmalloc(sizeof (struct islpci_mgmtframe) + size,
+		frame = kmalloc(sizeof(struct islpci_mgmtframe) + size,
 				GFP_ATOMIC);
-		if (!frame) {
-			printk(KERN_WARNING
-			       "%s: Out of memory, cannot handle oid 0x%08x\n",
-			       ndev->name, header->oid);
+		if (!frame)
 			continue;
-		}
+
 		frame->ndev = ndev;
 		memcpy(&frame->buf, header, size);
 		frame->header = (pimfor_header_t *) frame->buf;
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index abe1d03..9bb3f22 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -1621,11 +1621,8 @@ static void set_multicast_list(struct usbnet *usbdev)
 	} else if (mc_count) {
 		int i = 0;
 
-		mc_addrs = kmalloc(mc_count * ETH_ALEN, GFP_ATOMIC);
+		mc_addrs = kmalloc_array(mc_count, ETH_ALEN, GFP_ATOMIC);
 		if (!mc_addrs) {
-			netdev_warn(usbdev->net,
-				    "couldn't alloc %d bytes of memory\n",
-				    mc_count * ETH_ALEN);
 			netif_addr_unlock_bh(usbdev->net);
 			return;
 		}
diff --git a/drivers/net/wireless/ti/wlcore/sdio.c b/drivers/net/wireless/ti/wlcore/sdio.c
index d4f184e..75622f6 100644
--- a/drivers/net/wireless/ti/wlcore/sdio.c
+++ b/drivers/net/wireless/ti/wlcore/sdio.c
@@ -229,10 +229,8 @@ static int wl1271_probe(struct sdio_func *func,
 		return -ENODEV;
 
 	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
-	if (!glue) {
-		dev_err(&func->dev, "can't allocate glue\n");
+	if (!glue)
 		goto out;
-	}
 
 	glue->dev = &func->dev;
 
diff --git a/drivers/net/wireless/ti/wlcore/spi.c b/drivers/net/wireless/ti/wlcore/spi.c
index 2d700b7..53790d1 100644
--- a/drivers/net/wireless/ti/wlcore/spi.c
+++ b/drivers/net/wireless/ti/wlcore/spi.c
@@ -87,11 +87,8 @@ static void wl12xx_spi_reset(struct device *child)
 	struct spi_message m;
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
-	if (!cmd) {
-		dev_err(child->parent,
-			"could not allocate cmd for spi reset\n");
+	if (!cmd)
 		return;
-	}
 
 	memset(&t, 0, sizeof(t));
 	spi_message_init(&m);
@@ -115,11 +112,8 @@ static void wl12xx_spi_init(struct device *child)
 	struct spi_message m;
 
 	cmd = kzalloc(WSPI_INIT_CMD_LEN, GFP_KERNEL);
-	if (!cmd) {
-		dev_err(child->parent,
-			"could not allocate cmd for spi init\n");
+	if (!cmd)
 		return;
-	}
 
 	memset(crc, 0, sizeof(crc));
 	memset(&t, 0, sizeof(t));
@@ -340,10 +334,8 @@ static int wl1271_probe(struct spi_device *spi)
 	pdata->ops = &spi_ops;
 
 	glue = kzalloc(sizeof(*glue), GFP_KERNEL);
-	if (!glue) {
-		dev_err(&spi->dev, "can't allocate glue\n");
+	if (!glue)
 		goto out;
-	}
 
 	glue->dev = &spi->dev;
 
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index ef2b171..7ef0b4a 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -155,7 +155,6 @@ static int upload_code(struct usb_device *udev,
 	 */
 	p = kmalloc(MAX_TRANSFER_SIZE, GFP_KERNEL);
 	if (!p) {
-		dev_err(&udev->dev, "out of memory\n");
 		r = -ENOMEM;
 		goto error;
 	}
-- 
1.8.0.dirty
