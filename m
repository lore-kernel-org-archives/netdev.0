From: Torgny Johansson <torgny.johansson@ericsson.com>
Subject: [PATCH torvalds-2.6] cdc_ether: fix autosuspend for mbm devices
Date: Mon, 26 Apr 2010 12:14:13 +0200
Message-ID: <201004261214.13836.torgny.johansson@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <oliver@neukum.org>, <davem@davemlost.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw9.se.ericsson.net ([193.180.251.57]:62212 "EHLO
	mailgw9.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752240Ab0DZKOQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 06:14:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

In 2.6.33 it seems autosuspend is broken for mbm devices.

Autosuspend works until you bring the wwan interface up, then the device does not enter autosuspend anymore.

The following patch fixes the problem by setting the .manage_power field in the mbm_info struct 
to the same as in the cdc_info struct (cdc_manager_power).

I am unsure exactly what that does and why autosuspend doesn't work without it. 
Can you guys comment on that? Is this fix the correct approach?

Also, if you like this patch, is it possible to get it included in a minor release of 2.6.33 (e.g. 2.6.33.3) as a bugfix?

Regards
Torgny Johansson

---
Signed-off-by: Torgny Johansson <torgny.johansson@ericsson.com>

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index c8cdb7f..3547cf1 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -431,6 +431,7 @@ static const struct driver_info mbm_info = {
 	.bind = 	cdc_bind,
 	.unbind =	usbnet_cdc_unbind,
 	.status =	cdc_status,
+	.manage_power =	cdc_manage_power,
 };
 
 /*-------------------------------------------------------------------------*/

