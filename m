From: Joe Perches <joe@perches.com>
Subject: [PATCH 1/3] nfc: Replace nfc_dev_dbg with dev_dbg, remove function tracing
Date: Fri,  5 Apr 2013 12:27:37 -0700
Message-ID: <2cb852228bb418b927a0adebaeef612f24059b58.1365189658.git.joe@perches.com>
References: <1365180413.2075.5.camel@joe-AO722>
Cc: Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
	Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
	Samuel Ortiz <sameo@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, linux-nfc@lists.01.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365180413.2075.5.camel@joe-AO722>
In-Reply-To: <cover.1365189658.git.joe@perches.com>
References: <cover.1365189658.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the generic kernel function instead of a home-grown
one that does the same thing.  Remove empty function
tracing style uses as the kernel function tracer does
that too.

Add \n to uses not at the macro.  Don't add \n where
the nfc_dev_dbg macro mistakenly had them already.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/nfc/nfcwilink.c |  51 +++++++--------------
 drivers/nfc/pn533.c     | 118 ++++++++++++++++--------------------------------
 include/net/nfc/nfc.h   |   1 -
 3 files changed, 56 insertions(+), 114 deletions(-)

diff --git a/drivers/nfc/nfcwilink.c b/drivers/nfc/nfcwilink.c
index 3b731ac..b2f4040 100644
--- a/drivers/nfc/nfcwilink.c
+++ b/drivers/nfc/nfcwilink.c
@@ -146,8 +146,6 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 	unsigned long comp_ret;
 	int rc;
 
-	nfc_dev_dbg(&drv->pdev->dev, "get_bts_file_name entry");
-
 	skb = nfcwilink_skb_alloc(sizeof(struct nci_vs_nfcc_info_cmd),
 					GFP_KERNEL);
 	if (!skb) {
@@ -172,17 +170,16 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 
 	comp_ret = wait_for_completion_timeout(&drv->completed,
 				msecs_to_jiffies(NFCWILINK_CMD_TIMEOUT));
-	nfc_dev_dbg(&drv->pdev->dev, "wait_for_completion_timeout returned %ld",
-			comp_ret);
+	dev_dbg(&drv->pdev->dev, "wait_for_completion_timeout returned %ld\n",
+		comp_ret);
 	if (comp_ret == 0) {
-		nfc_dev_err(&drv->pdev->dev,
-				"timeout on wait_for_completion_timeout");
+		dev_err(&drv->pdev->dev,
+			"timeout on wait_for_completion_timeout\n");
 		return -ETIMEDOUT;
 	}
 
-	nfc_dev_dbg(&drv->pdev->dev, "nci_vs_nfcc_info_rsp: plen %d, status %d",
-			drv->nfcc_info.plen,
-			drv->nfcc_info.status);
+	dev_dbg(&drv->pdev->dev, "nci_vs_nfcc_info_rsp: plen %d, status %d\n",
+		drv->nfcc_info.plen, drv->nfcc_info.status);
 
 	if ((drv->nfcc_info.plen != 5) || (drv->nfcc_info.status != 0)) {
 		nfc_dev_err(&drv->pdev->dev,
@@ -209,8 +206,6 @@ static int nfcwilink_send_bts_cmd(struct nfcwilink *drv, __u8 *data, int len)
 	unsigned long comp_ret;
 	int rc;
 
-	nfc_dev_dbg(&drv->pdev->dev, "send_bts_cmd entry");
-
 	/* verify valid cmd for the NFC channel */
 	if ((len <= sizeof(struct nfcwilink_hdr)) ||
 		(len > BTS_FILE_CMD_MAX_LEN) ||
@@ -242,8 +237,8 @@ static int nfcwilink_send_bts_cmd(struct nfcwilink *drv, __u8 *data, int len)
 
 	comp_ret = wait_for_completion_timeout(&drv->completed,
 				msecs_to_jiffies(NFCWILINK_CMD_TIMEOUT));
-	nfc_dev_dbg(&drv->pdev->dev, "wait_for_completion_timeout returned %ld",
-			comp_ret);
+	dev_dbg(&drv->pdev->dev, "wait_for_completion_timeout returned %ld\n",
+		comp_ret);
 	if (comp_ret == 0) {
 		nfc_dev_err(&drv->pdev->dev,
 				"timeout on wait_for_completion_timeout");
@@ -261,8 +256,6 @@ static int nfcwilink_download_fw(struct nfcwilink *drv)
 	__u8 *ptr;
 	int len, rc;
 
-	nfc_dev_dbg(&drv->pdev->dev, "download_fw entry");
-
 	set_bit(NFCWILINK_FW_DOWNLOAD, &drv->flags);
 
 	rc = nfcwilink_get_bts_file_name(drv, file_name);
@@ -284,8 +277,8 @@ static int nfcwilink_download_fw(struct nfcwilink *drv)
 	ptr = (__u8 *)fw->data;
 
 	if ((len == 0) || (ptr == NULL)) {
-		nfc_dev_dbg(&drv->pdev->dev,
-				"request_firmware returned size %d", len);
+		dev_dbg(&drv->pdev->dev,
+			"request_firmware returned size %d\n", len);
 		goto release_fw;
 	}
 
@@ -306,8 +299,8 @@ static int nfcwilink_download_fw(struct nfcwilink *drv)
 		action_len =
 			__le16_to_cpu(((struct bts_file_action *)ptr)->len);
 
-		nfc_dev_dbg(&drv->pdev->dev, "bts_file_action type %d, len %d",
-				action_type, action_len);
+		dev_dbg(&drv->pdev->dev, "bts_file_action type %d, len %d\n",
+			action_type, action_len);
 
 		switch (action_type) {
 		case BTS_FILE_ACTION_TYPE_SEND_CMD:
@@ -337,8 +330,6 @@ static void nfcwilink_register_complete(void *priv_data, char data)
 {
 	struct nfcwilink *drv = priv_data;
 
-	nfc_dev_dbg(&drv->pdev->dev, "register_complete entry");
-
 	/* store ST registration status */
 	drv->st_register_cb_status = data;
 
@@ -360,7 +351,7 @@ static long nfcwilink_receive(void *priv_data, struct sk_buff *skb)
 		return -EFAULT;
 	}
 
-	nfc_dev_dbg(&drv->pdev->dev, "receive entry, len %d", skb->len);
+	dev_dbg(&drv->pdev->dev, "receive entry, len %d\n", skb->len);
 
 	/* strip the ST header
 	(apart for the chnl byte, which is not received in the hdr) */
@@ -402,8 +393,6 @@ static int nfcwilink_open(struct nci_dev *ndev)
 	unsigned long comp_ret;
 	int rc;
 
-	nfc_dev_dbg(&drv->pdev->dev, "open entry");
-
 	if (test_and_set_bit(NFCWILINK_RUNNING, &drv->flags)) {
 		rc = -EBUSY;
 		goto exit;
@@ -421,9 +410,9 @@ static int nfcwilink_open(struct nci_dev *ndev)
 			&drv->completed,
 			msecs_to_jiffies(NFCWILINK_REGISTER_TIMEOUT));
 
-			nfc_dev_dbg(&drv->pdev->dev,
-			"wait_for_completion_timeout returned %ld",
-			comp_ret);
+			dev_dbg(&drv->pdev->dev,
+				"wait_for_completion_timeout returned %ld\n",
+				comp_ret);
 
 			if (comp_ret == 0) {
 				/* timeout */
@@ -466,8 +455,6 @@ static int nfcwilink_close(struct nci_dev *ndev)
 	struct nfcwilink *drv = nci_get_drvdata(ndev);
 	int rc;
 
-	nfc_dev_dbg(&drv->pdev->dev, "close entry");
-
 	if (!test_and_clear_bit(NFCWILINK_RUNNING, &drv->flags))
 		return 0;
 
@@ -487,7 +474,7 @@ static int nfcwilink_send(struct sk_buff *skb)
 	struct nfcwilink_hdr hdr = {NFCWILINK_CHNL, NFCWILINK_OPCODE, 0x0000};
 	long len;
 
-	nfc_dev_dbg(&drv->pdev->dev, "send entry, len %d", skb->len);
+	dev_dbg(&drv->pdev->dev, "send entry, len %d\n", skb->len);
 
 	if (!test_bit(NFCWILINK_RUNNING, &drv->flags)) {
 		kfree_skb(skb);
@@ -524,8 +511,6 @@ static int nfcwilink_probe(struct platform_device *pdev)
 	int rc;
 	__u32 protocols;
 
-	nfc_dev_dbg(&pdev->dev, "probe entry");
-
 	drv = devm_kzalloc(&pdev->dev, sizeof(struct nfcwilink), GFP_KERNEL);
 	if (!drv) {
 		rc = -ENOMEM;
@@ -576,8 +561,6 @@ static int nfcwilink_remove(struct platform_device *pdev)
 	struct nfcwilink *drv = dev_get_drvdata(&pdev->dev);
 	struct nci_dev *ndev;
 
-	nfc_dev_dbg(&pdev->dev, "remove entry");
-
 	if (!drv)
 		return -EFAULT;
 
diff --git a/drivers/nfc/pn533.c b/drivers/nfc/pn533.c
index f0f6763..e2956a6 100644
--- a/drivers/nfc/pn533.c
+++ b/drivers/nfc/pn533.c
@@ -527,9 +527,9 @@ static void pn533_recv_response(struct urb *urb)
 		break; /* success */
 	case -ECONNRESET:
 	case -ENOENT:
-		nfc_dev_dbg(&dev->interface->dev,
-			    "The urb has been canceled (status %d)",
-			    urb->status);
+		dev_dbg(&dev->interface->dev,
+			"The urb has been canceled (status %d)\n",
+			urb->status);
 		dev->wq_in_error = urb->status;
 		goto sched_wq;
 	case -ESHUTDOWN:
@@ -542,7 +542,7 @@ static void pn533_recv_response(struct urb *urb)
 
 	in_frame = dev->in_urb->transfer_buffer;
 
-	nfc_dev_dbg(&dev->interface->dev, "Received a frame.");
+	dev_dbg(&dev->interface->dev, "Received a frame\n");
 	print_hex_dump(KERN_DEBUG, "PN533 RX: ", DUMP_PREFIX_NONE, 16, 1,
 		       in_frame, dev->ops->rx_frame_size(in_frame), false);
 
@@ -583,9 +583,9 @@ static void pn533_recv_ack(struct urb *urb)
 		break; /* success */
 	case -ECONNRESET:
 	case -ENOENT:
-		nfc_dev_dbg(&dev->interface->dev,
-			    "The urb has been stopped (status %d)",
-			    urb->status);
+		dev_dbg(&dev->interface->dev,
+			"The urb has been stopped (status %d)\n",
+			urb->status);
 		dev->wq_in_error = urb->status;
 		goto sched_wq;
 	case -ESHUTDOWN:
@@ -631,8 +631,6 @@ static int pn533_send_ack(struct pn533 *dev, gfp_t flags)
 	/* spec 7.1.1.3:  Preamble, SoPC (2), ACK Code (2), Postamble */
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	dev->out_urb->transfer_buffer = ack;
 	dev->out_urb->transfer_buffer_length = sizeof(ack);
 	rc = usb_submit_urb(dev->out_urb, flags);
@@ -739,7 +737,7 @@ static int __pn533_send_async(struct pn533 *dev, u8 cmd_code,
 	struct pn533_send_async_complete_arg *arg;
 	int rc = 0;
 
-	nfc_dev_dbg(&dev->interface->dev, "Sending command 0x%x", cmd_code);
+	dev_dbg(&dev->interface->dev, "Sending command 0x%x\n", cmd_code);
 
 	arg = kzalloc(sizeof(*arg), GFP_KERNEL);
 	if (!arg)
@@ -764,8 +762,8 @@ static int __pn533_send_async(struct pn533 *dev, u8 cmd_code,
 		goto unlock;
 	}
 
-	nfc_dev_dbg(&dev->interface->dev, "%s Queueing command 0x%x", __func__,
-		    cmd_code);
+	dev_dbg(&dev->interface->dev, "%s Queueing command 0x%x\n",
+		__func__, cmd_code);
 
 	cmd = kzalloc(sizeof(struct pn533_cmd), GFP_KERNEL);
 	if (!cmd) {
@@ -971,9 +969,9 @@ static void pn533_send_complete(struct urb *urb)
 		break; /* success */
 	case -ECONNRESET:
 	case -ENOENT:
-		nfc_dev_dbg(&dev->interface->dev,
-			    "The urb has been stopped (status %d)",
-			    urb->status);
+		dev_dbg(&dev->interface->dev,
+			"The urb has been stopped (status %d)\n",
+			urb->status);
 		break;
 	case -ESHUTDOWN:
 	default:
@@ -1235,8 +1233,8 @@ static int pn533_target_found(struct pn533 *dev, u8 tg, u8 *tgdata,
 	struct nfc_target nfc_tgt;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s - modulation=%d", __func__,
-		    dev->poll_mod_curr);
+	dev_dbg(&dev->interface->dev, "%s - modulation=%d\n",
+		__func__, dev->poll_mod_curr);
 
 	if (tg != 1)
 		return -EPROTO;
@@ -1267,14 +1265,14 @@ static int pn533_target_found(struct pn533 *dev, u8 tg, u8 *tgdata,
 		return rc;
 
 	if (!(nfc_tgt.supported_protocols & dev->poll_protocols)) {
-		nfc_dev_dbg(&dev->interface->dev,
-			    "The Tg found doesn't have the desired protocol");
+		dev_dbg(&dev->interface->dev,
+			"The Tg found doesn't have the desired protocol\n");
 		return -EAGAIN;
 	}
 
-	nfc_dev_dbg(&dev->interface->dev,
-		    "Target found - supported protocols: 0x%x",
-		    nfc_tgt.supported_protocols);
+	dev_dbg(&dev->interface->dev,
+		"Target found - supported protocols: 0x%x\n",
+		nfc_tgt.supported_protocols);
 
 	dev->tgt_available_prots = nfc_tgt.supported_protocols;
 
@@ -1331,8 +1329,6 @@ static int pn533_start_poll_complete(struct pn533 *dev, struct sk_buff *resp)
 	u8 nbtg, tg, *tgdata;
 	int rc, tgdata_len;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	nbtg = resp->data[0];
 	tg = resp->data[1];
 	tgdata = &resp->data[2];
@@ -1412,8 +1408,6 @@ static int pn533_tm_get_data_complete(struct pn533 *dev, void *arg,
 {
 	u8 status;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (IS_ERR(resp))
 		return PTR_ERR(resp);
 
@@ -1437,8 +1431,6 @@ static void pn533_wq_tg_get_data(struct work_struct *work)
 	struct sk_buff *skb;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	skb = pn533_alloc_skb(dev, 0);
 	if (!skb)
 		return;
@@ -1459,16 +1451,14 @@ static int pn533_init_target_complete(struct pn533 *dev, struct sk_buff *resp)
 	size_t gb_len;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (resp->len < ATR_REQ_GB_OFFSET + 1)
 		return -EINVAL;
 
 	mode = resp->data[0];
 	cmd = &resp->data[1];
 
-	nfc_dev_dbg(&dev->interface->dev, "Target mode 0x%x len %d\n",
-		    mode, resp->len);
+	dev_dbg(&dev->interface->dev, "Target mode 0x%x len %d\n",
+		mode, resp->len);
 
 	if ((mode & PN533_INIT_TARGET_RESP_FRAME_MASK) ==
 	    PN533_INIT_TARGET_RESP_ACTIVE)
@@ -1498,8 +1488,6 @@ static void pn533_listen_mode_timer(unsigned long data)
 {
 	struct pn533 *dev = (struct pn533 *)data;
 
-	nfc_dev_dbg(&dev->interface->dev, "Listen mode timeout");
-
 	/* An ack will cancel the last issued command (poll) */
 	pn533_send_ack(dev, GFP_ATOMIC);
 
@@ -1516,8 +1504,6 @@ static int pn533_poll_complete(struct pn533 *dev, void *arg,
 	struct pn533_poll_modulations *cur_mod;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (IS_ERR(resp)) {
 		rc = PTR_ERR(resp);
 
@@ -1587,8 +1573,8 @@ static int pn533_send_poll_frame(struct pn533 *dev)
 
 	mod = dev->poll_mod_active[dev->poll_mod_curr];
 
-	nfc_dev_dbg(&dev->interface->dev, "%s mod len %d\n",
-		    __func__, mod->len);
+	dev_dbg(&dev->interface->dev, "%s mod len %d\n",
+		__func__, mod->len);
 
 	if (mod->len == 0) {  /* Listen mode */
 		cmd_code = PN533_CMD_TG_INIT_AS_TARGET;
@@ -1621,9 +1607,9 @@ static void pn533_wq_poll(struct work_struct *work)
 
 	cur_mod = dev->poll_mod_active[dev->poll_mod_curr];
 
-	nfc_dev_dbg(&dev->interface->dev,
-		    "%s cancel_listen %d modulation len %d",
-		    __func__, dev->cancel_listen, cur_mod->len);
+	dev_dbg(&dev->interface->dev,
+		"%s cancel_listen %d modulation len %d\n",
+		__func__, dev->cancel_listen, cur_mod->len);
 
 	if (dev->cancel_listen == 1) {
 		dev->cancel_listen = 0;
@@ -1645,9 +1631,9 @@ static int pn533_start_poll(struct nfc_dev *nfc_dev,
 {
 	struct pn533 *dev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dev_dbg(&dev->interface->dev,
-		    "%s: im protocols 0x%x tm protocols 0x%x",
-		    __func__, im_protocols, tm_protocols);
+	dev_dbg(&dev->interface->dev,
+		"%s: im protocols 0x%x tm protocols 0x%x\n",
+		__func__, im_protocols, tm_protocols);
 
 	if (dev->tgt_active_prot) {
 		nfc_dev_err(&dev->interface->dev,
@@ -1679,13 +1665,11 @@ static void pn533_stop_poll(struct nfc_dev *nfc_dev)
 {
 	struct pn533 *dev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	del_timer(&dev->listen_timer);
 
 	if (!dev->poll_mod_count) {
-		nfc_dev_dbg(&dev->interface->dev,
-			    "Polling operation was not running");
+		dev_dbg(&dev->interface->dev,
+			"Polling operation was not running\n");
 		return;
 	}
 
@@ -1707,8 +1691,6 @@ static int pn533_activate_target_nfcdep(struct pn533 *dev)
 	struct sk_buff *skb;
 	struct sk_buff *resp;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	skb = pn533_alloc_skb(dev, sizeof(u8) * 2); /*TG + Next*/
 	if (!skb)
 		return -ENOMEM;
@@ -1741,12 +1723,12 @@ static int pn533_activate_target(struct nfc_dev *nfc_dev,
 	struct pn533 *dev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s - protocol=%u", __func__,
-		    protocol);
+	dev_dbg(&dev->interface->dev, "%s - protocol=%u\n",
+		__func__, protocol);
 
 	if (dev->poll_mod_count) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Cannot activate while polling");
+		dev_err(&dev->interface->dev,
+			"Cannot activate while polling\n");
 		return -EBUSY;
 	}
 
@@ -1794,8 +1776,6 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (!dev->tgt_active_prot) {
 		nfc_dev_err(&dev->interface->dev, "There is no active target");
 		return;
@@ -1857,7 +1837,7 @@ static int pn533_in_dep_link_up_complete(struct pn533 *dev, void *arg,
 	if (!dev->tgt_available_prots) {
 		struct nfc_target nfc_target;
 
-		nfc_dev_dbg(&dev->interface->dev, "Creating new target");
+		dev_dbg(&dev->interface->dev, "Creating new target\n");
 
 		nfc_target.supported_protocols = NFC_PROTO_NFC_DEP_MASK;
 		nfc_target.nfcid1_len = 10;
@@ -1910,8 +1890,6 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev, struct nfc_target *target,
 
 	u8 passive_data[PASSIVE_DATA_LEN] = {0x00, 0xff, 0xff, 0x00, 0x3};
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (dev->poll_mod_count) {
 		nfc_dev_err(&dev->interface->dev,
 			    "Cannot bring the DEP link up while polling");
@@ -1981,8 +1959,6 @@ static int pn533_dep_link_down(struct nfc_dev *nfc_dev)
 {
 	struct pn533 *dev = nfc_get_drvdata(nfc_dev);
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	pn533_poll_reset_mod_list(dev);
 
 	if (dev->tgt_mode || dev->tgt_active_prot) {
@@ -2008,8 +1984,6 @@ static struct sk_buff *pn533_build_response(struct pn533 *dev)
 	struct sk_buff *skb, *tmp, *t;
 	unsigned int skb_len = 0, tmp_len = 0;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (skb_queue_empty(&dev->resp_q))
 		return NULL;
 
@@ -2021,8 +1995,8 @@ static struct sk_buff *pn533_build_response(struct pn533 *dev)
 	skb_queue_walk_safe(&dev->resp_q, tmp, t)
 		skb_len += tmp->len;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s total length %d\n",
-		    __func__, skb_len);
+	dev_dbg(&dev->interface->dev, "%s total length %d\n",
+		__func__, skb_len);
 
 	skb = alloc_skb(skb_len, GFP_KERNEL);
 	if (skb == NULL)
@@ -2049,8 +2023,6 @@ static int pn533_data_exchange_complete(struct pn533 *dev, void *_arg,
 	int rc = 0;
 	u8 status, ret, mi;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (IS_ERR(resp)) {
 		rc = PTR_ERR(resp);
 		goto _error;
@@ -2103,8 +2075,6 @@ static int pn533_transceive(struct nfc_dev *nfc_dev,
 	struct pn533_data_exchange_arg *arg = NULL;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (skb->len > PN533_CMD_DATAEXCH_DATA_MAXLEN) {
 		/* TODO: Implement support to multi-part data exchange */
 		nfc_dev_err(&dev->interface->dev,
@@ -2166,8 +2136,6 @@ static int pn533_tm_send_complete(struct pn533 *dev, void *arg,
 {
 	u8 status;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (IS_ERR(resp))
 		return PTR_ERR(resp);
 
@@ -2193,8 +2161,6 @@ static int pn533_tm_send(struct nfc_dev *nfc_dev, struct sk_buff *skb)
 	struct pn533 *dev = nfc_get_drvdata(nfc_dev);
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	if (skb->len > PN533_CMD_DATAEXCH_DATA_MAXLEN) {
 		nfc_dev_err(&dev->interface->dev,
 			    "Data length greater than the max allowed: %d",
@@ -2217,8 +2183,6 @@ static void pn533_wq_mi_recv(struct work_struct *work)
 	struct sk_buff *skb;
 	int rc;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	skb = pn533_alloc_skb(dev, PN533_CMD_DATAEXCH_HEAD_LEN);
 	if (!skb)
 		goto error;
@@ -2268,8 +2232,6 @@ static int pn533_set_configuration(struct pn533 *dev, u8 cfgitem, u8 *cfgdata,
 
 	int skb_len;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	skb_len = sizeof(cfgitem) + cfgdata_len; /* cfgitem + cfgdata */
 
 	skb = pn533_alloc_skb(dev, skb_len);
@@ -2315,8 +2277,6 @@ static int pn533_fw_reset(struct pn533 *dev)
 	struct sk_buff *skb;
 	struct sk_buff *resp;
 
-	nfc_dev_dbg(&dev->interface->dev, "%s", __func__);
-
 	skb = pn533_alloc_skb(dev, sizeof(u8));
 	if (!skb)
 		return -ENOMEM;
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 87a6417..3448f09 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -30,7 +30,6 @@
 
 #define nfc_dev_info(dev, fmt, arg...) dev_info((dev), "NFC: " fmt "\n", ## arg)
 #define nfc_dev_err(dev, fmt, arg...) dev_err((dev), "NFC: " fmt "\n", ## arg)
-#define nfc_dev_dbg(dev, fmt, arg...) dev_dbg((dev), fmt "\n", ## arg)
 
 struct nfc_dev;
 
-- 
1.8.1.2.459.gbcd45b4.dirty
