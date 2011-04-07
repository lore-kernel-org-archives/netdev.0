From: "Justin P. Mattock" <justinmattock@gmail.com>
Subject: [RFC 1/6]Fix typo "recieve" in various parts of the kernel.
Date: Thu,  7 Apr 2011 09:09:22 -0700
Message-ID: <1302192567-842-1-git-send-email-justinmattock@gmail.com>
Cc: linux-kernel@vger.kernel.org,
	"Justin P. Mattock" <justinmattock@gmail.com>,
	linux-input@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mtd@lists.infradead.org, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de, linux-scsi@vger.kernel.org,
	linux-usb@vger.kernel.org
To: trivial@kernel.org
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The patch below fixes some typos "recieve" in various parts of the kernel.
Note: these below are in actual code rather than comments(excpet for r852.c which
has a code fix, and comment).
compile tested as best as I can...

Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
CC: linux-input@vger.kernel.org
CC: linux-arm-kernel@lists.infradead.org 
CC: linux-mtd@lists.infradead.org
CC: netdev@vger.kernel.org
CC: socketcan-core@lists.berlios.de
CC: linux-scsi@vger.kernel.org 
CC: linux-usb@vger.kernel.org
---
 drivers/input/misc/keyspan_remote.c |    2 +-
 drivers/mfd/ab8500-gpadc.c          |    2 +-
 drivers/mtd/nand/r852.c             |    6 +++---
 drivers/net/bnx2x/bnx2x_link.c      |    8 ++++----
 drivers/net/can/janz-ican3.c        |    4 ++--
 drivers/scsi/scsi_netlink.c         |    2 +-
 drivers/usb/misc/ftdi-elan.c        |   28 ++++++++++++++--------------
 drivers/uwb/reset.c                 |    2 +-
 8 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/input/misc/keyspan_remote.c b/drivers/input/misc/keyspan_remote.c
index a93c525..fc62256 100644
--- a/drivers/input/misc/keyspan_remote.c
+++ b/drivers/input/misc/keyspan_remote.c
@@ -312,7 +312,7 @@ static void keyspan_check_data(struct usb_keyspan *remote)
 			remote->data.tester = remote->data.tester >> 5;
 			remote->data.bits_left -= 5;
 		} else {
-			err("Bad message recieved, no stop bit found.\n");
+			err("Bad message received, no stop bit found.\n");
 		}
 
 		dev_dbg(&remote->udev->dev,
diff --git a/drivers/mfd/ab8500-gpadc.c b/drivers/mfd/ab8500-gpadc.c
index bc93b2e..ea91ef1 100644
--- a/drivers/mfd/ab8500-gpadc.c
+++ b/drivers/mfd/ab8500-gpadc.c
@@ -314,7 +314,7 @@ int ab8500_gpadc_convert(struct ab8500_gpadc *gpadc, u8 input)
 	/* wait for completion of conversion */
 	if (!wait_for_completion_timeout(&gpadc->ab8500_gpadc_complete, 2*HZ)) {
 		dev_err(gpadc->dev,
-			"timeout: didnt recieve GPADC conversion interrupt\n");
+			"timeout: didnt receive GPADC conversion interrupt\n");
 		ret = -EINVAL;
 		goto out;
 	}
diff --git a/drivers/mtd/nand/r852.c b/drivers/mtd/nand/r852.c
index 6322d1f..45a3f60 100644
--- a/drivers/mtd/nand/r852.c
+++ b/drivers/mtd/nand/r852.c
@@ -766,7 +766,7 @@ static irqreturn_t r852_irq(int irq, void *data)
 		ret = IRQ_HANDLED;
 		dev->card_detected = !!(card_status & R852_CARD_IRQ_INSERT);
 
-		/* we shouldn't recieve any interrupts if we wait for card
+		/* we shouldn't receive any interrupts if we wait for card
 			to settle */
 		WARN_ON(dev->card_unstable);
 
@@ -794,13 +794,13 @@ static irqreturn_t r852_irq(int irq, void *data)
 		ret = IRQ_HANDLED;
 
 		if (dma_status & R852_DMA_IRQ_ERROR) {
-			dbg("recieved dma error IRQ");
+			dbg("received dma error IRQ");
 			r852_dma_done(dev, -EIO);
 			complete(&dev->dma_done);
 			goto out;
 		}
 
-		/* recieved DMA interrupt out of nowhere? */
+		/* received DMA interrupt out of nowhere? */
 		WARN_ON_ONCE(dev->dma_stage == 0);
 
 		if (dev->dma_stage == 0)
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index f2f367d..d25491b 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -2385,7 +2385,7 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 					 struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u16 rx_status, ustat_val, cl37_fsm_recieved;
+	u16 rx_status, ustat_val, cl37_fsm_received;
 	DP(NETIF_MSG_LINK, "bnx2x_check_fallback_to_cl37\n");
 	/* Step 1: Make sure signal is detected */
 	CL22_RD_OVER_CL45(bp, phy,
@@ -2423,15 +2423,15 @@ static void bnx2x_check_fallback_to_cl37(struct bnx2x_phy *phy,
 	CL22_RD_OVER_CL45(bp, phy,
 			  MDIO_REG_BANK_REMOTE_PHY,
 			  MDIO_REMOTE_PHY_MISC_RX_STATUS,
-			  &cl37_fsm_recieved);
-	if ((cl37_fsm_recieved &
+			  &cl37_fsm_received);
+	if ((cl37_fsm_received &
 	     (MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG |
 	     MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG)) !=
 	    (MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_OVER1G_MSG |
 	      MDIO_REMOTE_PHY_MISC_RX_STATUS_CL37_FSM_RECEIVED_BRCM_OUI_MSG)) {
 		DP(NETIF_MSG_LINK, "No CL37 FSM were received. "
 			     "misc_rx_status(0x8330) = 0x%x\n",
-			 cl37_fsm_recieved);
+			 cl37_fsm_received);
 		return;
 	}
 	/*
diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
index 102b16c..98667f9 100644
--- a/drivers/net/can/janz-ican3.c
+++ b/drivers/net/can/janz-ican3.c
@@ -1050,7 +1050,7 @@ static void ican3_handle_inquiry(struct ican3_dev *mod, struct ican3_msg *msg)
 		complete(&mod->termination_comp);
 		break;
 	default:
-		dev_err(mod->dev, "recieved an unknown inquiry response\n");
+		dev_err(mod->dev, "received an unknown inquiry response\n");
 		break;
 	}
 }
@@ -1058,7 +1058,7 @@ static void ican3_handle_inquiry(struct ican3_dev *mod, struct ican3_msg *msg)
 static void ican3_handle_unknown_message(struct ican3_dev *mod,
 					struct ican3_msg *msg)
 {
-	dev_warn(mod->dev, "recieved unknown message: spec 0x%.2x length %d\n",
+	dev_warn(mod->dev, "received unknown message: spec 0x%.2x length %d\n",
 			   msg->spec, le16_to_cpu(msg->len));
 }
 
diff --git a/drivers/scsi/scsi_netlink.c b/drivers/scsi/scsi_netlink.c
index a2ed201..26a8a45 100644
--- a/drivers/scsi/scsi_netlink.c
+++ b/drivers/scsi/scsi_netlink.c
@@ -499,7 +499,7 @@ scsi_netlink_init(void)
 				SCSI_NL_GRP_CNT, scsi_nl_rcv_msg, NULL,
 				THIS_MODULE);
 	if (!scsi_nl_sock) {
-		printk(KERN_ERR "%s: register of recieve handler failed\n",
+		printk(KERN_ERR "%s: register of receive handler failed\n",
 				__func__);
 		netlink_unregister_notifier(&scsi_netlink_notifier);
 		return;
diff --git a/drivers/usb/misc/ftdi-elan.c b/drivers/usb/misc/ftdi-elan.c
index 7839c98..1871a30 100644
--- a/drivers/usb/misc/ftdi-elan.c
+++ b/drivers/usb/misc/ftdi-elan.c
@@ -187,7 +187,7 @@ struct usb_ftdi {
         u32 controlreg;
         u8 response[4 + 1024];
         int expected;
-        int recieved;
+        int received;
         int ed_found;
 };
 #define kref_to_usb_ftdi(d) container_of(d, struct usb_ftdi, kref)
@@ -353,7 +353,7 @@ static void ftdi_elan_abandon_targets(struct usb_ftdi *ftdi)
                         mutex_lock(&ftdi->u132_lock);
                 }
         }
-        ftdi->recieved = 0;
+        ftdi->received = 0;
         ftdi->expected = 4;
         ftdi->ed_found = 0;
         mutex_unlock(&ftdi->u132_lock);
@@ -411,7 +411,7 @@ static void ftdi_elan_flush_targets(struct usb_ftdi *ftdi)
                         }
                 }
         }
-        ftdi->recieved = 0;
+        ftdi->received = 0;
         ftdi->expected = 4;
         ftdi->ed_found = 0;
         mutex_unlock(&ftdi->u132_lock);
@@ -447,7 +447,7 @@ static void ftdi_elan_cancel_targets(struct usb_ftdi *ftdi)
                         }
                 }
         }
-        ftdi->recieved = 0;
+        ftdi->received = 0;
         ftdi->expected = 4;
         ftdi->ed_found = 0;
         mutex_unlock(&ftdi->u132_lock);
@@ -874,7 +874,7 @@ static char *have_ed_set_response(struct usb_ftdi *ftdi,
                         mutex_unlock(&ftdi->u132_lock);
                         ftdi_elan_do_callback(ftdi, target, 4 + ftdi->response,
                                 payload);
-                        ftdi->recieved = 0;
+                        ftdi->received = 0;
                         ftdi->expected = 4;
                         ftdi->ed_found = 0;
                         return ftdi->response;
@@ -890,7 +890,7 @@ static char *have_ed_set_response(struct usb_ftdi *ftdi,
                         mutex_unlock(&ftdi->u132_lock);
                         ftdi_elan_do_callback(ftdi, target, 4 + ftdi->response,
                                 payload);
-                        ftdi->recieved = 0;
+                        ftdi->received = 0;
                         ftdi->expected = 4;
                         ftdi->ed_found = 0;
                         return ftdi->response;
@@ -905,7 +905,7 @@ static char *have_ed_set_response(struct usb_ftdi *ftdi,
                 mutex_unlock(&ftdi->u132_lock);
                 ftdi_elan_do_callback(ftdi, target, 4 + ftdi->response,
                         payload);
-                ftdi->recieved = 0;
+                ftdi->received = 0;
                 ftdi->expected = 4;
                 ftdi->ed_found = 0;
                 return ftdi->response;
@@ -914,7 +914,7 @@ static char *have_ed_set_response(struct usb_ftdi *ftdi,
                 mutex_unlock(&ftdi->u132_lock);
                 ftdi_elan_do_callback(ftdi, target, 4 + ftdi->response,
                         payload);
-                ftdi->recieved = 0;
+                ftdi->received = 0;
                 ftdi->expected = 4;
                 ftdi->ed_found = 0;
                 return ftdi->response;
@@ -934,7 +934,7 @@ static char *have_ed_get_response(struct usb_ftdi *ftdi,
         if (target->active)
                 ftdi_elan_do_callback(ftdi, target, NULL, 0);
         target->abandoning = 0;
-        ftdi->recieved = 0;
+        ftdi->received = 0;
         ftdi->expected = 4;
         ftdi->ed_found = 0;
         return ftdi->response;
@@ -951,7 +951,7 @@ static char *have_ed_get_response(struct usb_ftdi *ftdi,
 */
 static int ftdi_elan_respond_engine(struct usb_ftdi *ftdi)
 {
-        u8 *b = ftdi->response + ftdi->recieved;
+        u8 *b = ftdi->response + ftdi->received;
         int bytes_read = 0;
         int retry_on_empty = 1;
         int retry_on_timeout = 3;
@@ -1043,11 +1043,11 @@ static int ftdi_elan_respond_engine(struct usb_ftdi *ftdi)
                 u8 c = ftdi->bulk_in_buffer[++ftdi->bulk_in_last];
                 bytes_read += 1;
                 ftdi->bulk_in_left -= 1;
-                if (ftdi->recieved == 0 && c == 0xFF) {
+                if (ftdi->received == 0 && c == 0xFF) {
                         goto have;
                 } else
                         *b++ = c;
-                if (++ftdi->recieved < ftdi->expected) {
+                if (++ftdi->received < ftdi->expected) {
                         goto have;
                 } else if (ftdi->ed_found) {
                         int ed_number = (ftdi->response[0] >> 5) & 0x03;
@@ -1069,7 +1069,7 @@ static int ftdi_elan_respond_engine(struct usb_ftdi *ftdi)
                         }
                         ftdi_elan_do_callback(ftdi, target, 4 + ftdi->response,
                                 payload);
-                        ftdi->recieved = 0;
+                        ftdi->received = 0;
                         ftdi->expected = 4;
                         ftdi->ed_found = 0;
                         b = ftdi->response;
@@ -1089,7 +1089,7 @@ static int ftdi_elan_respond_engine(struct usb_ftdi *ftdi)
                         *respond->value = data;
                         *respond->result = 0;
                         complete(&respond->wait_completion);
-                        ftdi->recieved = 0;
+                        ftdi->received = 0;
                         ftdi->expected = 4;
                         ftdi->ed_found = 0;
                         b = ftdi->response;
diff --git a/drivers/uwb/reset.c b/drivers/uwb/reset.c
index 2784929..3de630b 100644
--- a/drivers/uwb/reset.c
+++ b/drivers/uwb/reset.c
@@ -52,7 +52,7 @@ const char *__strerror[] = {
 	"cancelled",
 	"invalid state",
 	"invalid size",
-	"ack not recieved",
+	"ack not received",
 	"no more asie notification",
 };
 
-- 
1.7.4.2

