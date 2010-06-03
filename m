From: Dan Carpenter <error27@gmail.com>
Subject: [patch] isdn/kcapi: return -EFAULT on copy_from_user errors
Date: Thu, 3 Jun 2010 11:56:13 +0200
Message-ID: <20100603095613.GP5483@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jan Kiszka <jan.kiszka@web.de>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:42371 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758204Ab0FCJ4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 05:56:32 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

copy_from_user() returns the number of bytes remaining but we should
return -EFAULT here.  The error code gets returned to the user.  Both 
old_capi_manufacturer() and capi20_manufacturer() had other places
that already returned -EFAULT so this won't break anything.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/drivers/isdn/capi/kcapi.c b/drivers/isdn/capi/kcapi.c
index bde3c88..b054494 100644
--- a/drivers/isdn/capi/kcapi.c
+++ b/drivers/isdn/capi/kcapi.c
@@ -1020,12 +1020,12 @@ static int old_capi_manufacturer(unsigned int cmd, void __user *data)
 		if (cmd == AVMB1_ADDCARD) {
 		   if ((retval = copy_from_user(&cdef, data,
 					    sizeof(avmb1_carddef))))
-			   return retval;
+			   return -EFAULT;
 		   cdef.cardtype = AVM_CARDTYPE_B1;
 		} else {
 		   if ((retval = copy_from_user(&cdef, data,
 					    sizeof(avmb1_extcarddef))))
-			   return retval;
+			   return -EFAULT;
 		}
 		cparams.port = cdef.port;
 		cparams.irq = cdef.irq;
@@ -1218,7 +1218,7 @@ int capi20_manufacturer(unsigned int cmd, void __user *data)
 		kcapi_carddef cdef;
 
 		if ((retval = copy_from_user(&cdef, data, sizeof(cdef))))
-			return retval;
+			return -EFAULT;
 
 		cparams.port = cdef.port;
 		cparams.irq = cdef.irq;
