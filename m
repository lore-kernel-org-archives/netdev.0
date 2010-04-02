From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Fri, 02 Apr 2010 18:21:23 +0100
Message-ID: <1270228883.12516.140.camel@localhost>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>
	 <1270064527-8485-1-git-send-email-agimenez@sysvalve.es>
	 <1270077538.8653.484.camel@localhost>  <4BB62620.3070807@sysvalve.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, oliver@neukum.org,
	linville@tuxdriver.com, j.dumon@option.com,
	steve.glendinning@smsc.com, davem@davemloft.net, gregkh@suse.de,
	dgiagio@gmail.com, dborca@yahoo.com
To: "\"L. Alberto" =?ISO-8859-1?Q?Gim=E9nez=22?= <agimenez@sysvalve.es>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48591 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755525Ab0DBRVc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Apr 2010 13:21:32 -0400
In-Reply-To: <4BB62620.3070807@sysvalve.es>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-04-02 at 19:15 +0200, "L. Alberto Gim=C3=A9nez" wrote:
> On 04/01/2010 01:18 AM, Ben Hutchings wrote:
> > On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim=C3=A9nez wrote:
> > [...]
> >> --- /dev/null
> >> +++ b/drivers/net/usb/ipheth.c
> > [...]
>=20
> Hi Ben,
>=20
> Upstream has fixed several errors pointed out by you and Oliver (than=
ks
> for that), but some of them are still pending.
>=20
> I will send patches on top of my last driver submission (if the prope=
r
> way would be resubmit the whole code, please tell me. Anyway I need t=
o
> clarify some doubts...

Since David Miller has not merged your original patch, you should send =
a
single new patch with the changes incorporated.

> >> +	usb_fill_bulk_urb(dev->tx_urb, udev,
> >> +			  usb_sndbulkpipe(udev, dev->bulk_out),
> >> +			  dev->tx_buf, IPHETH_BUF_SIZE,
> >> +			  ipheth_sndbulk_callback,
> >> +			  dev);
> >> +	dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
> >> +
> >> +	retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
> >> +	if (retval) {
> >> +		err("%s: usb_submit_urb: %d", __func__, retval);
> >> +		dev->stats.tx_errors++;
> >> +		dev_kfree_skb_irq(skb);
> >> +	} else {
> >> +		net->trans_start =3D jiffies;
> >=20
> > No longer needed.
>=20
> What is not longer needed? The assignment, the whole "else" branch? I=
f
> the assignment is what is not needed, can I just remove that line, ri=
ght?

The assignment is not needed.

> > [...]
> >> +#ifdef HAVE_NET_DEVICE_OPS
> >> +static const struct net_device_ops ipheth_netdev_ops =3D {
> >> +       .ndo_open =3D &ipheth_open,
> >> +       .ndo_stop =3D &ipheth_close,
> >> +       .ndo_start_xmit =3D &ipheth_tx,
> >> +       .ndo_tx_timeout =3D &ipheth_tx_timeout,
> >> +       .ndo_get_stats =3D &ipheth_stats,
> >> +};
> >> +#endif
> >=20
> > Remove the #ifdef, there is no question whether we have net_device_=
ops.
>=20
> Ok, I will just remove both #ifdefs, but why is that? Maybe in previo=
us
> versions of the kernel the net_device_ops struct was introduced and n=
ow
> it's present no matter how you configure your kernel?
[...]

Correct, it is now mandatory.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

