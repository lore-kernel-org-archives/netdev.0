From: Oliver Neukum <oliver@neukum.org>
Subject: [patch]replace runtime power management primitives in kaweth driver
Date: Wed, 19 Aug 2009 21:35:01 +0200
Message-ID: <200908192135.01422.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Alan Stern <stern@rowland.harvard.edu>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:48297 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751850AbZHSTeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:34:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch removes a rare use of the USB power management API which
won't be supported after the conversion to the new generic runtime power
management framework. Functionality is not altered.

Signed-off-by: Oliver Neukum <oliver@neukum.org>

Hi,

please accept this for the next merge window. It will be needed for
the adoption of the generic framework for USB.

	Regards
		Oliver

--

commit eb6ea8b517c6390e85585aa3f24483840296487e
Author: Oliver Neukum <oliver@neukum.org>
Date:   Wed Aug 19 20:27:42 2009 +0200

    usb: remove rare pm primitive for conversion to new API

diff --git a/drivers/net/usb/kaweth.c b/drivers/net/usb/kaweth.c
index 1f9ec29..6db2c70 100644
--- a/drivers/net/usb/kaweth.c
+++ b/drivers/net/usb/kaweth.c
@@ -721,7 +721,7 @@ static int kaweth_open(struct net_device *net)
 	return 0;
 
 err_out:
-	usb_autopm_enable(kaweth->intf);
+	usb_autopm_put_interface(kaweth->intf);
 	return -EIO;
 }
 
@@ -758,7 +758,7 @@ static int kaweth_close(struct net_device *net)
 
 	kaweth->status &= ~KAWETH_STATUS_CLOSING;
 
-	usb_autopm_enable(kaweth->intf);
+	usb_autopm_put_interface(kaweth->intf);
 
 	return 0;
 }

