From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net: can: usb: peak_usb: pcan_usb_core.c:  Cleaning up
 missing null-terminate in conjunction with strncpy
Date: Mon, 15 Sep 2014 10:42:05 +0200
Message-ID: <5416A65D.6010500@pengutronix.de>
References: <1410715898-15904-1-git-send-email-rickard_strandqvist@spectrumdigital.se> <063D6719AE5E284EB5DD2968C1650D6D17491F2B@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="gihElPFK9THk5gpRP0TgpvLhOhHfQC6a7"
Cc: Oliver Hartkopp <socketcan@hartkopp.net>,
	Stephane Grosjean <s.grosjean@peak-system.com>,
	Alexey Khoroshilov <khoroshilov@ispras.ru>,
	"Christopher R. Baker" <cbaker@rec.ri.cmu.edu>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Rickard Strandqvist' <rickard_strandqvist@spectrumdigital.se>,
	Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17491F2B@AcuExch.aculab.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--gihElPFK9THk5gpRP0TgpvLhOhHfQC6a7
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 09/15/2014 10:28 AM, David Laight wrote:
> From: Rickard Strandqvist
> ...
>> Replacing strncpy with strlcpy to avoid strings that lacks null termin=
ate.
> ...
>> diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> index 644e6ab..d4fe8ac 100644
>> --- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> +++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
>> @@ -830,7 +830,7 @@ static void peak_usb_disconnect(struct usb_interfa=
ce *intf)
>>  		char name[IFNAMSIZ];
>>
>>  		dev->state &=3D ~PCAN_USB_STATE_CONNECTED;
>> -		strncpy(name, netdev->name, IFNAMSIZ);
>> +		strlcpy(name, netdev->name, IFNAMSIZ);
>>
>>  		unregister_netdev(netdev);
>>  		free_candev(netdev);
>=20
> Or:
> 	char name[sizeof netdev->name];
> 	memcpy(name, netdev->name, sizeof netdev->name);

I would be "sizeof(foo)" in kernel coding style, but let's have a look
at the original code:

                struct net_device *netdev =3D dev->netdev;
                char name[IFNAMSIZ];

                dev->state &=3D ~PCAN_USB_STATE_CONNECTED;
                strncpy(name, netdev->name, IFNAMSIZ);

                unregister_netdev(netdev);
                free_candev(netdev);

                kfree(dev->cmd_buf);
                dev->next_siblings =3D NULL;
                if (dev->adapter->dev_free)
                        dev->adapter->dev_free(dev);

                dev_info(&intf->dev, "%s removed\n", name);

I think it's save to use:

    dev_info(&intf->dev, "%s removed\n", netdev_name(dev->netdev));

instead of doing the str?cpy() in the first place. But why not use:

    netdev_info(dev->netdev, "removed\n");

Is the USB device information lost when using netdev_info()?

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--gihElPFK9THk5gpRP0TgpvLhOhHfQC6a7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlQWpmMACgkQjTAFq1RaXHOpOACdFcOvxPW92F8JemLi2xwvF9Za
vFsAn131jCiAO/pSBqCmJWABrckzwIV3
=/Swx
-----END PGP SIGNATURE-----

--gihElPFK9THk5gpRP0TgpvLhOhHfQC6a7--
