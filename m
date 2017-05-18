From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [PATCH] cdc-ether: divorce initialisation with a filter reset
 and a generic method
Date: Thu, 18 May 2017 12:36:34 +0200
Message-ID: <1495103794.6672.5.camel@suse.com>
References: <20170518082328.10094-1-oneukum@suse.com>
         <8737c2eat4.fsf@miraculix.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46501 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754508AbdERKiF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 18 May 2017 06:38:05 -0400
In-Reply-To: <8737c2eat4.fsf@miraculix.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, den 18.05.2017, 12:09 +0200 schrieb Bjørn Mork:
> Oliver Neukum <oneukum@suse.com> writes:
> 
> > 
> > @@ -417,7 +434,7 @@ int usbnet_cdc_bind(struct usbnet *dev, struct usb_interface *intf)
> >  	BUILD_BUG_ON((sizeof(((struct usbnet *)0)->data)
> >  			< sizeof(struct cdc_state)));
> >  
> > -	status = usbnet_generic_cdc_bind(dev, intf);
> > +	status = usbnet_ether_cdc_bind(dev, intf);
> >  	if (status < 0)
> >  		return status;
> >  
> > @@ -472,7 +489,6 @@ static void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
> >  
> >  	if (urb->actual_length < sizeof(*event))
> >  		return;
> > -
> >  	event = urb->transfer_buffer;
> >  
> >  	if (event->bNotificationType != USB_CDC_NOTIFY_NETWORK_CONNECTION) {
> > @@ -493,7 +509,7 @@ static void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
> >  static const struct driver_info	cdc_info = {
> >  	.description =	"CDC Ethernet Device",
> >  	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
> > -	.bind =		usbnet_cdc_bind,
> > +	.bind =		usbnet_ether_cdc_bind,
> >  	.unbind =	usbnet_cdc_unbind,
> >  	.status =	usbnet_cdc_status,
> >  	.set_rx_mode =	usbnet_cdc_update_filter,
> 
> 
> I didn't quite get this.  You change the call in usbnet_cdc_bind() from
> usbnet_generic_cdc_bind() to usbnet_ether_cdc_bind(), which I believe is
> fine.  But then you update the .bind hook to point to usbnet_ether_cdc_bind.
> Why?  The only effect I can see is that usbnet_get_ethernet_addr() is
> skipped. That can't be correct?

You are right. I am an idiot. I wanted to target RNDIS and missed totally.
Thanks.

Dave please trash the patch.

	Regards
		Oliver
