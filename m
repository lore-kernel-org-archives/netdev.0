From: Stefan Metzmacher <metze@samba.org>
Subject: [PATCH] usbnet/cdc_ncm: add missing .reset_resume hook
Date: Wed,  1 Jun 2011 11:13:50 +0200
Message-ID: <1306919630-13426-2-git-send-email-metze@samba.org>
References: <1306919630-13426-1-git-send-email-metze@samba.org>
Cc: Greg Kroah-Hartman <gregkh@suse.de>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stefan Metzmacher <metze@samba.org>
To: Oliver Neukum <oliver@neukum.name>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1306919630-13426-1-git-send-email-metze@samba.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 drivers/net/usb/cdc_ncm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index cdd3ae4..3257aaa 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1234,6 +1234,7 @@ static struct usb_driver cdc_ncm_driver = {
 	.disconnect = cdc_ncm_disconnect,
 	.suspend = usbnet_suspend,
 	.resume = usbnet_resume,
+	.reset_resume =	usbnet_resume,
 	.supports_autosuspend = 1,
 };
 
-- 
1.7.4.1
