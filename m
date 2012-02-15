From: Toby Gray <toby.gray@realvnc.com>
Subject: [PATCH 1/5] usb: cdc-ncm: Change alternate setting magic numbers into #defines
Date: Wed, 15 Feb 2012 14:47:37 +0000
Message-ID: <1329317261-3406-2-git-send-email-toby.gray@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Cc: netdev@vger.kernel.org, alexey.orishko@gmail.com,
	Toby Gray <toby.gray@realvnc.com>
To: Toby Gray <tg@realvnc.com>, Oliver Neukum <oliver@neukum.name>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from realvnc.com ([146.101.152.142]:53032 "EHLO realvnc.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758451Ab2BOOr5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Feb 2012 09:47:57 -0500
In-Reply-To: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CDC NCM specification describes the alternate settings that a CDC
NCM interface must support. Alternate setting 0 does not allow any
network traffic but allows configuration of the interface. Alternate 1
allows network traffic but doesn't allow configuration of some of the
interface properties.

This change provides #defines for there two numbers to clarify why
usb_set_interface is being called.

Signed-off-by: Toby Gray <toby.gray@realvnc.com>
---
 drivers/net/usb/cdc_ncm.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 3a539a9..3df51ee 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -87,6 +87,13 @@
 	(sizeof(struct usb_cdc_ncm_nth16) + sizeof(struct usb_cdc_ncm_ndp16) + \
 	(CDC_NCM_DPT_DATAGRAMS_MAX + 1) * sizeof(struct usb_cdc_ncm_dpe16))
 
+/* CDC NCM ch. 5.3 describes alternate setting 0 as having no
+ * endpoints and therefore not allowing any networking traffic. */
+#define	CDC_NCM_ALTSETTING_RESET	0
+/* CDC NCM ch. 5.3 describes alternate setting 1 as having the
+ * required bulk endpoints for normal operation. */
+#define	CDC_NCM_ALTSETTING_DATA		1
+
 struct cdc_ncm_data {
 	struct usb_cdc_ncm_nth16 nth16;
 	struct usb_cdc_ncm_ndp16 ndp16;
@@ -549,7 +556,7 @@ advance:
 	iface_no = ctx->data->cur_altsetting->desc.bInterfaceNumber;
 
 	/* reset data interface */
-	temp = usb_set_interface(dev->udev, iface_no, 0);
+	temp = usb_set_interface(dev->udev, iface_no, CDC_NCM_ALTSETTING_RESET);
 	if (temp)
 		goto error2;
 
@@ -558,7 +565,7 @@ advance:
 		goto error2;
 
 	/* configure data interface */
-	temp = usb_set_interface(dev->udev, iface_no, 1);
+	temp = usb_set_interface(dev->udev, iface_no, CDC_NCM_ALTSETTING_DATA);
 	if (temp)
 		goto error2;
 
-- 
1.7.0.4
