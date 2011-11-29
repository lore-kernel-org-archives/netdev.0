From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] nfc: Convert nfc_dbg to pr_debug
Date: Tue, 29 Nov 2011 11:37:33 -0800
Message-ID: <f211de7bafcd70f74295ffbc2f50cec93a1785a0.1322595343.git.joe@perches.com>
References: <cover.1322595343.git.joe@perches.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1322595343.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using the standard debugging mechanisms is better than
subsystem specific ones when the subsystem doesn't use
a specific struct.

Coalesce long formats.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/nfc/core.c     |   37 ++++++++++++-----------
 net/nfc/nci/core.c |   56 ++++++++++++++++++------------------
 net/nfc/nci/data.c |   22 +++++++-------
 net/nfc/nci/ntf.c  |   67 +++++++++++++++++++++----------------------
 net/nfc/nci/rsp.c  |   80 ++++++++++++++++++++++++++--------------------------
 net/nfc/netlink.c  |   32 +++++++++++----------
 net/nfc/rawsock.c  |   24 ++++++++--------
 7 files changed, 160 insertions(+), 158 deletions(-)

diff --git a/net/nfc/core.c b/net/nfc/core.c
index 03e4571..c922adb 100644
--- a/net/nfc/core.c
+++ b/net/nfc/core.c
@@ -65,7 +65,7 @@ int nfc_dev_up(struct nfc_dev *dev)
 {
 	int rc = 0;
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	device_lock(&dev->dev);
 
@@ -99,7 +99,7 @@ int nfc_dev_down(struct nfc_dev *dev)
 {
 	int rc = 0;
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	device_lock(&dev->dev);
 
@@ -141,7 +141,8 @@ int nfc_start_poll(struct nfc_dev *dev, u32 protocols)
 {
 	int rc;
 
-	nfc_dbg("dev_name=%s protocols=0x%x", dev_name(&dev->dev), protocols);
+	pr_debug("dev_name=%s protocols=0x%x\n",
+		 dev_name(&dev->dev), protocols);
 
 	if (!protocols)
 		return -EINVAL;
@@ -176,7 +177,7 @@ int nfc_stop_poll(struct nfc_dev *dev)
 {
 	int rc = 0;
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	device_lock(&dev->dev);
 
@@ -209,8 +210,8 @@ int nfc_activate_target(struct nfc_dev *dev, u32 target_idx, u32 protocol)
 {
 	int rc;
 
-	nfc_dbg("dev_name=%s target_idx=%u protocol=%u", dev_name(&dev->dev),
-							target_idx, protocol);
+	pr_debug("dev_name=%s target_idx=%u protocol=%u\n",
+		 dev_name(&dev->dev), target_idx, protocol);
 
 	device_lock(&dev->dev);
 
@@ -238,7 +239,8 @@ int nfc_deactivate_target(struct nfc_dev *dev, u32 target_idx)
 {
 	int rc = 0;
 
-	nfc_dbg("dev_name=%s target_idx=%u", dev_name(&dev->dev), target_idx);
+	pr_debug("dev_name=%s target_idx=%u\n",
+		 dev_name(&dev->dev), target_idx);
 
 	device_lock(&dev->dev);
 
@@ -273,8 +275,8 @@ int nfc_data_exchange(struct nfc_dev *dev, u32 target_idx,
 {
 	int rc;
 
-	nfc_dbg("dev_name=%s target_idx=%u skb->len=%u", dev_name(&dev->dev),
-							target_idx, skb->len);
+	pr_debug("dev_name=%s target_idx=%u skb->len=%u\n",
+		 dev_name(&dev->dev), target_idx, skb->len);
 
 	device_lock(&dev->dev);
 
@@ -328,7 +330,7 @@ int nfc_targets_found(struct nfc_dev *dev, struct nfc_target *targets,
 {
 	int i;
 
-	nfc_dbg("dev_name=%s n_targets=%d", dev_name(&dev->dev), n_targets);
+	pr_debug("dev_name=%s n_targets=%d\n", dev_name(&dev->dev), n_targets);
 
 	dev->polling = false;
 
@@ -362,7 +364,7 @@ static void nfc_release(struct device *d)
 {
 	struct nfc_dev *dev = to_nfc_dev(d);
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	nfc_genl_data_exit(&dev->genl_data);
 	kfree(dev->targets);
@@ -448,7 +450,7 @@ int nfc_register_device(struct nfc_dev *dev)
 {
 	int rc;
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	mutex_lock(&nfc_devlist_mutex);
 	nfc_devlist_generation++;
@@ -460,9 +462,8 @@ int nfc_register_device(struct nfc_dev *dev)
 
 	rc = nfc_genl_device_added(dev);
 	if (rc)
-		nfc_dbg("The userspace won't be notified that the device %s was"
-						" added", dev_name(&dev->dev));
-
+		pr_debug("The userspace won't be notified that the device %s was added\n",
+			 dev_name(&dev->dev));
 
 	return 0;
 }
@@ -477,7 +478,7 @@ void nfc_unregister_device(struct nfc_dev *dev)
 {
 	int rc;
 
-	nfc_dbg("dev_name=%s", dev_name(&dev->dev));
+	pr_debug("dev_name=%s\n", dev_name(&dev->dev));
 
 	mutex_lock(&nfc_devlist_mutex);
 	nfc_devlist_generation++;
@@ -492,8 +493,8 @@ void nfc_unregister_device(struct nfc_dev *dev)
 
 	rc = nfc_genl_device_removed(dev);
 	if (rc)
-		nfc_dbg("The userspace won't be notified that the device %s"
-					" was removed", dev_name(&dev->dev));
+		pr_debug("The userspace won't be notified that the device %s was removed\n",
+			 dev_name(&dev->dev));
 
 }
 EXPORT_SYMBOL(nfc_unregister_device);
diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 30032b2..3faceb0 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -81,7 +81,7 @@ static int __nci_request(struct nci_dev *ndev,
 							&ndev->req_completion,
 							timeout);
 
-	nfc_dbg("wait_for_completion return %ld", completion_rc);
+	pr_debug("wait_for_completion return %ld\n", completion_rc);
 
 	if (completion_rc > 0) {
 		switch (ndev->req_status) {
@@ -325,7 +325,7 @@ static void nci_cmd_timer(unsigned long arg)
 {
 	struct nci_dev *ndev = (void *) arg;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	atomic_set(&ndev->cmd_cnt, 1);
 	queue_work(ndev->cmd_wq, &ndev->cmd_work);
@@ -335,7 +335,7 @@ static int nci_dev_up(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	return nci_open_device(ndev);
 }
@@ -344,7 +344,7 @@ static int nci_dev_down(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	return nci_close_device(ndev);
 }
@@ -354,7 +354,7 @@ static int nci_start_poll(struct nfc_dev *nfc_dev, __u32 protocols)
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (test_bit(NCI_DISCOVERY, &ndev->flags)) {
 		pr_err("unable to start poll, since poll is already active\n");
@@ -367,7 +367,7 @@ static int nci_start_poll(struct nfc_dev *nfc_dev, __u32 protocols)
 	}
 
 	if (test_bit(NCI_POLL_ACTIVE, &ndev->flags)) {
-		nfc_dbg("target is active, implicitly deactivate...");
+		pr_debug("target is active, implicitly deactivate...\n");
 
 		rc = nci_request(ndev, nci_rf_deactivate_req, 0,
 			msecs_to_jiffies(NCI_RF_DEACTIVATE_TIMEOUT));
@@ -388,7 +388,7 @@ static void nci_stop_poll(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!test_bit(NCI_DISCOVERY, &ndev->flags)) {
 		pr_err("unable to stop poll, since poll is not active\n");
@@ -404,7 +404,7 @@ static int nci_activate_target(struct nfc_dev *nfc_dev, __u32 target_idx,
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dbg("entry, target_idx %d, protocol 0x%x", target_idx, protocol);
+	pr_debug("entry, target_idx %d, protocol 0x%x\n", target_idx, protocol);
 
 	if (!test_bit(NCI_POLL_ACTIVE, &ndev->flags)) {
 		pr_err("there is no available target to activate\n");
@@ -432,7 +432,7 @@ static void nci_deactivate_target(struct nfc_dev *nfc_dev, __u32 target_idx)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dbg("entry, target_idx %d", target_idx);
+	pr_debug("entry, target_idx %d\n", target_idx);
 
 	if (!ndev->target_active_prot) {
 		pr_err("unable to deactivate target, no active target\n");
@@ -455,7 +455,7 @@ static int nci_data_exchange(struct nfc_dev *nfc_dev, __u32 target_idx,
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	nfc_dbg("entry, target_idx %d, len %d", target_idx, skb->len);
+	pr_debug("entry, target_idx %d, len %d\n", target_idx, skb->len);
 
 	if (!ndev->target_active_prot) {
 		pr_err("unable to exchange data, no active target\n");
@@ -501,7 +501,7 @@ struct nci_dev *nci_allocate_device(struct nci_ops *ops,
 {
 	struct nci_dev *ndev;
 
-	nfc_dbg("entry, supported_protocols 0x%x", supported_protocols);
+	pr_debug("entry, supported_protocols 0x%x\n", supported_protocols);
 
 	if (!ops->open || !ops->close || !ops->send)
 		return NULL;
@@ -541,7 +541,7 @@ EXPORT_SYMBOL(nci_allocate_device);
  */
 void nci_free_device(struct nci_dev *ndev)
 {
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	nfc_free_device(ndev->nfc_dev);
 	kfree(ndev);
@@ -559,7 +559,7 @@ int nci_register_device(struct nci_dev *ndev)
 	struct device *dev = &ndev->nfc_dev->dev;
 	char name[32];
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	rc = nfc_register_device(ndev->nfc_dev);
 	if (rc)
@@ -623,7 +623,7 @@ EXPORT_SYMBOL(nci_register_device);
  */
 void nci_unregister_device(struct nci_dev *ndev)
 {
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	nci_close_device(ndev);
 
@@ -644,7 +644,7 @@ int nci_recv_frame(struct sk_buff *skb)
 {
 	struct nci_dev *ndev = (struct nci_dev *) skb->dev;
 
-	nfc_dbg("entry, len %d", skb->len);
+	pr_debug("entry, len %d\n", skb->len);
 
 	if (!ndev || (!test_bit(NCI_UP, &ndev->flags)
 		&& !test_bit(NCI_INIT, &ndev->flags))) {
@@ -664,7 +664,7 @@ static int nci_send_frame(struct sk_buff *skb)
 {
 	struct nci_dev *ndev = (struct nci_dev *) skb->dev;
 
-	nfc_dbg("entry, len %d", skb->len);
+	pr_debug("entry, len %d\n", skb->len);
 
 	if (!ndev) {
 		kfree_skb(skb);
@@ -683,7 +683,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 	struct nci_ctrl_hdr *hdr;
 	struct sk_buff *skb;
 
-	nfc_dbg("entry, opcode 0x%x, plen %d", opcode, plen);
+	pr_debug("entry, opcode 0x%x, plen %d\n", opcode, plen);
 
 	skb = nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + plen), GFP_KERNEL);
 	if (!skb) {
@@ -717,7 +717,7 @@ static void nci_tx_work(struct work_struct *work)
 	struct nci_dev *ndev = container_of(work, struct nci_dev, tx_work);
 	struct sk_buff *skb;
 
-	nfc_dbg("entry, credits_cnt %d", atomic_read(&ndev->credits_cnt));
+	pr_debug("entry, credits_cnt %d\n", atomic_read(&ndev->credits_cnt));
 
 	/* Send queued tx data */
 	while (atomic_read(&ndev->credits_cnt)) {
@@ -730,10 +730,10 @@ static void nci_tx_work(struct work_struct *work)
 				NCI_DATA_FLOW_CONTROL_NOT_USED)
 			atomic_dec(&ndev->credits_cnt);
 
-		nfc_dbg("NCI TX: MT=data, PBF=%d, conn_id=%d, plen=%d",
-				nci_pbf(skb->data),
-				nci_conn_id(skb->data),
-				nci_plen(skb->data));
+		pr_debug("NCI TX: MT=data, PBF=%d, conn_id=%d, plen=%d\n",
+			 nci_pbf(skb->data),
+			 nci_conn_id(skb->data),
+			 nci_plen(skb->data));
 
 		nci_send_frame(skb);
 	}
@@ -776,7 +776,7 @@ static void nci_cmd_work(struct work_struct *work)
 	struct nci_dev *ndev = container_of(work, struct nci_dev, cmd_work);
 	struct sk_buff *skb;
 
-	nfc_dbg("entry, cmd_cnt %d", atomic_read(&ndev->cmd_cnt));
+	pr_debug("entry, cmd_cnt %d\n", atomic_read(&ndev->cmd_cnt));
 
 	/* Send queued command */
 	if (atomic_read(&ndev->cmd_cnt)) {
@@ -786,11 +786,11 @@ static void nci_cmd_work(struct work_struct *work)
 
 		atomic_dec(&ndev->cmd_cnt);
 
-		nfc_dbg("NCI TX: MT=cmd, PBF=%d, GID=0x%x, OID=0x%x, plen=%d",
-				nci_pbf(skb->data),
-				nci_opcode_gid(nci_opcode(skb->data)),
-				nci_opcode_oid(nci_opcode(skb->data)),
-				nci_plen(skb->data));
+		pr_debug("NCI TX: MT=cmd, PBF=%d, GID=0x%x, OID=0x%x, plen=%d\n",
+			 nci_pbf(skb->data),
+			 nci_opcode_gid(nci_opcode(skb->data)),
+			 nci_opcode_oid(nci_opcode(skb->data)),
+			 nci_plen(skb->data));
 
 		nci_send_frame(skb);
 
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 7d8a125..3c5db09 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -42,7 +42,7 @@ void nci_data_exchange_complete(struct nci_dev *ndev,
 	data_exchange_cb_t cb = ndev->data_exchange_cb;
 	void *cb_context = ndev->data_exchange_cb_context;
 
-	nfc_dbg("entry, len %d, err %d", ((skb) ? (skb->len) : (0)), err);
+	pr_debug("entry, len %d, err %d\n", skb ? skb->len : 0, err);
 
 	if (cb) {
 		ndev->data_exchange_cb = NULL;
@@ -92,7 +92,7 @@ static int nci_queue_tx_data_frags(struct nci_dev *ndev,
 	int frag_len;
 	int rc = 0;
 
-	nfc_dbg("entry, conn_id 0x%x, total_len %d", conn_id, total_len);
+	pr_debug("entry, conn_id 0x%x, total_len %d\n", conn_id, total_len);
 
 	__skb_queue_head_init(&frags_q);
 
@@ -121,8 +121,8 @@ static int nci_queue_tx_data_frags(struct nci_dev *ndev,
 		data += frag_len;
 		total_len -= frag_len;
 
-		nfc_dbg("frag_len %d, remaining total_len %d",
-			frag_len, total_len);
+		pr_debug("frag_len %d, remaining total_len %d\n",
+			 frag_len, total_len);
 	}
 
 	/* queue all fragments atomically */
@@ -151,7 +151,7 @@ int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb)
 {
 	int rc = 0;
 
-	nfc_dbg("entry, conn_id 0x%x, plen %d", conn_id, skb->len);
+	pr_debug("entry, conn_id 0x%x, plen %d\n", conn_id, skb->len);
 
 	/* check if the packet need to be fragmented */
 	if (skb->len <= ndev->max_data_pkt_payload_size) {
@@ -230,19 +230,19 @@ void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	__u8 pbf = nci_pbf(skb->data);
 
-	nfc_dbg("entry, len %d", skb->len);
+	pr_debug("entry, len %d\n", skb->len);
 
-	nfc_dbg("NCI RX: MT=data, PBF=%d, conn_id=%d, plen=%d",
-			nci_pbf(skb->data),
-			nci_conn_id(skb->data),
-			nci_plen(skb->data));
+	pr_debug("NCI RX: MT=data, PBF=%d, conn_id=%d, plen=%d\n",
+		 nci_pbf(skb->data),
+		 nci_conn_id(skb->data),
+		 nci_plen(skb->data));
 
 	/* strip the nci data header */
 	skb_pull(skb, NCI_DATA_HDR_SIZE);
 
 	if (ndev->target_active_prot == NFC_PROTO_MIFARE) {
 		/* frame I/F => remove the status byte */
-		nfc_dbg("NFC_PROTO_MIFARE => remove the status byte");
+		pr_debug("NFC_PROTO_MIFARE => remove the status byte\n");
 		skb_trim(skb, (skb->len - 1));
 	}
 
diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index c704350..f26edc0 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -45,16 +45,16 @@ static void nci_core_conn_credits_ntf_packet(struct nci_dev *ndev,
 	struct nci_core_conn_credit_ntf *ntf = (void *) skb->data;
 	int i;
 
-	nfc_dbg("entry, num_entries %d", ntf->num_entries);
+	pr_debug("entry, num_entries %d\n", ntf->num_entries);
 
 	if (ntf->num_entries > NCI_MAX_NUM_CONN)
 		ntf->num_entries = NCI_MAX_NUM_CONN;
 
 	/* update the credits */
 	for (i = 0; i < ntf->num_entries; i++) {
-		nfc_dbg("entry[%d]: conn_id %d, credits %d", i,
-			ntf->conn_entries[i].conn_id,
-			ntf->conn_entries[i].credits);
+		pr_debug("entry[%d]: conn_id %d, credits %d\n",
+			 i, ntf->conn_entries[i].conn_id,
+			 ntf->conn_entries[i].credits);
 
 		if (ntf->conn_entries[i].conn_id == NCI_STATIC_RF_CONN_ID) {
 			/* found static rf connection */
@@ -80,9 +80,8 @@ static __u8 *nci_extract_rf_params_nfca_passive_poll(struct nci_dev *ndev,
 
 	nfca_poll->nfcid1_len = *data++;
 
-	nfc_dbg("sens_res 0x%x, nfcid1_len %d",
-		nfca_poll->sens_res,
-		nfca_poll->nfcid1_len);
+	pr_debug("sens_res 0x%x, nfcid1_len %d\n",
+		 nfca_poll->sens_res, nfca_poll->nfcid1_len);
 
 	memcpy(nfca_poll->nfcid1, data, nfca_poll->nfcid1_len);
 	data += nfca_poll->nfcid1_len;
@@ -92,9 +91,9 @@ static __u8 *nci_extract_rf_params_nfca_passive_poll(struct nci_dev *ndev,
 	if (nfca_poll->sel_res_len != 0)
 		nfca_poll->sel_res = *data++;
 
-	nfc_dbg("sel_res_len %d, sel_res 0x%x",
-		nfca_poll->sel_res_len,
-		nfca_poll->sel_res);
+	pr_debug("sel_res_len %d, sel_res 0x%x\n",
+		 nfca_poll->sel_res_len,
+		 nfca_poll->sel_res);
 
 	return data;
 }
@@ -140,12 +139,12 @@ static void nci_target_found(struct nci_dev *ndev,
 	nfc_tgt.sel_res = ntf->rf_tech_specific_params.nfca_poll.sel_res;
 
 	if (!(nfc_tgt.supported_protocols & ndev->poll_prots)) {
-		nfc_dbg("the target found does not have the desired protocol");
+		pr_debug("the target found does not have the desired protocol\n");
 		return;
 	}
 
-	nfc_dbg("new target found,  supported_protocols 0x%x",
-		nfc_tgt.supported_protocols);
+	pr_debug("new target found,  supported_protocols 0x%x\n",
+		 nfc_tgt.supported_protocols);
 
 	ndev->target_available_prots = nfc_tgt.supported_protocols;
 
@@ -168,13 +167,13 @@ static void nci_rf_intf_activated_ntf_packet(struct nci_dev *ndev,
 	ntf.activation_rf_tech_and_mode = *data++;
 	ntf.rf_tech_specific_params_len = *data++;
 
-	nfc_dbg("rf_discovery_id %d", ntf.rf_discovery_id);
-	nfc_dbg("rf_interface_type 0x%x", ntf.rf_interface_type);
-	nfc_dbg("rf_protocol 0x%x", ntf.rf_protocol);
-	nfc_dbg("activation_rf_tech_and_mode 0x%x",
-		ntf.activation_rf_tech_and_mode);
-	nfc_dbg("rf_tech_specific_params_len %d",
-		ntf.rf_tech_specific_params_len);
+	pr_debug("rf_discovery_id %d\n", ntf.rf_discovery_id);
+	pr_debug("rf_interface_type 0x%x\n", ntf.rf_interface_type);
+	pr_debug("rf_protocol 0x%x\n", ntf.rf_protocol);
+	pr_debug("activation_rf_tech_and_mode 0x%x\n",
+		 ntf.activation_rf_tech_and_mode);
+	pr_debug("rf_tech_specific_params_len %d\n",
+		 ntf.rf_tech_specific_params_len);
 
 	if (ntf.rf_tech_specific_params_len > 0) {
 		switch (ntf.activation_rf_tech_and_mode) {
@@ -195,14 +194,14 @@ static void nci_rf_intf_activated_ntf_packet(struct nci_dev *ndev,
 	ntf.data_exch_rx_bit_rate = *data++;
 	ntf.activation_params_len = *data++;
 
-	nfc_dbg("data_exch_rf_tech_and_mode 0x%x",
-		ntf.data_exch_rf_tech_and_mode);
-	nfc_dbg("data_exch_tx_bit_rate 0x%x",
-		ntf.data_exch_tx_bit_rate);
-	nfc_dbg("data_exch_rx_bit_rate 0x%x",
-		ntf.data_exch_rx_bit_rate);
-	nfc_dbg("activation_params_len %d",
-		ntf.activation_params_len);
+	pr_debug("data_exch_rf_tech_and_mode 0x%x\n",
+		 ntf.data_exch_rf_tech_and_mode);
+	pr_debug("data_exch_tx_bit_rate 0x%x\n",
+		 ntf.data_exch_tx_bit_rate);
+	pr_debug("data_exch_rx_bit_rate 0x%x\n",
+		 ntf.data_exch_rx_bit_rate);
+	pr_debug("activation_params_len %d\n",
+		 ntf.activation_params_len);
 
 	if (ntf.activation_params_len > 0) {
 		switch (ntf.rf_interface_type) {
@@ -231,7 +230,7 @@ static void nci_rf_deactivate_ntf_packet(struct nci_dev *ndev,
 {
 	struct nci_rf_deactivate_ntf *ntf = (void *) skb->data;
 
-	nfc_dbg("entry, type 0x%x, reason 0x%x", ntf->type, ntf->reason);
+	pr_debug("entry, type 0x%x, reason 0x%x\n", ntf->type, ntf->reason);
 
 	clear_bit(NCI_POLL_ACTIVE, &ndev->flags);
 	ndev->target_active_prot = 0;
@@ -257,11 +256,11 @@ void nci_ntf_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	__u16 ntf_opcode = nci_opcode(skb->data);
 
-	nfc_dbg("NCI RX: MT=ntf, PBF=%d, GID=0x%x, OID=0x%x, plen=%d",
-			nci_pbf(skb->data),
-			nci_opcode_gid(ntf_opcode),
-			nci_opcode_oid(ntf_opcode),
-			nci_plen(skb->data));
+	pr_debug("NCI RX: MT=ntf, PBF=%d, GID=0x%x, OID=0x%x, plen=%d\n",
+		 nci_pbf(skb->data),
+		 nci_opcode_gid(ntf_opcode),
+		 nci_opcode_oid(ntf_opcode),
+		 nci_plen(skb->data));
 
 	/* strip the nci control header */
 	skb_pull(skb, NCI_CTRL_HDR_SIZE);
diff --git a/net/nfc/nci/rsp.c b/net/nfc/nci/rsp.c
index 6f51a28..f00c2ab 100644
--- a/net/nfc/nci/rsp.c
+++ b/net/nfc/nci/rsp.c
@@ -42,12 +42,12 @@ static void nci_core_reset_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	struct nci_core_reset_rsp *rsp = (void *) skb->data;
 
-	nfc_dbg("entry, status 0x%x", rsp->status);
+	pr_debug("entry, status 0x%x\n", rsp->status);
 
 	if (rsp->status == NCI_STATUS_OK) {
 		ndev->nci_ver = rsp->nci_ver;
-		nfc_dbg("nci_ver 0x%x, config_status 0x%x",
-			rsp->nci_ver, rsp->config_status);
+		pr_debug("nci_ver 0x%x, config_status 0x%x\n",
+			 rsp->nci_ver, rsp->config_status);
 	}
 
 	nci_req_complete(ndev, rsp->status);
@@ -58,7 +58,7 @@ static void nci_core_init_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 	struct nci_core_init_rsp_1 *rsp_1 = (void *) skb->data;
 	struct nci_core_init_rsp_2 *rsp_2;
 
-	nfc_dbg("entry, status 0x%x", rsp_1->status);
+	pr_debug("entry, status 0x%x\n", rsp_1->status);
 
 	if (rsp_1->status != NCI_STATUS_OK)
 		goto exit;
@@ -97,34 +97,34 @@ static void nci_core_init_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 
 	atomic_set(&ndev->credits_cnt, ndev->initial_num_credits);
 
-	nfc_dbg("nfcc_features 0x%x",
-		ndev->nfcc_features);
-	nfc_dbg("num_supported_rf_interfaces %d",
-		ndev->num_supported_rf_interfaces);
-	nfc_dbg("supported_rf_interfaces[0] 0x%x",
-		ndev->supported_rf_interfaces[0]);
-	nfc_dbg("supported_rf_interfaces[1] 0x%x",
-		ndev->supported_rf_interfaces[1]);
-	nfc_dbg("supported_rf_interfaces[2] 0x%x",
-		ndev->supported_rf_interfaces[2]);
-	nfc_dbg("supported_rf_interfaces[3] 0x%x",
-		ndev->supported_rf_interfaces[3]);
-	nfc_dbg("max_logical_connections %d",
-		ndev->max_logical_connections);
-	nfc_dbg("max_routing_table_size %d",
-		ndev->max_routing_table_size);
-	nfc_dbg("max_ctrl_pkt_payload_len %d",
-		ndev->max_ctrl_pkt_payload_len);
-	nfc_dbg("max_size_for_large_params %d",
-		ndev->max_size_for_large_params);
-	nfc_dbg("max_data_pkt_payload_size %d",
-		ndev->max_data_pkt_payload_size);
-	nfc_dbg("initial_num_credits %d",
-		ndev->initial_num_credits);
-	nfc_dbg("manufact_id 0x%x",
-		ndev->manufact_id);
-	nfc_dbg("manufact_specific_info 0x%x",
-		ndev->manufact_specific_info);
+	pr_debug("nfcc_features 0x%x\n",
+		 ndev->nfcc_features);
+	pr_debug("num_supported_rf_interfaces %d\n",
+		 ndev->num_supported_rf_interfaces);
+	pr_debug("supported_rf_interfaces[0] 0x%x\n",
+		 ndev->supported_rf_interfaces[0]);
+	pr_debug("supported_rf_interfaces[1] 0x%x\n",
+		 ndev->supported_rf_interfaces[1]);
+	pr_debug("supported_rf_interfaces[2] 0x%x\n",
+		 ndev->supported_rf_interfaces[2]);
+	pr_debug("supported_rf_interfaces[3] 0x%x\n",
+		 ndev->supported_rf_interfaces[3]);
+	pr_debug("max_logical_connections %d\n",
+		 ndev->max_logical_connections);
+	pr_debug("max_routing_table_size %d\n",
+		 ndev->max_routing_table_size);
+	pr_debug("max_ctrl_pkt_payload_len %d\n",
+		 ndev->max_ctrl_pkt_payload_len);
+	pr_debug("max_size_for_large_params %d\n",
+		 ndev->max_size_for_large_params);
+	pr_debug("max_data_pkt_payload_size %d\n",
+		 ndev->max_data_pkt_payload_size);
+	pr_debug("initial_num_credits %d\n",
+		 ndev->initial_num_credits);
+	pr_debug("manufact_id 0x%x\n",
+		 ndev->manufact_id);
+	pr_debug("manufact_specific_info 0x%x\n",
+		 ndev->manufact_specific_info);
 
 exit:
 	nci_req_complete(ndev, rsp_1->status);
@@ -135,7 +135,7 @@ static void nci_rf_disc_map_rsp_packet(struct nci_dev *ndev,
 {
 	__u8 status = skb->data[0];
 
-	nfc_dbg("entry, status 0x%x", status);
+	pr_debug("entry, status 0x%x\n", status);
 
 	nci_req_complete(ndev, status);
 }
@@ -144,7 +144,7 @@ static void nci_rf_disc_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	__u8 status = skb->data[0];
 
-	nfc_dbg("entry, status 0x%x", status);
+	pr_debug("entry, status 0x%x\n", status);
 
 	if (status == NCI_STATUS_OK)
 		set_bit(NCI_DISCOVERY, &ndev->flags);
@@ -157,7 +157,7 @@ static void nci_rf_deactivate_rsp_packet(struct nci_dev *ndev,
 {
 	__u8 status = skb->data[0];
 
-	nfc_dbg("entry, status 0x%x", status);
+	pr_debug("entry, status 0x%x\n", status);
 
 	clear_bit(NCI_DISCOVERY, &ndev->flags);
 
@@ -171,11 +171,11 @@ void nci_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 	/* we got a rsp, stop the cmd timer */
 	del_timer(&ndev->cmd_timer);
 
-	nfc_dbg("NCI RX: MT=rsp, PBF=%d, GID=0x%x, OID=0x%x, plen=%d",
-			nci_pbf(skb->data),
-			nci_opcode_gid(rsp_opcode),
-			nci_opcode_oid(rsp_opcode),
-			nci_plen(skb->data));
+	pr_debug("NCI RX: MT=rsp, PBF=%d, GID=0x%x, OID=0x%x, plen=%d\n",
+		 nci_pbf(skb->data),
+		 nci_opcode_gid(rsp_opcode),
+		 nci_opcode_oid(rsp_opcode),
+		 nci_plen(skb->data));
 
 	/* strip the nci control header */
 	skb_pull(skb, NCI_CTRL_HDR_SIZE);
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 03f8818..5aef1a5 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -21,6 +21,8 @@
  * 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <net/genetlink.h>
 #include <linux/nfc.h>
 #include <linux/slab.h>
@@ -51,7 +53,7 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 {
 	void *hdr;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	hdr = genlmsg_put(msg, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
 				&nfc_genl_family, flags, NFC_CMD_GET_TARGET);
@@ -105,7 +107,7 @@ static int nfc_genl_dump_targets(struct sk_buff *skb,
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 	int rc;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!dev) {
 		dev = __get_device_from_cb(cb);
@@ -139,7 +141,7 @@ static int nfc_genl_dump_targets_done(struct netlink_callback *cb)
 {
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (dev)
 		nfc_put_device(dev);
@@ -152,7 +154,7 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	dev->genl_data.poll_req_pid = 0;
 
@@ -183,7 +185,7 @@ int nfc_genl_device_added(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!msg)
@@ -216,7 +218,7 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!msg)
@@ -249,7 +251,7 @@ static int nfc_genl_send_device(struct sk_buff *msg, struct nfc_dev *dev,
 {
 	void *hdr;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	hdr = genlmsg_put(msg, pid, seq, &nfc_genl_family, flags,
 							NFC_CMD_GET_DEVICE);
@@ -277,7 +279,7 @@ static int nfc_genl_dump_devices(struct sk_buff *skb,
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 	bool first_call = false;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!iter) {
 		first_call = true;
@@ -319,7 +321,7 @@ static int nfc_genl_dump_devices_done(struct netlink_callback *cb)
 {
 	struct class_dev_iter *iter = (struct class_dev_iter *) cb->args[0];
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	nfc_device_iter_exit(iter);
 	kfree(iter);
@@ -334,7 +336,7 @@ static int nfc_genl_get_device(struct sk_buff *skb, struct genl_info *info)
 	u32 idx;
 	int rc = -ENOBUFS;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
@@ -373,7 +375,7 @@ static int nfc_genl_dev_up(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
@@ -396,7 +398,7 @@ static int nfc_genl_dev_down(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
@@ -420,7 +422,7 @@ static int nfc_genl_start_poll(struct sk_buff *skb, struct genl_info *info)
 	u32 idx;
 	u32 protocols;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX] ||
 		!info->attrs[NFC_ATTR_PROTOCOLS])
@@ -451,7 +453,7 @@ static int nfc_genl_stop_poll(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	nfc_dbg("entry");
+	pr_debug("entry\n");
 
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
@@ -524,7 +526,7 @@ static int nfc_genl_rcv_nl_event(struct notifier_block *this,
 	if (event != NETLINK_URELEASE || n->protocol != NETLINK_GENERIC)
 		goto out;
 
-	nfc_dbg("NETLINK_URELEASE event from id %d", n->pid);
+	pr_debug("NETLINK_URELEASE event from id %d\n", n->pid);
 
 	nfc_device_iter_init(&iter);
 	dev = nfc_device_iter_next(&iter);
diff --git a/net/nfc/rawsock.c b/net/nfc/rawsock.c
index feb235b..68ecf3f 100644
--- a/net/nfc/rawsock.c
+++ b/net/nfc/rawsock.c
@@ -31,7 +31,7 @@
 
 static void rawsock_write_queue_purge(struct sock *sk)
 {
-	nfc_dbg("sk=%p", sk);
+	pr_debug("sk=%p\n", sk);
 
 	spin_lock_bh(&sk->sk_write_queue.lock);
 	__skb_queue_purge(&sk->sk_write_queue);
@@ -41,7 +41,7 @@ static void rawsock_write_queue_purge(struct sock *sk)
 
 static void rawsock_report_error(struct sock *sk, int err)
 {
-	nfc_dbg("sk=%p err=%d", sk, err);
+	pr_debug("sk=%p err=%d\n", sk, err);
 
 	sk->sk_shutdown = SHUTDOWN_MASK;
 	sk->sk_err = -err;
@@ -54,7 +54,7 @@ static int rawsock_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 
-	nfc_dbg("sock=%p", sock);
+	pr_debug("sock=%p\n", sock);
 
 	sock_orphan(sk);
 	sock_put(sk);
@@ -70,14 +70,14 @@ static int rawsock_connect(struct socket *sock, struct sockaddr *_addr,
 	struct nfc_dev *dev;
 	int rc = 0;
 
-	nfc_dbg("sock=%p sk=%p flags=%d", sock, sk, flags);
+	pr_debug("sock=%p sk=%p flags=%d\n", sock, sk, flags);
 
 	if (!addr || len < sizeof(struct sockaddr_nfc) ||
 		addr->sa_family != AF_NFC)
 		return -EINVAL;
 
-	nfc_dbg("addr dev_idx=%u target_idx=%u protocol=%u", addr->dev_idx,
-					addr->target_idx, addr->nfc_protocol);
+	pr_debug("addr dev_idx=%u target_idx=%u protocol=%u\n",
+		 addr->dev_idx, addr->target_idx, addr->nfc_protocol);
 
 	lock_sock(sk);
 
@@ -138,7 +138,7 @@ static void rawsock_data_exchange_complete(void *context, struct sk_buff *skb,
 
 	BUG_ON(in_irq());
 
-	nfc_dbg("sk=%p err=%d", sk, err);
+	pr_debug("sk=%p err=%d\n", sk, err);
 
 	if (err)
 		goto error;
@@ -174,7 +174,7 @@ static void rawsock_tx_work(struct work_struct *work)
 	struct sk_buff *skb;
 	int rc;
 
-	nfc_dbg("sk=%p target_idx=%u", sk, target_idx);
+	pr_debug("sk=%p target_idx=%u\n", sk, target_idx);
 
 	if (sk->sk_shutdown & SEND_SHUTDOWN) {
 		rawsock_write_queue_purge(sk);
@@ -200,7 +200,7 @@ static int rawsock_sendmsg(struct kiocb *iocb, struct socket *sock,
 	struct sk_buff *skb;
 	int rc;
 
-	nfc_dbg("sock=%p sk=%p len=%zu", sock, sk, len);
+	pr_debug("sock=%p sk=%p len=%zu\n", sock, sk, len);
 
 	if (msg->msg_namelen)
 		return -EOPNOTSUPP;
@@ -241,7 +241,7 @@ static int rawsock_recvmsg(struct kiocb *iocb, struct socket *sock,
 	int copied;
 	int rc;
 
-	nfc_dbg("sock=%p sk=%p len=%zu flags=%d", sock, sk, len, flags);
+	pr_debug("sock=%p sk=%p len=%zu flags=%d\n", sock, sk, len, flags);
 
 	skb = skb_recv_datagram(sk, flags, noblock, &rc);
 	if (!skb)
@@ -285,7 +285,7 @@ static const struct proto_ops rawsock_ops = {
 
 static void rawsock_destruct(struct sock *sk)
 {
-	nfc_dbg("sk=%p", sk);
+	pr_debug("sk=%p\n", sk);
 
 	if (sk->sk_state == TCP_ESTABLISHED) {
 		nfc_deactivate_target(nfc_rawsock(sk)->dev,
@@ -306,7 +306,7 @@ static int rawsock_create(struct net *net, struct socket *sock,
 {
 	struct sock *sk;
 
-	nfc_dbg("sock=%p", sock);
+	pr_debug("sock=%p\n", sock);
 
 	if (sock->type != SOCK_SEQPACKET)
 		return -ESOCKTNOSUPPORT;
-- 
1.7.6.405.gc1be0
