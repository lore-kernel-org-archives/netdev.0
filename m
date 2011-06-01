From: Stefan Metzmacher <metze@samba.org>
Subject: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed,  1 Jun 2011 14:01:41 +0200
Message-ID: <1306929701-22861-2-git-send-email-metze@samba.org>
References: <2AC7D4AD8BA1C640B4C60C61C8E520153E3C07E568@EXDCVYMBSTM006.EQ1STM.local>
 <1306929701-22861-1-git-send-email-metze@samba.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Metzmacher <metze@samba.org>
To: Oliver Neukum <oliver@neukum.name>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p05-ob.rzone.de ([81.169.146.180]:57148 "EHLO
	mo-p05-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758768Ab1FAMCE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 08:02:04 -0400
In-Reply-To: <1306929701-22861-1-git-send-email-metze@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This avoids messages like this after suspend:

   cdc_ncm 2-1.4:1.6: no reset_resume for driver cdc_ncm?
   cdc_ncm 2-1.4:1.7: no reset_resume for driver cdc_ncm?
   cdc_ncm 2-1.4:1.6: usb0: unregister 'cdc_ncm' usb-0000:00:1d.0-1.4, CDC NCM

This is important for the Ericsson F5521gw GSM/UMTS modem.
Otherwise modemmanager looses the fact that the cdc_ncm and cdc_acm devices
belong together.

The cdc_ether module does the same.

Signed-off-by: Stefan Metzmacher <metze@samba.org>
---
 drivers/net/usb/cdc_ncm.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index cdd3ae4..f33ca6a 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -54,7 +54,7 @@
 #include <linux/usb/usbnet.h>
 #include <linux/usb/cdc.h>
 
-#define	DRIVER_VERSION				"24-May-2011"
+#define	DRIVER_VERSION				"01-June-2011"
 
 /* CDC NCM subclass 3.2.1 */
 #define USB_CDC_NCM_NDP16_LENGTH_MIN		0x10
@@ -1234,6 +1234,7 @@ static struct usb_driver cdc_ncm_driver = {
 	.disconnect = cdc_ncm_disconnect,
 	.suspend = usbnet_suspend,
 	.resume = usbnet_resume,
+	.reset_resume =	usbnet_resume,
 	.supports_autosuspend = 1,
 };
 
-- 
1.7.4.1

