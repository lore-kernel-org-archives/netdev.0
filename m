From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: Re: [PATCH] Cleanup usbnet_probe() return value handling
Date: Tue, 03 Jul 2007 00:46:42 +0200
Message-ID: <87sl86juel.fsf@p4.be.48ers.dk>
References: <87lkdyx19a.fsf@nanv.dk> <200707020914.38479.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dbrownell@users.sourceforge.net
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp40.mobistarmail.be ([193.252.23.61]:15902 "EHLO
	smtp40.mobistarmail.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757556AbXGBWqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2007 18:46:20 -0400
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf4016.mobistarmail.be (SMTP Server) with ESMTP id 19C4F700008B
	for <netdev@vger.kernel.org>; Tue,  3 Jul 2007 00:46:16 +0200 (CEST)
In-Reply-To: <200707020914.38479.david-b@pacbell.net> (David Brownell's
	message of "Mon, 2 Jul 2007 09:14:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>>>>> "David" == David Brownell <david-b@pacbell.net> writes:

Hi,

 David> I'd rather see the later test updated to match this one.
 David> (Good catch!)

 David> The return convention is "negative means error".  There's
 David> code in USB which has multiple nonnegative success codes.

Ok, updated patch does that instead.

 David> In particular usb_control_msg(), which would very naturally
 David> used as the body of a bind() method, returns negative or
 David> the number of bytes transferred.

Yeah, that was the original problem in my dm9601 driver.

usbnet_probe() handles a positive return value from the driver bind()
function as success, but will later only setup the status handler if the
return value was zero, leading to confusion. Patch adjusts this to accept
positive values as success in both checks.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>
---
 drivers/net/usb/usbnet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.22-rc7/drivers/net/usb/usbnet.c
===================================================================
--- linux-2.6.22-rc7.orig/drivers/net/usb/usbnet.c
+++ linux-2.6.22-rc7/drivers/net/usb/usbnet.c
@@ -1208,7 +1208,7 @@
 			status = 0;
 
 	}
-	if (status == 0 && dev->status)
+	if (status >= 0 && dev->status)
 		status = init_status (dev, udev);
 	if (status < 0)
 		goto out3;

-- 
Bye, Peter Korsgaard

