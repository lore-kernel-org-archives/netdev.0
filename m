From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Tue, 15 Apr 2008 22:17:21 +0200
Message-ID: <200804152217.25451.oliver@neukum.org>
References: <20080414213238.GB28833@kroah.com> <200804152046.44018.oliver@neukum.org> <20080415190030.GB27608@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Filip Aben <f.aben@option.com>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	ajb@spheresystems.co.uk
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:47113 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbYDOURz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2008 16:17:55 -0400
In-Reply-To: <20080415190030.GB27608@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 15. April 2008 21:00:30 schrieb Greg KH:
> > Do you have a new unified patch? I'd work against that, lest we get
> > merge troubles.
> 
> Good idea :)
> 
> Here it is.

Against that one.

Change GFP_KERNEL used in interrupt and resume() to GFP_ATOMIC,
respectively GFP_NOIO

Signed-off-by: Oliver Neukum <oneukum@suse.de>

---

--- a/drivers/net/usb/hso.c	2008-04-15 21:48:10.000000000 +0200
+++ b/drivers/net/usb/hso.c	2008-04-15 21:52:48.000000000 +0200
@@ -1663,7 +1663,7 @@ static void intr_callback(struct urb *ur
 		}
 	}
 	/* Resubmit interrupt urb */
-	hso_mux_submit_intr_urb(shared_int, urb->dev, GFP_KERNEL);
+	hso_mux_submit_intr_urb(shared_int, urb->dev, GFP_ATOMIC);
 }
 
 /* called for writing to muxed serial port */
@@ -1694,7 +1694,7 @@ static int hso_std_serial_write_data(str
 			  serial->tx_data, serial->tx_data_count,
 			  hso_std_serial_write_bulk_callback, serial);
 
-	result = usb_submit_urb(serial->tx_urb, GFP_KERNEL);
+	result = usb_submit_urb(serial->tx_urb, GFP_ATOMIC);
 	if (result) {
 		dev_warn(&serial->parent->usb->dev,
 			 "Failed to submit urb - res %d\n", result);
@@ -2040,7 +2040,7 @@ static int hso_start_net_device(struct h
 
 		/* Put it out there so the device can send us stuff */
 		result = usb_submit_urb(hso_net->mux_bulk_rx_urb_pool[i],
-					GFP_KERNEL);
+					GFP_NOIO);
 		if (result)
 			dev_warn(&hso_dev->usb->dev,
 				"%s failed mux_bulk_rx_urb[%d] %d\n", __func__,
@@ -2104,7 +2104,7 @@ static int hso_start_serial_device(struc
 		if (!serial->shared_int->use_count) {
 			result =
 			    hso_mux_submit_intr_urb(serial->shared_int,
-						    hso_dev->usb, GFP_KERNEL);
+						    hso_dev->usb, GFP_ATOMIC);
 		}
 		serial->shared_int->use_count++;
 		spin_unlock_bh(&serial->shared_int->shared_int_lock);
