From: Oliver Neukum <oneukum@suse.de>
Subject: Re: [PATCH] cdc-ether: clean packet filter upon probe
Date: Fri, 15 Aug 2014 08:12:01 +0200
Message-ID: <1408083121.17565.4.camel@linux-fkkt.site>
References: <1406537796-20156-1-git-send-email-oneukum@suse.de>
	 <87a977z5pn.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42750 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750992AbaHOGMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2014 02:12:05 -0400
In-Reply-To: <87a977z5pn.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-08-14 at 13:11 +0200, Bj=C3=B8rn Mork wrote:
> Oliver Neukum <oneukum@suse.de> writes:
>=20
> > There are devices that don't do reset all the way. So the packet fi=
lter should
> > be set to a sane initial value. Failure to do so leads to intermitt=
ent failures
> > of DHCP on some systems under some conditions.
> >
> > Signed-off-by: Oliver Neukum <oneukum@suse.de>
> > ---
> >  drivers/net/usb/cdc_ether.c | 16 ++++++++++++++++
> >  1 file changed, 16 insertions(+)
> >
> > diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ethe=
r.c
> > index 9ea4bfe..2a32d91 100644
> > --- a/drivers/net/usb/cdc_ether.c
> > +++ b/drivers/net/usb/cdc_ether.c
> > @@ -341,6 +341,22 @@ next_desc:
> >  		usb_driver_release_interface(driver, info->data);
> >  		return -ENODEV;
> >  	}
> > +
> > +	/* Some devices don't initialise properly. In particular
> > +	 * the packet filter is not reset. There are devices that
> > +	 * don't do reset all the way. So the packet filter should
> > +	 * be set to a sane initial value.
> > +	 */
> > +	usb_control_msg(dev->udev,
> > +			usb_sndctrlpipe(dev->udev, 0),
> > +			USB_CDC_SET_ETHERNET_PACKET_FILTER,
> > +			USB_TYPE_CLASS | USB_RECIP_INTERFACE,
> > +			USB_CDC_PACKET_TYPE_ALL_MULTICAST | USB_CDC_PACKET_TYPE_DIRECTE=
D | USB_CDC_PACKET_TYPE_BROADCAST,
> > +			intf->cur_altsetting->desc.bInterfaceNumber,
> > +			NULL,
> > +			0,
> > +			USB_CTRL_SET_TIMEOUT
> > +		);
> >  	return 0;
> > =20
> >  bad_desc:
>=20
> Hmm, the usbnet_generic_cdc_bind() function is used by the vendor
> specific zaurus and rndis_host drivers as well.  Are we sure the
> USB_CDC_SET_ETHERNET_PACKET_FILTER message is supported by all device=
s
> supported by these drivers?

Support for this request is mandatory.

	Regards
		Oliver
