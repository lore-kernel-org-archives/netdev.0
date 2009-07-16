From: "=?utf-8?q?R=C3=A9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Thu, 16 Jul 2009 10:12:41 +0300
Message-ID: <200907161012.42452.remi.denis-courmont@nokia.com>
References: <1247666341-7121-1-git-send-email-remi.denis-courmont@nokia.com> <200907151620.31509.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: ext Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:23522 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750905AbZGPHLO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 03:11:14 -0400
In-Reply-To: <200907151620.31509.oliver@neukum.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 15 July 2009 17:20:31 ext Oliver Neukum wrote:
> Am Mittwoch, 15. Juli 2009 15:59:01 schrieb R=C3=A9mi Denis-Courmont:
>
> Hello,
>
> > +	netif_stop_queue(dev);
> > +	if (atomic_inc_return(&pnd->tx_queue) < dev->tx_queue_len)
> > +		netif_wake_queue(dev);
>
> This is unelegant.

But I cannot think of any alternative that would not involve a spin loc=
k and=20
disable IRQs. There is a race between qdisc and USB TX completion here.

I'm not sure what you're trying to suggest...?

> > +static void usbpn_disconnect(struct usb_interface *intf)
> > +{
> > +	struct usbpn_dev *pnd =3D usb_get_intfdata(intf);
> > +
>
> What happens if this happens in the unexpected order?

Right, the data interface gets released twice. This "works" since=20
usb_driver_release_interface() has an explicit check. I will try to cle=
an it=20
up anyway.

> > +	if (intf !=3D pnd->data_intf) {
> > +		usb_driver_release_interface(&usbpn_driver, pnd->data_intf);
> > +		return;
> > +	}
> > +
> > +	unregister_netdev(pnd->dev);
> > +	usb_put_dev(pnd->usb);
> > +}

Thanks for the review.

--=20
R=C3=A9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

