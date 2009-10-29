From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]convert kaweth to use usb_reset_configuration()
Date: Thu, 29 Oct 2009 16:07:12 +0100
Message-ID: <200910291607.12382.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Sarah Sharp <sarah.a.sharp@linux.intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:52491 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754304AbZJ2PFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 11:05:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For USB 3.0 it is necessary that all drivers use the standard
API to reset a configuration. This removes a home-grown
implementation.

Signed-off-by: Oliver Neukum <oliver@neukum.org>

Hi David,

please take this for the next merge window.

	Regards
		Oliver

--

--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -471,16 +471,7 @@ static int kaweth_reset(struct kaweth_device *kaweth)
 	int result;
 
 	dbg("kaweth_reset(%p)", kaweth);
-	result = kaweth_control(kaweth,
-				usb_sndctrlpipe(kaweth->dev, 0),
-				USB_REQ_SET_CONFIGURATION,
-				0,
-				kaweth->dev->config[0].desc.bConfigurationValue,
-				0,
-				NULL,
-				0,
-				KAWETH_CONTROL_TIMEOUT);
-
+	result = usb_reset_configuration(kaweth->dev);
 	mdelay(10);
 
 	dbg("kaweth_reset() returns %d.",result);

