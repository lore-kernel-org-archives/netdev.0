From: =?UTF-8?B?IkwuIEFsYmVydG8gR2ltw6luZXoi?= <agimenez@sysvalve.es>
Subject: Re: [PATCHv3] drivers/net/usb: Add new driver ipheth
Date: Fri, 02 Apr 2010 20:23:21 +0200
Message-ID: <4BB63619.6070607@sysvalve.es>
References: <1269984864-28159-1-git-send-email-agimenez@sysvalve.es> <1270064527-8485-1-git-send-email-agimenez@sysvalve.es> <201003312233.26130.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linville@tuxdriver.com,
	j.dumon@option.com, steve.glendinning@smsc.com,
	davem@davemloft.net, gregkh@suse.de, dgiagio@gmail.com,
	dborca@yahoo.com
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from capside.net ([81.19.98.74]:56364 "EHLO eul0600410.eu.verio.net"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750735Ab0DBSX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 14:23:28 -0400
In-Reply-To: <201003312233.26130.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/31/2010 10:33 PM, Oliver Neukum wrote:
> Am Mittwoch, 31. M=C3=A4rz 2010 21:42:07 schrieb L. Alberto Gim=C3=A9=
nez:

Hi Oliver,

Just like with Ben's comments I still have a couple of doubts about you=
r
comments.


>> +
>> +static int ipheth_open(struct net_device *net)
>> +{
>> +	struct ipheth_device *dev =3D netdev_priv(net);
>> +	struct usb_device *udev =3D dev->udev;
>> +	int retval =3D 0;
>> +
>> +	usb_set_interface(udev, IPHETH_INTFNUM, IPHETH_ALT_INTFNUM);
>> +	usb_clear_halt(udev, usb_rcvbulkpipe(udev, dev->bulk_in));
>> +	usb_clear_halt(udev, usb_sndbulkpipe(udev, dev->bulk_out));
>=20
> Is this really needed? If so, please add a comment.

I understand that usb_clear_halt is only needed when the device has
transmitted data, and as it is "open" time, we can assume that no
transmissions ere made, so we don't need to clear anything (aka: remove
both lines), am I right?


>> +
>> +	retval =3D ipheth_carrier_set(dev);
>> +	if (retval)
>> +		goto error;
>> +
>> +	retval =3D ipheth_rx_submit(dev, GFP_KERNEL);
>> +	if (retval)
>> +		goto error;
>> +
>> +	schedule_delayed_work(&dev->carrier_work, IPHETH_CARRIER_CHECK_TIM=
EOUT);
>=20
> Does it make sense to start rx while you have no carrier?

Well, I have no clue about this one. I think that upstream developers
should take a look into this (Dario, Daniel, could you?) since I don't
have the knowledge to decide what to do about it.

But I assume that as with the previous one, we have just opened the
device and we aren't (yet) doing anything with it, so we shouldn't star=
t rx?

>> +static void ipheth_disconnect(struct usb_interface *intf)
>> +{
>> +	struct ipheth_device *dev;
>> +
>> +	dev =3D usb_get_intfdata(intf);
>> +	if (dev !=3D NULL) {
>=20
> is this check needed?

Does usb_get_infdata always return not NULL? I haven't found anything
about it (just manual pages for the function, but can't spot if it
cannot return NULL). We disconnected the device, but I understand that
the kernel still has the information and the allocated memory, so the
cleanup code is still needed, isn't it?


>=20
>> +static struct usb_driver ipheth_driver =3D {
>> +	.name =3D		"ipheth",
>> +	.probe =3D	ipheth_probe,
>> +	.disconnect =3D	ipheth_disconnect,
>> +	.id_table =3D	ipheth_table,
>> +	.supports_autosuspend =3D 0,
>=20
> redundant

Why?

Thanks a lot in advance.


Best regards,
--=20
L. Alberto Gim=C3=A9nez
JabberID agimenez@jabber.sysvalve.es
GnuPG key ID 0x3BAABDE1
