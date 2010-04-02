From: =?UTF-8?B?IkwuIEFsYmVydG8gR2ltw6luZXoi?= <agimenez@sysvalve.es>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Fri, 02 Apr 2010 19:15:12 +0200
Message-ID: <4BB62620.3070807@sysvalve.es>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es>	 <1270064527-8485-1-git-send-email-agimenez@sysvalve.es> <1270077538.8653.484.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, oliver@neukum.org,
	linville@tuxdriver.com, j.dumon@option.com,
	steve.glendinning@smsc.com, davem@davemloft.net, gregkh@suse.de,
	dgiagio@gmail.com, dborca@yahoo.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270077538.8653.484.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/01/2010 01:18 AM, Ben Hutchings wrote:
> On Wed, 2010-03-31 at 21:42 +0200, L. Alberto Gim=C3=A9nez wrote:
> [...]
>> --- /dev/null
>> +++ b/drivers/net/usb/ipheth.c
> [...]

Hi Ben,

Upstream has fixed several errors pointed out by you and Oliver (thanks
for that), but some of them are still pending.

I will send patches on top of my last driver submission (if the proper
way would be resubmit the whole code, please tell me. Anyway I need to
clarify some doubts...

>> +	usb_fill_bulk_urb(dev->tx_urb, udev,
>> +			  usb_sndbulkpipe(udev, dev->bulk_out),
>> +			  dev->tx_buf, IPHETH_BUF_SIZE,
>> +			  ipheth_sndbulk_callback,
>> +			  dev);
>> +	dev->tx_urb->transfer_flags |=3D URB_NO_TRANSFER_DMA_MAP;
>> +
>> +	retval =3D usb_submit_urb(dev->tx_urb, GFP_ATOMIC);
>> +	if (retval) {
>> +		err("%s: usb_submit_urb: %d", __func__, retval);
>> +		dev->stats.tx_errors++;
>> +		dev_kfree_skb_irq(skb);
>> +	} else {
>> +		net->trans_start =3D jiffies;
>=20
> No longer needed.

What is not longer needed? The assignment, the whole "else" branch? If
the assignment is what is not needed, can I just remove that line, righ=
t?

> [...]
>> +#ifdef HAVE_NET_DEVICE_OPS
>> +static const struct net_device_ops ipheth_netdev_ops =3D {
>> +       .ndo_open =3D &ipheth_open,
>> +       .ndo_stop =3D &ipheth_close,
>> +       .ndo_start_xmit =3D &ipheth_tx,
>> +       .ndo_tx_timeout =3D &ipheth_tx_timeout,
>> +       .ndo_get_stats =3D &ipheth_stats,
>> +};
>> +#endif
>=20
> Remove the #ifdef, there is no question whether we have net_device_op=
s.

Ok, I will just remove both #ifdefs, but why is that? Maybe in previous
versions of the kernel the net_device_ops struct was introduced and now
it's present no matter how you configure your kernel?

> I have no idea about USB so I haven't checked the USB API usage at al=
l.

I think that Greg is the maintainer for the USB subsystem, so if he has
no further commets, I will try to submit fixes for both your and
Oliver's comments along with the upstream developers.

Thanks for your comments.


Best regards,
--=20
L. Alberto Gim=C3=A9nez
JabberID agimenez@jabber.sysvalve.es
GnuPG key ID 0x3BAABDE1
