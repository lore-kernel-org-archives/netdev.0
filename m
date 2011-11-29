From: Joe Perches <joe@perches.com>
Subject: [PATCH 4/4] nfc: Remove function tracer like entry messages
Date: Tue, 29 Nov 2011 11:37:35 -0800
Message-ID: <038f52f06c7c878e0e2b4965f3a64ac72cf5196d.1322595343.git.joe@perches.com>
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

Logging messages that mimic function tracer enter/exit
aren't necessary.  Just remove them.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/nfc/nci/core.c |   34 +++++++++-------------------------
 net/nfc/nci/data.c |    8 ++++----
 net/nfc/nci/ntf.c  |    2 +-
 net/nfc/nci/rsp.c  |   10 +++++-----
 net/nfc/netlink.c  |   28 ----------------------------
 5 files changed, 19 insertions(+), 63 deletions(-)

diff --git a/net/nfc/nci/core.c b/net/nfc/nci/core.c
index 3faceb0..37de28e 100644
--- a/net/nfc/nci/core.c
+++ b/net/nfc/nci/core.c
@@ -325,8 +325,6 @@ static void nci_cmd_timer(unsigned long arg)
 {
 	struct nci_dev *ndev = (void *) arg;
 
-	pr_debug("entry\n");
-
 	atomic_set(&ndev->cmd_cnt, 1);
 	queue_work(ndev->cmd_wq, &ndev->cmd_work);
 }
@@ -335,8 +333,6 @@ static int nci_dev_up(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	pr_debug("entry\n");
-
 	return nci_open_device(ndev);
 }
 
@@ -344,8 +340,6 @@ static int nci_dev_down(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	pr_debug("entry\n");
-
 	return nci_close_device(ndev);
 }
 
@@ -354,8 +348,6 @@ static int nci_start_poll(struct nfc_dev *nfc_dev, __u32 protocols)
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	pr_debug("entry\n");
-
 	if (test_bit(NCI_DISCOVERY, &ndev->flags)) {
 		pr_err("unable to start poll, since poll is already active\n");
 		return -EBUSY;
@@ -388,8 +380,6 @@ static void nci_stop_poll(struct nfc_dev *nfc_dev)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	pr_debug("entry\n");
-
 	if (!test_bit(NCI_DISCOVERY, &ndev->flags)) {
 		pr_err("unable to stop poll, since poll is not active\n");
 		return;
@@ -404,7 +394,7 @@ static int nci_activate_target(struct nfc_dev *nfc_dev, __u32 target_idx,
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	pr_debug("entry, target_idx %d, protocol 0x%x\n", target_idx, protocol);
+	pr_debug("target_idx %d, protocol 0x%x\n", target_idx, protocol);
 
 	if (!test_bit(NCI_POLL_ACTIVE, &ndev->flags)) {
 		pr_err("there is no available target to activate\n");
@@ -432,7 +422,7 @@ static void nci_deactivate_target(struct nfc_dev *nfc_dev, __u32 target_idx)
 {
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 
-	pr_debug("entry, target_idx %d\n", target_idx);
+	pr_debug("target_idx %d\n", target_idx);
 
 	if (!ndev->target_active_prot) {
 		pr_err("unable to deactivate target, no active target\n");
@@ -455,7 +445,7 @@ static int nci_data_exchange(struct nfc_dev *nfc_dev, __u32 target_idx,
 	struct nci_dev *ndev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	pr_debug("entry, target_idx %d, len %d\n", target_idx, skb->len);
+	pr_debug("target_idx %d, len %d\n", target_idx, skb->len);
 
 	if (!ndev->target_active_prot) {
 		pr_err("unable to exchange data, no active target\n");
@@ -501,7 +491,7 @@ struct nci_dev *nci_allocate_device(struct nci_ops *ops,
 {
 	struct nci_dev *ndev;
 
-	pr_debug("entry, supported_protocols 0x%x\n", supported_protocols);
+	pr_debug("supported_protocols 0x%x\n", supported_protocols);
 
 	if (!ops->open || !ops->close || !ops->send)
 		return NULL;
@@ -541,8 +531,6 @@ EXPORT_SYMBOL(nci_allocate_device);
  */
 void nci_free_device(struct nci_dev *ndev)
 {
-	pr_debug("entry\n");
-
 	nfc_free_device(ndev->nfc_dev);
 	kfree(ndev);
 }
@@ -559,8 +547,6 @@ int nci_register_device(struct nci_dev *ndev)
 	struct device *dev = &ndev->nfc_dev->dev;
 	char name[32];
 
-	pr_debug("entry\n");
-
 	rc = nfc_register_device(ndev->nfc_dev);
 	if (rc)
 		goto exit;
@@ -623,8 +609,6 @@ EXPORT_SYMBOL(nci_register_device);
  */
 void nci_unregister_device(struct nci_dev *ndev)
 {
-	pr_debug("entry\n");
-
 	nci_close_device(ndev);
 
 	destroy_workqueue(ndev->cmd_wq);
@@ -644,7 +628,7 @@ int nci_recv_frame(struct sk_buff *skb)
 {
 	struct nci_dev *ndev = (struct nci_dev *) skb->dev;
 
-	pr_debug("entry, len %d\n", skb->len);
+	pr_debug("len %d\n", skb->len);
 
 	if (!ndev || (!test_bit(NCI_UP, &ndev->flags)
 		&& !test_bit(NCI_INIT, &ndev->flags))) {
@@ -664,7 +648,7 @@ static int nci_send_frame(struct sk_buff *skb)
 {
 	struct nci_dev *ndev = (struct nci_dev *) skb->dev;
 
-	pr_debug("entry, len %d\n", skb->len);
+	pr_debug("len %d\n", skb->len);
 
 	if (!ndev) {
 		kfree_skb(skb);
@@ -683,7 +667,7 @@ int nci_send_cmd(struct nci_dev *ndev, __u16 opcode, __u8 plen, void *payload)
 	struct nci_ctrl_hdr *hdr;
 	struct sk_buff *skb;
 
-	pr_debug("entry, opcode 0x%x, plen %d\n", opcode, plen);
+	pr_debug("opcode 0x%x, plen %d\n", opcode, plen);
 
 	skb = nci_skb_alloc(ndev, (NCI_CTRL_HDR_SIZE + plen), GFP_KERNEL);
 	if (!skb) {
@@ -717,7 +701,7 @@ static void nci_tx_work(struct work_struct *work)
 	struct nci_dev *ndev = container_of(work, struct nci_dev, tx_work);
 	struct sk_buff *skb;
 
-	pr_debug("entry, credits_cnt %d\n", atomic_read(&ndev->credits_cnt));
+	pr_debug("credits_cnt %d\n", atomic_read(&ndev->credits_cnt));
 
 	/* Send queued tx data */
 	while (atomic_read(&ndev->credits_cnt)) {
@@ -776,7 +760,7 @@ static void nci_cmd_work(struct work_struct *work)
 	struct nci_dev *ndev = container_of(work, struct nci_dev, cmd_work);
 	struct sk_buff *skb;
 
-	pr_debug("entry, cmd_cnt %d\n", atomic_read(&ndev->cmd_cnt));
+	pr_debug("cmd_cnt %d\n", atomic_read(&ndev->cmd_cnt));
 
 	/* Send queued command */
 	if (atomic_read(&ndev->cmd_cnt)) {
diff --git a/net/nfc/nci/data.c b/net/nfc/nci/data.c
index 3c5db09..1e040fe 100644
--- a/net/nfc/nci/data.c
+++ b/net/nfc/nci/data.c
@@ -42,7 +42,7 @@ void nci_data_exchange_complete(struct nci_dev *ndev,
 	data_exchange_cb_t cb = ndev->data_exchange_cb;
 	void *cb_context = ndev->data_exchange_cb_context;
 
-	pr_debug("entry, len %d, err %d\n", skb ? skb->len : 0, err);
+	pr_debug("len %d, err %d\n", skb ? skb->len : 0, err);
 
 	if (cb) {
 		ndev->data_exchange_cb = NULL;
@@ -92,7 +92,7 @@ static int nci_queue_tx_data_frags(struct nci_dev *ndev,
 	int frag_len;
 	int rc = 0;
 
-	pr_debug("entry, conn_id 0x%x, total_len %d\n", conn_id, total_len);
+	pr_debug("conn_id 0x%x, total_len %d\n", conn_id, total_len);
 
 	__skb_queue_head_init(&frags_q);
 
@@ -151,7 +151,7 @@ int nci_send_data(struct nci_dev *ndev, __u8 conn_id, struct sk_buff *skb)
 {
 	int rc = 0;
 
-	pr_debug("entry, conn_id 0x%x, plen %d\n", conn_id, skb->len);
+	pr_debug("conn_id 0x%x, plen %d\n", conn_id, skb->len);
 
 	/* check if the packet need to be fragmented */
 	if (skb->len <= ndev->max_data_pkt_payload_size) {
@@ -230,7 +230,7 @@ void nci_rx_data_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	__u8 pbf = nci_pbf(skb->data);
 
-	pr_debug("entry, len %d\n", skb->len);
+	pr_debug("len %d\n", skb->len);
 
 	pr_debug("NCI RX: MT=data, PBF=%d, conn_id=%d, plen=%d\n",
 		 nci_pbf(skb->data),
diff --git a/net/nfc/nci/ntf.c b/net/nfc/nci/ntf.c
index f26edc0..c36bd4a0 100644
--- a/net/nfc/nci/ntf.c
+++ b/net/nfc/nci/ntf.c
@@ -45,7 +45,7 @@ static void nci_core_conn_credits_ntf_packet(struct nci_dev *ndev,
 	struct nci_core_conn_credit_ntf *ntf = (void *) skb->data;
 	int i;
 
-	pr_debug("entry, num_entries %d\n", ntf->num_entries);
+	pr_debug("num_entries %d\n", ntf->num_entries);
 
 	if (ntf->num_entries > NCI_MAX_NUM_CONN)
 		ntf->num_entries = NCI_MAX_NUM_CONN;
diff --git a/net/nfc/nci/rsp.c b/net/nfc/nci/rsp.c
index f00c2ab..ca611c5 100644
--- a/net/nfc/nci/rsp.c
+++ b/net/nfc/nci/rsp.c
@@ -42,7 +42,7 @@ static void nci_core_reset_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	struct nci_core_reset_rsp *rsp = (void *) skb->data;
 
-	pr_debug("entry, status 0x%x\n", rsp->status);
+	pr_debug("status 0x%x\n", rsp->status);
 
 	if (rsp->status == NCI_STATUS_OK) {
 		ndev->nci_ver = rsp->nci_ver;
@@ -58,7 +58,7 @@ static void nci_core_init_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 	struct nci_core_init_rsp_1 *rsp_1 = (void *) skb->data;
 	struct nci_core_init_rsp_2 *rsp_2;
 
-	pr_debug("entry, status 0x%x\n", rsp_1->status);
+	pr_debug("status 0x%x\n", rsp_1->status);
 
 	if (rsp_1->status != NCI_STATUS_OK)
 		goto exit;
@@ -135,7 +135,7 @@ static void nci_rf_disc_map_rsp_packet(struct nci_dev *ndev,
 {
 	__u8 status = skb->data[0];
 
-	pr_debug("entry, status 0x%x\n", status);
+	pr_debug("status 0x%x\n", status);
 
 	nci_req_complete(ndev, status);
 }
@@ -144,7 +144,7 @@ static void nci_rf_disc_rsp_packet(struct nci_dev *ndev, struct sk_buff *skb)
 {
 	__u8 status = skb->data[0];
 
-	pr_debug("entry, status 0x%x\n", status);
+	pr_debug("status 0x%x\n", status);
 
 	if (status == NCI_STATUS_OK)
 		set_bit(NCI_DISCOVERY, &ndev->flags);
@@ -157,7 +157,7 @@ static void nci_rf_deactivate_rsp_packet(struct nci_dev *ndev,
 {
 	__u8 status = skb->data[0];
 
-	pr_debug("entry, status 0x%x\n", status);
+	pr_debug("status 0x%x\n", status);
 
 	clear_bit(NCI_DISCOVERY, &ndev->flags);
 
diff --git a/net/nfc/netlink.c b/net/nfc/netlink.c
index 5aef1a5..c10e9b8 100644
--- a/net/nfc/netlink.c
+++ b/net/nfc/netlink.c
@@ -53,8 +53,6 @@ static int nfc_genl_send_target(struct sk_buff *msg, struct nfc_target *target,
 {
 	void *hdr;
 
-	pr_debug("entry\n");
-
 	hdr = genlmsg_put(msg, NETLINK_CB(cb->skb).pid, cb->nlh->nlmsg_seq,
 				&nfc_genl_family, flags, NFC_CMD_GET_TARGET);
 	if (!hdr)
@@ -107,8 +105,6 @@ static int nfc_genl_dump_targets(struct sk_buff *skb,
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 	int rc;
 
-	pr_debug("entry\n");
-
 	if (!dev) {
 		dev = __get_device_from_cb(cb);
 		if (IS_ERR(dev))
@@ -141,8 +137,6 @@ static int nfc_genl_dump_targets_done(struct netlink_callback *cb)
 {
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 
-	pr_debug("entry\n");
-
 	if (dev)
 		nfc_put_device(dev);
 
@@ -154,8 +148,6 @@ int nfc_genl_targets_found(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	pr_debug("entry\n");
-
 	dev->genl_data.poll_req_pid = 0;
 
 	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
@@ -185,8 +177,6 @@ int nfc_genl_device_added(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	pr_debug("entry\n");
-
 	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
@@ -218,8 +208,6 @@ int nfc_genl_device_removed(struct nfc_dev *dev)
 	struct sk_buff *msg;
 	void *hdr;
 
-	pr_debug("entry\n");
-
 	msg = nlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
 	if (!msg)
 		return -ENOMEM;
@@ -251,8 +239,6 @@ static int nfc_genl_send_device(struct sk_buff *msg, struct nfc_dev *dev,
 {
 	void *hdr;
 
-	pr_debug("entry\n");
-
 	hdr = genlmsg_put(msg, pid, seq, &nfc_genl_family, flags,
 							NFC_CMD_GET_DEVICE);
 	if (!hdr)
@@ -279,8 +265,6 @@ static int nfc_genl_dump_devices(struct sk_buff *skb,
 	struct nfc_dev *dev = (struct nfc_dev *) cb->args[1];
 	bool first_call = false;
 
-	pr_debug("entry\n");
-
 	if (!iter) {
 		first_call = true;
 		iter = kmalloc(sizeof(struct class_dev_iter), GFP_KERNEL);
@@ -321,8 +305,6 @@ static int nfc_genl_dump_devices_done(struct netlink_callback *cb)
 {
 	struct class_dev_iter *iter = (struct class_dev_iter *) cb->args[0];
 
-	pr_debug("entry\n");
-
 	nfc_device_iter_exit(iter);
 	kfree(iter);
 
@@ -336,8 +318,6 @@ static int nfc_genl_get_device(struct sk_buff *skb, struct genl_info *info)
 	u32 idx;
 	int rc = -ENOBUFS;
 
-	pr_debug("entry\n");
-
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
 
@@ -375,8 +355,6 @@ static int nfc_genl_dev_up(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	pr_debug("entry\n");
-
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
 
@@ -398,8 +376,6 @@ static int nfc_genl_dev_down(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	pr_debug("entry\n");
-
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
 
@@ -422,8 +398,6 @@ static int nfc_genl_start_poll(struct sk_buff *skb, struct genl_info *info)
 	u32 idx;
 	u32 protocols;
 
-	pr_debug("entry\n");
-
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX] ||
 		!info->attrs[NFC_ATTR_PROTOCOLS])
 		return -EINVAL;
@@ -453,8 +427,6 @@ static int nfc_genl_stop_poll(struct sk_buff *skb, struct genl_info *info)
 	int rc;
 	u32 idx;
 
-	pr_debug("entry\n");
-
 	if (!info->attrs[NFC_ATTR_DEVICE_INDEX])
 		return -EINVAL;
 
-- 
1.7.6.405.gc1be0
