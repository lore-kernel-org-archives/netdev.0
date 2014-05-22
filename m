From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] net: cdc_ncm: fix typo in test for supported formats
Date: Thu, 22 May 2014 10:52:29 +0300
Message-ID: <20140522075229.GA4346@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>,
	=?iso-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a typo here where we test for USB_CDC_NCM_NTH32_SIGN instead
of USB_CDC_NCM_NTB32_SUPPORTED.  The test probably still works as
written because 0x686D636E has (1 << 1) set and doesn't have (1 << 0)
set.

Fixes: f8afb73da375 ('net: cdc_ncm: factor out one-time device initialization')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
Static analysis.  Untested.  Applies on -next

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index ad2a386..93c9ca9 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -357,7 +357,8 @@ static int cdc_ncm_init(struct usbnet *dev)
 	 * "The host shall only send this command while the NCM Data
 	 *  Interface is in alternate setting 0."
 	 */
-	if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) & USB_CDC_NCM_NTH32_SIGN) {
+	if (le16_to_cpu(ctx->ncm_parm.bmNtbFormatsSupported) &
+						USB_CDC_NCM_NTB32_SUPPORTED) {
 		dev_dbg(&dev->intf->dev, "Setting NTB format to 16-bit\n");
 		err = usbnet_write_cmd(dev, USB_CDC_SET_NTB_FORMAT,
 				       USB_TYPE_CLASS | USB_DIR_OUT
