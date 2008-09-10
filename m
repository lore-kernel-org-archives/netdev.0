From: Denis Joseph Barrow <D.Barow@option.com>
Subject: Re: hso: remove usb_driver_claim_interface()
Date: Wed, 10 Sep 2008 12:44:05 +0200
Message-ID: <48C7A4F5.2070607@option.com>
References: <48C78E15.9030603@teltonika.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:17818 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbYIJKoI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 06:44:08 -0400
In-Reply-To: <48C78E15.9030603@teltonika.lt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paulius,
I'm not in a position yet to know if this patch is good, yet at least.
hso_probe gets called once for each serial ttyHSx device
usually four per usb stick modem & once for the hsox network device
per modem.
 
>From the comment on usb_driver_claim_interface
 * This is used by usb device drivers that need to claim more than one
 * interface on a device when probing (audio and acm are current examples).

I'm not used to USB terminology
>From my understanding of the code
we are claiming more than one interface on the usb modem multiple ttyHSx devices
& one network device. However we get probed once for each interface

We are also calling usb_driver_release_interface from hso_disconnect.
This looks a little asymmetrical to me.

Greg is this patch good? I've no problem with it if it gets your guys blessing.


Index: linux-2.6/drivers/net/usb/hso.c
===================================================================
--- linux-2.6.orig/drivers/net/usb/hso.c
+++ linux-2.6/drivers/net/usb/hso.c
@@ -2487,8 +2487,6 @@ static int hso_probe(struct usb_interfac
 		goto exit;
 	}
 
-	usb_driver_claim_interface(&hso_driver, interface, hso_dev);
-
 	/* save our data pointer in this device */
 	usb_set_intfdata(interface, hso_dev);
 



Paulius Zaleckas wrote:

-- 
best regards,
D.J. Barrow
