From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Fri, 02 Apr 2010 19:35:08 +0100
Message-ID: <1270233308.12516.145.camel@localhost>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	 <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
	 <1270077538.8653.484.camel@localhost>  <4BB62620.3070807@sysvalve.es>
	 <1270228883.12516.140.camel@localhost>  <4BB62F33.1020507@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, j.dumon-x9gZzRpC1QbQT0dZR+AlfA@public.gmane.org,
	steve.glendinning-sdUf+H5yV5I@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, gregkh-l3A5Bk7waGM@public.gmane.org,
	dgiagio-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Daniel Borca <dborca-/E1597aS9LQAvxtiuMwx3w@public.gmane.org>
To: "\"L. Alberto" =?ISO-8859-1?Q?Gim=E9nez=22?= <agimenez-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4BB62F33.1020507-lqZFv/KUvpAxAGwisGp4zA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2010-04-02 at 19:53 +0200, "L. Alberto Gim=C3=A9nez" wrote:
> On 04/02/2010 07:21 PM, Ben Hutchings wrote:
> > On Fri, 2010-04-02 at 19:15 +0200, "L. Alberto Gim=C3=A9nez" wrote:
> >> On 04/01/2010 01:18 AM, Ben Hutchings wrote:
> >>> On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim=C3=A9nez wrote:
> >>> [...]
> >>>> --- /dev/null
> >>>> +++ b/drivers/net/usb/ipheth.c
> >>> [...]
> >>>> +	usb_fill_bulk_urb(dev->tx_urb, udev,
> >>>> +			  usb_sndbulkpipe(udev, dev->bulk_out),
> >>>> +			  dev->tx_buf, IPHETH_BUF_SIZE,
> >>>> +			  ipheth_sndbulk_callback,
> >>>> +			  dev);
> >>>> +	dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
> >>>> +
> >>>> +	retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
> >>>> +	if (retval) {
> >>>> +		err("%s: usb_submit_urb: %d", __func__, retval);
> >>>> +		dev->stats.tx_errors++;
> >>>> +		dev_kfree_skb_irq(skb);
> >>>> +	} else {
> >>>> +		net->trans_start =3D jiffies;
> >>> No longer needed.
> >> What is not longer needed? The assignment, the whole "else" branch=
? If
> >> the assignment is what is not needed, can I just remove that line,=
 right?
> >=20
> > The assignment is not needed.
>=20
> Hi,
>=20
> I've been looking into this and it seems that the net_device.trans_st=
art
> field is now deprecated in favor of net_device.rx_queue.trans_start
[...]

The networking core updates netdev_queue::trans_start by calling
txq_trans_update() where necessary.  Drivers should not touch either
net_device::trans_start or netdev_queue::trans_start any more.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
