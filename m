From: samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org
Subject: [PATCH 6/7] [IrDA] Adding carriage returns to mcs7780
	debug statements
Date: Thu, 19 Apr 2007 00:32:08 +0300
Message-ID: <20070418214751.798743063@sortiz.org>
References: <20070418213202.214829666@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline;
	filename=0007-IrDA-net-2.6.22-Adding-carriage-returns-to-mcs77.patch
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=irda-users>
List-Post: <mailto:irda-users-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/irda-users>,
	<mailto:irda-users-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Sender: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: irda-users-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Samuel Ortiz <samuel-jcdQHdrhKHMdnm+yROfE0A@public.gmane.org>
---
 drivers/net/irda/mcs7780.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 54d1d54..0de8672 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -200,14 +200,14 @@ static inline int mcs_setup_transceiver_vishay(struct mcs_cb *mcs)
 /* Setup a communication between mcs7780 and agilent chip. */
 static inline int mcs_setup_transceiver_agilent(struct mcs_cb *mcs)
 {
-	IRDA_WARNING("This transceiver type is not supported yet.");
+	IRDA_WARNING("This transceiver type is not supported yet.\n");
 	return 1;
 }
 
 /* Setup a communication between mcs7780 and sharp chip. */
 static inline int mcs_setup_transceiver_sharp(struct mcs_cb *mcs)
 {
-	IRDA_WARNING("This transceiver type is not supported yet.");
+	IRDA_WARNING("This transceiver type is not supported yet.\n");
 	return 1;
 }
 
@@ -279,7 +279,7 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 		break;
 
 	default:
-		IRDA_WARNING("Unknown transceiver type: %d",
+		IRDA_WARNING("Unknown transceiver type: %d\n",
 			     mcs->transceiver_type);
 		ret = 1;
 	}
@@ -318,7 +318,7 @@ static inline int mcs_setup_transceiver(struct mcs_cb *mcs)
 		return ret;
 
 error:
-	IRDA_ERROR("%s", msg);
+	IRDA_ERROR("%s\n", msg);
 	return ret;
 }
 
@@ -587,7 +587,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 	} while(cnt++ < 100 && (rval & MCS_IRINTX));
 
 	if(cnt >= 100) {
-		IRDA_ERROR("unable to change speed");
+		IRDA_ERROR("unable to change speed\n");
 		ret = -EIO;
 		goto error;
 	}
@@ -638,7 +638,7 @@ static int mcs_speed_change(struct mcs_cb *mcs)
 
 		default:
 			ret = 1;
-			IRDA_WARNING("Unknown transceiver type: %d",
+			IRDA_WARNING("Unknown transceiver type: %d\n",
 				     mcs->transceiver_type);
 		}
 	if (unlikely(ret))
@@ -733,7 +733,7 @@ static int mcs_net_open(struct net_device *netdev)
 	sprintf(hwname, "usb#%d", mcs->usbdev->devnum);
 	mcs->irlap = irlap_open(netdev, &mcs->qos, hwname);
 	if (!mcs->irlap) {
-		IRDA_ERROR("mcs7780: irlap_open failed");
+		IRDA_ERROR("mcs7780: irlap_open failed\n");
 		goto error2;
 	}
 
@@ -862,7 +862,7 @@ static int mcs_hard_xmit(struct sk_buff *skb, struct net_device *ndev)
 			  mcs->out_buf, wraplen, mcs_send_irq, mcs);
 
 	if ((ret = usb_submit_urb(mcs->tx_urb, GFP_ATOMIC))) {
-		IRDA_ERROR("failed tx_urb: %d", ret);
+		IRDA_ERROR("failed tx_urb: %d\n", ret);
 		switch (ret) {
 		case -ENODEV:
 		case -EPIPE:
@@ -897,7 +897,7 @@ static int mcs_probe(struct usb_interface *intf,
 	if (!ndev)
 		goto error1;
 
-	IRDA_DEBUG(1, "MCS7780 USB-IrDA bridge found at %d.", udev->devnum);
+	IRDA_DEBUG(1, "MCS7780 USB-IrDA bridge found at %d.\n", udev->devnum);
 
 	/* what is it realy for? */
 	SET_MODULE_OWNER(ndev);
@@ -905,7 +905,7 @@ static int mcs_probe(struct usb_interface *intf,
 
 	ret = usb_reset_configuration(udev);
 	if (ret != 0) {
-		IRDA_ERROR("mcs7780: usb reset configuration failed");
+		IRDA_ERROR("mcs7780: usb reset configuration failed\n");
 		goto error2;
 	}
 
@@ -950,7 +950,7 @@ static int mcs_probe(struct usb_interface *intf,
 	if (ret != 0)
 		goto error2;
 
-	IRDA_DEBUG(1, "IrDA: Registered MosChip MCS7780 device as %s",
+	IRDA_DEBUG(1, "IrDA: Registered MosChip MCS7780 device as %s\n",
 		   ndev->name);
 
 	mcs->transceiver_type = transceiver_type;
@@ -981,7 +981,7 @@ static void mcs_disconnect(struct usb_interface *intf)
 	free_netdev(mcs->netdev);
 
 	usb_set_intfdata(intf, NULL);
-	IRDA_DEBUG(0, "MCS7780 now disconnected.");
+	IRDA_DEBUG(0, "MCS7780 now disconnected.\n");
 }
 
 /* Module insertion */
@@ -992,7 +992,7 @@ static int __init mcs_init(void)
 	/* register this driver with the USB subsystem */
 	result = usb_register(&mcs_driver);
 	if (result)
-		IRDA_ERROR("usb_register failed. Error number %d", result);
+		IRDA_ERROR("usb_register failed. Error number %d\n", result);
 
 	return result;
 }
-- 
1.5.1

--


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
