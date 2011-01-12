From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next-2.6 v4 1/1] can: c_can: Added support for Bosch
 C_CAN controller
Date: Wed, 12 Jan 2011 10:30:02 +0100
Message-ID: <4D2D749A.7000601@pengutronix.de>
References: <1294746592-12144-1-git-send-email-bhupesh.sharma@st.com>	<4D2C4D68.3070705@pengutronix.de> <D5ECB3C7A6F99444980976A8C6D896384DEAFA31B6@EAPEX1MAIL1.st.com> <4D2D6F95.8030502@grandegger.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC1A2DA3DE3C23DD7C85DFECA"
Cc: Bhupesh SHARMA <bhupesh.sharma@st.com>,
	"Socketcan-core@lists.berlios.de" <Socketcan-core@lists.berlios.de>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:41046 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113Ab1ALJaH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 04:30:07 -0500
In-Reply-To: <4D2D6F95.8030502@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC1A2DA3DE3C23DD7C85DFECA
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 01/12/2011 10:08 AM, Wolfgang Grandegger wrote:
> On 01/12/2011 09:51 AM, Bhupesh SHARMA wrote:
>> Hi Marc,
>>
>> Thanks for your review.
>> Please see my comments inline:
>>
>>> -----Original Message-----
>>> From: Marc Kleine-Budde [mailto:mkl@pengutronix.de]
>>> On 01/11/2011 12:49 PM, Bhupesh Sharma wrote:
> ...
>>>> +static int c_can_close(struct net_device *dev) {
>>>> +   struct c_can_priv *priv =3D netdev_priv(dev);
>>>> +
>>>> +   netif_stop_queue(dev);
>>>> +   napi_disable(&priv->napi);
>>>> +   c_can_stop(dev);
>>>> +   free_irq(dev->irq, dev);
>>>> +   close_candev(dev);
>>>> +
>>>> +   return 0;
>>>> +}
>>>> +
>>>> +struct net_device *alloc_c_can_dev(void)
>>>
>>> Please model after alloc_sja1000_dev:
>>>
>>> struct net_device *alloc_sja1000dev(int sizeof_priv)
>>>
>>> The private for the _user_ of alloc_c_can_dev is behind the sja1000
>>> private, so you can get rid of the void *priv member in the struct
>>> c_can_priv. (see below)
>>
>> Ok.
>> But Wolfgang also suggested to use the *priv* member inside c_can_priv=
 struct
>> for board specific details. In my c_can platform driver I use it to
>> store the *clk* variable. Do I need to change that as well?
>=20
> Marc is referring to:
>=20
> http://lxr.linux.no/#linux+v2.6.37/drivers/net/can/sja1000/sja1000.c#L5=
82
>=20
> But also there "priv->priv" is used to store a pointer to the board
> specific details. Looking to the SJA1000 drivers, only *one* uses
> "sizeof_priv > 0", but many other attach a separately allocated
> structure to "priv->priv". For that reason, I'm fine with your current
> implementation.

Okay fine with me.

A nice cleanup might be to introduce something like this:

static inline void * give_me_my_priv_from_sja1000_priv
	(struct sja1000_priv *priv)
{
	return (void *)(priv + 1);
}

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC1A2DA3DE3C23DD7C85DFECA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk0tdJ0ACgkQjTAFq1RaXHO0PACfbsCQboL3X51A9JZ1ivyHEA6f
dMAAn2RuDZQITDWgs4p9gpifvP5jVPwW
=nCiX
-----END PGP SIGNATURE-----

--------------enigC1A2DA3DE3C23DD7C85DFECA--
