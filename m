From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 13:45:11 +0200
Message-ID: <200804211345.12850.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804171632.12972.oliver@neukum.org> <4808BBC5.5070800@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:59221 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754992AbYDULh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 07:37:56 -0400
In-Reply-To: <4808BBC5.5070800@teltonika.lt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 18. April 2008 17:18:29 schrieb Paulius Zaleckas:
> 
> Oliver Neukum wrote:
> > 
> > Hi,
> > 
> > can you test this one as well. The method used to determine whether
> > a device is asleep is racy. This introduces a private test.
> > 
> > 	Regards
> > 		Oliver
> 
> By setting level "auto" it didn't suspend...
> When I tried to set "suspend" to the level I got crash:

Does this fix it?

	Regards
		Oliver

---

--- linux-2.6.25hso/drivers/net/usb/hso.c.alt3	2008-04-21 13:24:47.000000000 +0200
+++ linux-2.6.25hso/drivers/net/usb/hso.c	2008-04-21 13:25:18.000000000 +0200
@@ -2052,7 +2052,7 @@
 	}
 
 	if (serial->tx_urb)
-		usb_kill_urb(serial->rx_urb[i]);
+		usb_kill_urb(serial->tx_urb);
 
 	if (serial->shared_int) {
 		mutex_lock(&serial->shared_int->shared_int_lock);
