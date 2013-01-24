From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [RFC] net: usbnet: prevent buggy devices from killing us
Date: Thu, 24 Jan 2013 05:01:09 -0800
Message-ID: <1359032469.2704.7.camel@joe-AO722>
References: <1359023152-32576-1-git-send-email-bjorn@mork.no>
	 <51012B76.1060600@mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn-yOkvZcmFvRU@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sergei Shtylyov <sshtylyov-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51012B76.1060600-Igf4POYTYCDQT0dZR+AlfA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-24 at 16:39 +0400, Sergei Shtylyov wrote:
> On 24-01-2013 14:25, Bj=F8rn Mork wrote:
> > A device sending 0 length frames as fast as it can has been
> > observed killing the host system due to the resulting memory
> > pressure.
[]
> > diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
[]
> > +	/* Do not let a device flood us to death! */
> > +	if (dev->done.qlen > 1024) {
> > +		netif_dbg(dev, rx_err, dev->net, "done queue filling up (%u) - t=
hrottling\n", dev->done.qlen);
> > +		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
> > +		usb_free_urb (urb);
>=20
>     Run your patch thru scripts/checkpatch.pl please

And maybe ratelimit the netif_dbg

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
