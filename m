From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH] irda-usb: use NULL instead of 0
Date: Mon, 1 May 2006 15:31:34 -0700
Message-ID: <20060501153134.811ac2d4.rdunlap@xenotime.net>
References: <20060501150807.b05fe450.rdunlap@xenotime.net>
	<200605020019.25382.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:17880 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S932287AbWEAW3J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 May 2006 18:29:09 -0400
Received: from midway.site ([71.111.157.99]) by xenotime.net for <netdev@vger.kernel.org>; Mon, 1 May 2006 15:29:08 -0700
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605020019.25382.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I could be mistaken, but wasn't the usb_control_msg timeout type changed in kernel 2.6.12?
> The timeout value is no longer in jiffies but in msecs.

ugh, correct.  Here's a new patch.
Thanks.

---
From: Randy Dunlap <rdunlap@xenotime.net>

Use NULL instead of 0 for a null pointer value (sparse warning):
drivers/net/irda/irda-usb.c:1781:30: warning: Using plain integer as NULL pointer

Correct timeout argument to use milliseconds instead of jiffies.

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 drivers/net/irda/irda-usb.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- linux-2617-rc3.orig/drivers/net/irda/irda-usb.c
+++ linux-2617-rc3/drivers/net/irda/irda-usb.c
@@ -1778,7 +1778,7 @@ static int irda_usb_probe(struct usb_int
 
 	if (self->needspatch) {
 		ret = usb_control_msg (self->usbdev, usb_sndctrlpipe (self->usbdev, 0),
-				       0x02, 0x40, 0, 0, 0, 0, msecs_to_jiffies(500));
+				       0x02, 0x40, 0, 0, NULL, 0, 500);
 		if (ret < 0) {
 			IRDA_DEBUG (0, "usb_control_msg failed %d\n", ret);
 			goto err_out_3;
