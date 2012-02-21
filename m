From: Dave Jones <davej@redhat.com>
Subject: zaurus: Add ID for C-750/C-760/C-860/SL-C3000 PDA in MDLM mode
Date: Mon, 20 Feb 2012 22:28:13 -0500
Message-ID: <20120221032813.GA14228@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751800Ab2BUD2R (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Feb 2012 22:28:17 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q1L3SGcg022633
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:28:16 -0500
Received: from gelk.kernelslacker.org (ovpn-113-139.phx2.redhat.com [10.3.113.139])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id q1L3SF3M022949
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:28:16 -0500
Received: from gelk.kernelslacker.org (localhost [127.0.0.1])
	by gelk.kernelslacker.org (8.14.5/8.14.5) with ESMTP id q1L3SEsv014238
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 22:28:14 -0500
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.5/8.14.5/Submit) id q1L3SEq3014236
	for netdev@vger.kernel.org; Mon, 20 Feb 2012 22:28:14 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In 16adf5d07987d93675945f3cecf0e33706566005 I removed an over-broad
alias that caused zaurus.ko to bind to unrelated devices.
I had a report that at least one valid case no longer auto-loads because of this.
This patch adds an ID for that case.

Reported-by: Raphael Wimmer <raphael.wimmer@ur.de>
Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/drivers/net/usb/zaurus.c b/drivers/net/usb/zaurus.c
index f701d41..ed2caed 100644
--- a/drivers/net/usb/zaurus.c
+++ b/drivers/net/usb/zaurus.c
@@ -316,6 +316,11 @@ static const struct usb_device_id	products [] = {
 	ZAURUS_MASTER_INTERFACE,
 	.driver_info = ZAURUS_PXA_INFO,
 }, {
+	/* C-750/C-760/C-860/SL-C3000 PDA in MDLM mode */
+	USB_DEVICE_AND_INTERFACE_INFO(0x04DD, 0x9031, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &bogus_mdlm_info,
+}, {
 	.match_flags    =   USB_DEVICE_ID_MATCH_INT_INFO
 		 | USB_DEVICE_ID_MATCH_DEVICE,
 	.idVendor               = 0x04DD,
