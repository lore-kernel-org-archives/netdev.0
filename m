From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 2/3] nfc: Convert nfc_dev_info and nfc_dev_err to nfc_<level>
Date: Fri,  5 Apr 2013 12:27:38 -0700
Message-ID: <a041125c705407bbbfc5a58dc34da2bf652ffe6d.1365189658.git.joe@perches.com>
References: <1365180413.2075.5.camel@joe-AO722>
Cc: Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1365180413.2075.5.camel@joe-AO722>
In-Reply-To: <cover.1365189658.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
References: <cover.1365189658.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Use a more standard kernel style macro logging name.

Standardize the spacing of the "NFC: " prefix.
Add \n to uses, remove from macro.
Fix the defective uses that already had a \n.

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/nfc/nfcwilink.c |  44 +++++++-------
 drivers/nfc/pn533.c     | 156 ++++++++++++++++++++++++------------------------
 include/net/nfc/nfc.h   |   4 +-
 3 files changed, 100 insertions(+), 104 deletions(-)

diff --git a/drivers/nfc/nfcwilink.c b/drivers/nfc/nfcwilink.c
index b2f4040..f58b390 100644
--- a/drivers/nfc/nfcwilink.c
+++ b/drivers/nfc/nfcwilink.c
@@ -149,8 +149,8 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 	skb = nfcwilink_skb_alloc(sizeof(struct nci_vs_nfcc_info_cmd),
 					GFP_KERNEL);
 	if (!skb) {
-		nfc_dev_err(&drv->pdev->dev,
-				"no memory for nci_vs_nfcc_info_cmd");
+		nfc_err(&drv->pdev->dev,
+			"no memory for nci_vs_nfcc_info_cmd\n");
 		return -ENOMEM;
 	}
 
@@ -182,8 +182,7 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 		drv->nfcc_info.plen, drv->nfcc_info.status);
 
 	if ((drv->nfcc_info.plen != 5) || (drv->nfcc_info.status != 0)) {
-		nfc_dev_err(&drv->pdev->dev,
-				"invalid nci_vs_nfcc_info_rsp");
+		nfc_err(&drv->pdev->dev, "invalid nci_vs_nfcc_info_rsp\n");
 		return -EINVAL;
 	}
 
@@ -194,7 +193,7 @@ static int nfcwilink_get_bts_file_name(struct nfcwilink *drv, char *file_name)
 			drv->nfcc_info.sw_ver_z,
 			drv->nfcc_info.patch_id);
 
-	nfc_dev_info(&drv->pdev->dev, "nfcwilink FW file name: %s", file_name);
+	nfc_info(&drv->pdev->dev, "nfcwilink FW file name: %s\n", file_name);
 
 	return 0;
 }
@@ -211,8 +210,8 @@ static int nfcwilink_send_bts_cmd(struct nfcwilink *drv, __u8 *data, int len)
 		(len > BTS_FILE_CMD_MAX_LEN) ||
 		(hdr->chnl != NFCWILINK_CHNL) ||
 		(hdr->opcode != NFCWILINK_OPCODE)) {
-		nfc_dev_err(&drv->pdev->dev,
-			"ignoring invalid bts cmd, len %d, chnl %d, opcode %d",
+		nfc_err(&drv->pdev->dev,
+			"ignoring invalid bts cmd, len %d, chnl %d, opcode %d\n",
 			len, hdr->chnl, hdr->opcode);
 		return 0;
 	}
@@ -223,7 +222,7 @@ static int nfcwilink_send_bts_cmd(struct nfcwilink *drv, __u8 *data, int len)
 
 	skb = nfcwilink_skb_alloc(len, GFP_KERNEL);
 	if (!skb) {
-		nfc_dev_err(&drv->pdev->dev, "no memory for bts cmd");
+		nfc_err(&drv->pdev->dev, "no memory for bts cmd\n");
 		return -ENOMEM;
 	}
 
@@ -240,8 +239,8 @@ static int nfcwilink_send_bts_cmd(struct nfcwilink *drv, __u8 *data, int len)
 	dev_dbg(&drv->pdev->dev, "wait_for_completion_timeout returned %ld\n",
 		comp_ret);
 	if (comp_ret == 0) {
-		nfc_dev_err(&drv->pdev->dev,
-				"timeout on wait_for_completion_timeout");
+		nfc_err(&drv->pdev->dev,
+			"timeout on wait_for_completion_timeout\n");
 		return -ETIMEDOUT;
 	}
 
@@ -264,7 +263,7 @@ static int nfcwilink_download_fw(struct nfcwilink *drv)
 
 	rc = request_firmware(&fw, file_name, &drv->pdev->dev);
 	if (rc) {
-		nfc_dev_err(&drv->pdev->dev, "request_firmware failed %d", rc);
+		nfc_err(&drv->pdev->dev, "request_firmware failed %d\n", rc);
 
 		/* if the file is not found, don't exit with failure */
 		if (rc == -ENOENT)
@@ -284,7 +283,7 @@ static int nfcwilink_download_fw(struct nfcwilink *drv)
 
 	if (__le32_to_cpu(((struct bts_file_hdr *)ptr)->magic) !=
 			BTS_FILE_HDR_MAGIC) {
-		nfc_dev_err(&drv->pdev->dev, "wrong bts magic number");
+		nfc_err(&drv->pdev->dev, "wrong bts magic number\n");
 		rc = -EINVAL;
 		goto release_fw;
 	}
@@ -367,7 +366,7 @@ static long nfcwilink_receive(void *priv_data, struct sk_buff *skb)
 	/* Forward skb to NCI core layer */
 	rc = nci_recv_frame(skb);
 	if (rc < 0) {
-		nfc_dev_err(&drv->pdev->dev, "nci_recv_frame failed %d", rc);
+		nfc_err(&drv->pdev->dev, "nci_recv_frame failed %d\n", rc);
 		return rc;
 	}
 
@@ -420,13 +419,12 @@ static int nfcwilink_open(struct nci_dev *ndev)
 				goto clear_exit;
 			} else if (drv->st_register_cb_status != 0) {
 				rc = drv->st_register_cb_status;
-				nfc_dev_err(&drv->pdev->dev,
-				"st_register_cb failed %d", rc);
+				nfc_err(&drv->pdev->dev,
+					"st_register_cb failed %d\n", rc);
 				goto clear_exit;
 			}
 		} else {
-			nfc_dev_err(&drv->pdev->dev,
-				"st_register failed %d", rc);
+			nfc_err(&drv->pdev->dev, "st_register failed %d\n", rc);
 			goto clear_exit;
 		}
 	}
@@ -436,8 +434,8 @@ static int nfcwilink_open(struct nci_dev *ndev)
 	drv->st_write = nfcwilink_proto.write;
 
 	if (nfcwilink_download_fw(drv)) {
-		nfc_dev_err(&drv->pdev->dev, "nfcwilink_download_fw failed %d",
-				rc);
+		nfc_err(&drv->pdev->dev, "nfcwilink_download_fw failed %d\n",
+			rc);
 		/* open should succeed, even if the FW download failed */
 	}
 
@@ -460,7 +458,7 @@ static int nfcwilink_close(struct nci_dev *ndev)
 
 	rc = st_unregister(&nfcwilink_proto);
 	if (rc)
-		nfc_dev_err(&drv->pdev->dev, "st_unregister failed %d", rc);
+		nfc_err(&drv->pdev->dev, "st_unregister failed %d\n", rc);
 
 	drv->st_write = NULL;
 
@@ -492,7 +490,7 @@ static int nfcwilink_send(struct sk_buff *skb)
 	len = drv->st_write(skb);
 	if (len < 0) {
 		kfree_skb(skb);
-		nfc_dev_err(&drv->pdev->dev, "st_write failed %ld", len);
+		nfc_err(&drv->pdev->dev, "st_write failed %ld\n", len);
 		return -EFAULT;
 	}
 
@@ -531,7 +529,7 @@ static int nfcwilink_probe(struct platform_device *pdev)
 					NFCWILINK_HDR_LEN,
 					0);
 	if (!drv->ndev) {
-		nfc_dev_err(&pdev->dev, "nci_allocate_device failed");
+		nfc_err(&pdev->dev, "nci_allocate_device failed\n");
 		rc = -ENOMEM;
 		goto exit;
 	}
@@ -541,7 +539,7 @@ static int nfcwilink_probe(struct platform_device *pdev)
 
 	rc = nci_register_device(drv->ndev);
 	if (rc < 0) {
-		nfc_dev_err(&pdev->dev, "nci_register_device failed %d", rc);
+		nfc_err(&pdev->dev, "nci_register_device failed %d\n", rc);
 		goto free_dev_exit;
 	}
 
diff --git a/drivers/nfc/pn533.c b/drivers/nfc/pn533.c
index e2956a6..714b4ec 100644
--- a/drivers/nfc/pn533.c
+++ b/drivers/nfc/pn533.c
@@ -534,8 +534,8 @@ static void pn533_recv_response(struct urb *urb)
 		goto sched_wq;
 	case -ESHUTDOWN:
 	default:
-		nfc_dev_err(&dev->interface->dev,
-			    "Urb failure (status %d)", urb->status);
+		nfc_err(&dev->interface->dev, "Urb failure (status %d)\n",
+			urb->status);
 		dev->wq_in_error = urb->status;
 		goto sched_wq;
 	}
@@ -547,14 +547,14 @@ static void pn533_recv_response(struct urb *urb)
 		       in_frame, dev->ops->rx_frame_size(in_frame), false);
 
 	if (!dev->ops->rx_is_frame_valid(in_frame)) {
-		nfc_dev_err(&dev->interface->dev, "Received an invalid frame");
+		nfc_err(&dev->interface->dev, "Received an invalid frame\n");
 		dev->wq_in_error = -EIO;
 		goto sched_wq;
 	}
 
 	if (!pn533_rx_frame_is_cmd_response(dev, in_frame)) {
-		nfc_dev_err(&dev->interface->dev,
-			    "It it not the response to the last command");
+		nfc_err(&dev->interface->dev,
+			"It it not the response to the last command\n");
 		dev->wq_in_error = -EIO;
 		goto sched_wq;
 	}
@@ -590,8 +590,8 @@ static void pn533_recv_ack(struct urb *urb)
 		goto sched_wq;
 	case -ESHUTDOWN:
 	default:
-		nfc_dev_err(&dev->interface->dev,
-			    "Urb failure (status %d)", urb->status);
+		nfc_err(&dev->interface->dev, "Urb failure (status %d)\n",
+			urb->status);
 		dev->wq_in_error = urb->status;
 		goto sched_wq;
 	}
@@ -599,15 +599,15 @@ static void pn533_recv_ack(struct urb *urb)
 	in_frame = dev->in_urb->transfer_buffer;
 
 	if (!pn533_rx_frame_is_ack(in_frame)) {
-		nfc_dev_err(&dev->interface->dev, "Received an invalid ack");
+		nfc_err(&dev->interface->dev, "Received an invalid ack\n");
 		dev->wq_in_error = -EIO;
 		goto sched_wq;
 	}
 
 	rc = pn533_submit_urb_for_response(dev, GFP_ATOMIC);
 	if (rc) {
-		nfc_dev_err(&dev->interface->dev,
-			    "usb_submit_urb failed with result %d", rc);
+		nfc_err(&dev->interface->dev,
+			"usb_submit_urb failed with result %d\n", rc);
 		dev->wq_in_error = rc;
 		goto sched_wq;
 	}
@@ -975,8 +975,8 @@ static void pn533_send_complete(struct urb *urb)
 		break;
 	case -ESHUTDOWN:
 	default:
-		nfc_dev_err(&dev->interface->dev,
-			    "Urb failure (status %d)", urb->status);
+		nfc_err(&dev->interface->dev, "Urb failure (status %d)\n",
+			urb->status);
 	}
 }
 
@@ -1256,8 +1256,8 @@ static int pn533_target_found(struct pn533 *dev, u8 tg, u8 *tgdata,
 		rc = pn533_target_found_type_b(&nfc_tgt, tgdata, tgdata_len);
 		break;
 	default:
-		nfc_dev_err(&dev->interface->dev,
-			    "Unknown current poll modulation");
+		nfc_err(&dev->interface->dev,
+			"Unknown current poll modulation\n");
 		return -EPROTO;
 	}
 
@@ -1473,8 +1473,8 @@ static int pn533_init_target_complete(struct pn533 *dev, struct sk_buff *resp)
 	rc = nfc_tm_activated(dev->nfc_dev, NFC_PROTO_NFC_DEP_MASK,
 			      comm_mode, gb, gb_len);
 	if (rc < 0) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Error when signaling target activation");
+		nfc_err(&dev->interface->dev,
+			"Error when signaling target activation\n");
 		return rc;
 	}
 
@@ -1507,8 +1507,8 @@ static int pn533_poll_complete(struct pn533 *dev, void *arg,
 	if (IS_ERR(resp)) {
 		rc = PTR_ERR(resp);
 
-		nfc_dev_err(&dev->interface->dev, "%s  Poll complete error %d",
-			    __func__, rc);
+		nfc_err(&dev->interface->dev, "%s  Poll complete error %d\n",
+			__func__, rc);
 
 		if (rc == -ENOENT) {
 			if (dev->poll_mod_count != 0)
@@ -1516,8 +1516,8 @@ static int pn533_poll_complete(struct pn533 *dev, void *arg,
 			else
 				goto stop_poll;
 		} else if (rc < 0) {
-			nfc_dev_err(&dev->interface->dev,
-				    "Error %d when running poll", rc);
+			nfc_err(&dev->interface->dev,
+				"Error %d when running poll\n", rc);
 			goto stop_poll;
 		}
 	}
@@ -1543,7 +1543,7 @@ done:
 	return rc;
 
 stop_poll:
-	nfc_dev_err(&dev->interface->dev, "Polling operation has been stopped");
+	nfc_err(&dev->interface->dev, "Polling operation has been stopped\n");
 
 	pn533_poll_reset_mod_list(dev);
 	dev->poll_protocols = 0;
@@ -1585,7 +1585,7 @@ static int pn533_send_poll_frame(struct pn533 *dev)
 	}
 
 	if (!skb) {
-		nfc_dev_err(&dev->interface->dev, "Failed to allocate skb.");
+		nfc_err(&dev->interface->dev, "Failed to allocate skb\n");
 		return -ENOMEM;
 	}
 
@@ -1593,7 +1593,7 @@ static int pn533_send_poll_frame(struct pn533 *dev)
 				  NULL);
 	if (rc < 0) {
 		dev_kfree_skb(skb);
-		nfc_dev_err(&dev->interface->dev, "Polling loop error %d", rc);
+		nfc_err(&dev->interface->dev, "Polling loop error %d\n", rc);
 	}
 
 	return rc;
@@ -1636,14 +1636,14 @@ static int pn533_start_poll(struct nfc_dev *nfc_dev,
 		__func__, im_protocols, tm_protocols);
 
 	if (dev->tgt_active_prot) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Cannot poll with a target already activated");
+		nfc_err(&dev->interface->dev,
+			"Cannot poll with a target already activated\n");
 		return -EBUSY;
 	}
 
 	if (dev->tgt_mode) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Cannot poll while already being activated");
+		nfc_err(&dev->interface->dev,
+			"Cannot poll while already being activated\n");
 		return -EBUSY;
 	}
 
@@ -1727,35 +1727,35 @@ static int pn533_activate_target(struct nfc_dev *nfc_dev,
 		__func__, protocol);
 
 	if (dev->poll_mod_count) {
-		dev_err(&dev->interface->dev,
+		nfc_err(&dev->interface->dev,
 			"Cannot activate while polling\n");
 		return -EBUSY;
 	}
 
 	if (dev->tgt_active_prot) {
-		nfc_dev_err(&dev->interface->dev,
-			    "There is already an active target");
+		nfc_err(&dev->interface->dev,
+			"There is already an active target\n");
 		return -EBUSY;
 	}
 
 	if (!dev->tgt_available_prots) {
-		nfc_dev_err(&dev->interface->dev,
-			    "There is no available target to activate");
+		nfc_err(&dev->interface->dev,
+			"There is no available target to activate\n");
 		return -EINVAL;
 	}
 
 	if (!(dev->tgt_available_prots & (1 << protocol))) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Target doesn't support requested proto %u",
-			    protocol);
+		nfc_err(&dev->interface->dev,
+			"Target doesn't support requested proto %u\n",
+			protocol);
 		return -EINVAL;
 	}
 
 	if (protocol == NFC_PROTO_NFC_DEP) {
 		rc = pn533_activate_target_nfcdep(dev);
 		if (rc) {
-			nfc_dev_err(&dev->interface->dev,
-				    "Activating target with DEP failed %d", rc);
+			nfc_err(&dev->interface->dev,
+				"Activating target with DEP failed %d\n", rc);
 			return rc;
 		}
 	}
@@ -1777,7 +1777,7 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 	int rc;
 
 	if (!dev->tgt_active_prot) {
-		nfc_dev_err(&dev->interface->dev, "There is no active target");
+		nfc_err(&dev->interface->dev, "There is no active target\n");
 		return;
 	}
 
@@ -1796,8 +1796,8 @@ static void pn533_deactivate_target(struct nfc_dev *nfc_dev,
 
 	rc = resp->data[0] & PN533_CMD_RET_MASK;
 	if (rc != PN533_CMD_RET_SUCCESS)
-		nfc_dev_err(&dev->interface->dev,
-			    "Error 0x%x when releasing the target", rc);
+		nfc_err(&dev->interface->dev,
+			"Error 0x%x when releasing the target\n", rc);
 
 	dev_kfree_skb(resp);
 	return;
@@ -1819,8 +1819,8 @@ static int pn533_in_dep_link_up_complete(struct pn533 *dev, void *arg,
 
 	if (dev->tgt_available_prots &&
 	    !(dev->tgt_available_prots & (1 << NFC_PROTO_NFC_DEP))) {
-		nfc_dev_err(&dev->interface->dev,
-			    "The target does not support DEP");
+		nfc_err(&dev->interface->dev,
+			"The target does not support DEP\n");
 		rc =  -EINVAL;
 		goto error;
 	}
@@ -1829,8 +1829,8 @@ static int pn533_in_dep_link_up_complete(struct pn533 *dev, void *arg,
 
 	rc = rsp->status & PN533_CMD_RET_MASK;
 	if (rc != PN533_CMD_RET_SUCCESS) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Bringing DEP link up failed %d", rc);
+		nfc_err(&dev->interface->dev,
+			"Bringing DEP link up failed %d\n", rc);
 		goto error;
 	}
 
@@ -1891,21 +1891,21 @@ static int pn533_dep_link_up(struct nfc_dev *nfc_dev, struct nfc_target *target,
 	u8 passive_data[PASSIVE_DATA_LEN] = {0x00, 0xff, 0xff, 0x00, 0x3};
 
 	if (dev->poll_mod_count) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Cannot bring the DEP link up while polling");
+		nfc_err(&dev->interface->dev,
+			"Cannot bring the DEP link up while polling\n");
 		return -EBUSY;
 	}
 
 	if (dev->tgt_active_prot) {
-		nfc_dev_err(&dev->interface->dev,
-			    "There is already an active target");
+		nfc_err(&dev->interface->dev,
+			"There is already an active target\n");
 		return -EBUSY;
 	}
 
 	baud = pn533_mod_to_baud(dev);
 	if (baud < 0) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Invalid curr modulation %d", dev->poll_mod_curr);
+		nfc_err(&dev->interface->dev,
+			"Invalid curr modulation %d\n", dev->poll_mod_curr);
 		return baud;
 	}
 
@@ -2035,9 +2035,8 @@ static int pn533_data_exchange_complete(struct pn533 *dev, void *_arg,
 	skb_pull(resp, sizeof(status));
 
 	if (ret != PN533_CMD_RET_SUCCESS) {
-		nfc_dev_err(&dev->interface->dev,
-			    "PN533 reported error %d when exchanging data",
-			    ret);
+		nfc_err(&dev->interface->dev,
+			"PN533 reported error %d when exchanging data\n", ret);
 		rc = -EIO;
 		goto error;
 	}
@@ -2077,16 +2076,16 @@ static int pn533_transceive(struct nfc_dev *nfc_dev,
 
 	if (skb->len > PN533_CMD_DATAEXCH_DATA_MAXLEN) {
 		/* TODO: Implement support to multi-part data exchange */
-		nfc_dev_err(&dev->interface->dev,
-			    "Data length greater than the max allowed: %d",
-			    PN533_CMD_DATAEXCH_DATA_MAXLEN);
+		nfc_err(&dev->interface->dev,
+			"Data length greater than the max allowed: %d\n",
+			PN533_CMD_DATAEXCH_DATA_MAXLEN);
 		rc = -ENOSYS;
 		goto error;
 	}
 
 	if (!dev->tgt_active_prot) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Can't exchange data if there is no active target");
+		nfc_err(&dev->interface->dev,
+			"Can't exchange data if there is no active target\n");
 		rc = -EINVAL;
 		goto error;
 	}
@@ -2162,9 +2161,9 @@ static int pn533_tm_send(struct nfc_dev *nfc_dev, struct sk_buff *skb)
 	int rc;
 
 	if (skb->len > PN533_CMD_DATAEXCH_DATA_MAXLEN) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Data length greater than the max allowed: %d",
-			    PN533_CMD_DATAEXCH_DATA_MAXLEN);
+		nfc_err(&dev->interface->dev,
+			"Data length greater than the max allowed: %d\n",
+			PN533_CMD_DATAEXCH_DATA_MAXLEN);
 		return -ENOSYS;
 	}
 
@@ -2213,8 +2212,8 @@ static void pn533_wq_mi_recv(struct work_struct *work)
 	if (rc == 0) /* success */
 		return;
 
-	nfc_dev_err(&dev->interface->dev,
-		    "Error %d when trying to perform data_exchange", rc);
+	nfc_err(&dev->interface->dev,
+		"Error %d when trying to perform data_exchange\n", rc);
 
 	dev_kfree_skb(skb);
 	kfree(dev->cmd_complete_arg);
@@ -2338,16 +2337,16 @@ static int pn533_setup(struct pn533 *dev)
 		break;
 
 	default:
-		nfc_dev_err(&dev->interface->dev, "Unknown device type %d\n",
-			    dev->device_type);
+		nfc_err(&dev->interface->dev, "Unknown device type %d\n",
+			dev->device_type);
 		return -EINVAL;
 	}
 
 	rc = pn533_set_configuration(dev, PN533_CFGITEM_MAX_RETRIES,
 				     (u8 *)&max_retries, sizeof(max_retries));
 	if (rc) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Error on setting MAX_RETRIES config");
+		nfc_err(&dev->interface->dev,
+			"Error on setting MAX_RETRIES config\n");
 		return rc;
 	}
 
@@ -2355,8 +2354,7 @@ static int pn533_setup(struct pn533 *dev)
 	rc = pn533_set_configuration(dev, PN533_CFGITEM_TIMING,
 				     (u8 *)&timing, sizeof(timing));
 	if (rc) {
-		nfc_dev_err(&dev->interface->dev,
-			    "Error on setting RF timings");
+		nfc_err(&dev->interface->dev, "Error on setting RF timings\n");
 		return rc;
 	}
 
@@ -2370,8 +2368,8 @@ static int pn533_setup(struct pn533 *dev)
 		rc = pn533_set_configuration(dev, PN533_CFGITEM_PASORI,
 					     pasori_cfg, 3);
 		if (rc) {
-			nfc_dev_err(&dev->interface->dev,
-				    "Error while settings PASORI config");
+			nfc_err(&dev->interface->dev,
+				"Error while settings PASORI config\n");
 			return rc;
 		}
 
@@ -2416,8 +2414,8 @@ static int pn533_probe(struct usb_interface *interface,
 	}
 
 	if (!in_endpoint || !out_endpoint) {
-		nfc_dev_err(&interface->dev,
-			    "Could not find bulk-in or bulk-out endpoint");
+		nfc_err(&interface->dev,
+			"Could not find bulk-in or bulk-out endpoint\n");
 		rc = -ENODEV;
 		goto error;
 	}
@@ -2467,8 +2465,8 @@ static int pn533_probe(struct usb_interface *interface,
 		break;
 
 	default:
-		nfc_dev_err(&dev->interface->dev, "Unknown device type %d\n",
-			    dev->device_type);
+		nfc_err(&dev->interface->dev, "Unknown device type %d\n",
+			dev->device_type);
 		rc = -EINVAL;
 		goto destroy_wq;
 	}
@@ -2478,9 +2476,9 @@ static int pn533_probe(struct usb_interface *interface,
 	if (rc < 0)
 		goto destroy_wq;
 
-	nfc_dev_info(&dev->interface->dev,
-		     "NXP PN533 firmware ver %d.%d now attached",
-		     fw_ver.ver, fw_ver.rev);
+	nfc_info(&dev->interface->dev,
+		 "NXP PN533 firmware ver %d.%d now attached\n",
+		 fw_ver.ver, fw_ver.rev);
 
 
 	dev->nfc_dev = nfc_allocate_device(&pn533_nfc_ops, protocols,
@@ -2548,7 +2546,7 @@ static void pn533_disconnect(struct usb_interface *interface)
 	usb_free_urb(dev->out_urb);
 	kfree(dev);
 
-	nfc_dev_info(&interface->dev, "NXP PN533 NFC device disconnected");
+	nfc_info(&interface->dev, "NXP PN533 NFC device disconnected\n");
 }
 
 static struct usb_driver pn533_driver = {
diff --git a/include/net/nfc/nfc.h b/include/net/nfc/nfc.h
index 3448f09..853ff83 100644
--- a/include/net/nfc/nfc.h
+++ b/include/net/nfc/nfc.h
@@ -28,8 +28,8 @@
 #include <linux/device.h>
 #include <linux/skbuff.h>
 
-#define nfc_dev_info(dev, fmt, arg...) dev_info((dev), "NFC: " fmt "\n", ## arg)
-#define nfc_dev_err(dev, fmt, arg...) dev_err((dev), "NFC: " fmt "\n", ## arg)
+#define nfc_info(dev, fmt, ...) dev_info((dev), "NFC: " fmt, ##__VA_ARGS__)
+#define nfc_err(dev, fmt, ...) dev_err((dev), "NFC: " fmt, ##__VA_ARGS__)
 
 struct nfc_dev;
 
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
