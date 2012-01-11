From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Wed, 11 Jan 2012 10:38:54 +0100
Message-ID: <4F0D58AE.7070601@pengutronix.de>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com> <4F0B7421.6050203@pengutronix.de> <4F0C0552.5080504@grandegger.com> <4F0C2F4A.20500@essax.com> <4F0D4FBA.1080108@essax.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig00B331AFBEC8F11109C88CD5"
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: info@essax.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0D4FBA.1080108@essax.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig00B331AFBEC8F11109C88CD5
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hello,

On 01/11/2012 10:00 AM, Wolfgang Zarre wrote:
>>> Please provide an extra patch for these unrelated changes. If we real=
ly
>>> want to remove it.
>>>
>>
>> Sure, this I can do.
>>
>=20
> Ok, here the patch to remove:

Looks good, please add a patch description and put in a patch series
together with the spinlock patch (see other mail).

Marc

> --------------------------------------------------------
> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc77=
0.c
> index 2d12f89..dad6707 100644
> --- a/drivers/net/can/cc770/cc770.c
> +++ b/drivers/net/can/cc770/cc770.c
> @@ -460,15 +460,6 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff=

> *skb, struct net_device *dev)
>=20
>      stats->tx_bytes +=3D dlc;
>=20
> -
> -    /*
> -     * HM: We had some cases of repeated IRQs so make sure the
> -     * INT is acknowledged I know it's already further up, but
> -     * doing again fixed the issue
> -     */
> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
> -
>      return NETDEV_TX_OK;
>  }
>=20
> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct net_device
> *dev, unsigned int o)
>      /* Nothing more to send, switch off interrupts */
>      cc770_write_reg(priv, msgobj[mo].ctrl0,
>              MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
> -    /*
> -     * We had some cases of repeated IRQ so make sure the
> -     * INT is acknowledged
> -     */
> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>=20
>      stats->tx_packets++;
>      can_get_echo_skb(dev, 0);
> ----------------------------------------------------------

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enig00B331AFBEC8F11109C88CD5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAk8NWK4ACgkQjTAFq1RaXHMPMQCeIwqiUQjpzi/ZTxyzOuFsZxKX
qRUAoIWr7v7jWbhY/KbnzgtKBjgOT2cl
=7qLN
-----END PGP SIGNATURE-----

--------------enig00B331AFBEC8F11109C88CD5--
