From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH 5/7] can: clear ctrlmode when close candev
Date: Mon, 03 Nov 2014 17:28:48 +0100
Message-ID: <5457AD40.7020606@pengutronix.de>
References: <1414579527-31100-1-git-send-email-b29396@freescale.com> <1414579527-31100-5-git-send-email-b29396@freescale.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="2lJ9LQVaE9DOqDG1dl61GOPt5LuUJ29aR"
Cc: wg@grandegger.com, varkabhadram@gmail.com, netdev@vger.kernel.org,
	socketcan@hartkopp.net, linux-arm-kernel@lists.infradead.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: Dong Aisheng <b29396@freescale.com>, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1414579527-31100-5-git-send-email-b29396@freescale.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--2lJ9LQVaE9DOqDG1dl61GOPt5LuUJ29aR
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/29/2014 11:45 AM, Dong Aisheng wrote:
> Currently priv->ctrlmode is not cleared when close_candev, so next time=

> the driver will still use this value to set controller even user
> does not set any ctrl mode.
> e.g.
> Step 1. ip link set can0 up type can0 bitrate 1000000 loopback on
> Controller will be in loopback mode
> Step 2. ip link set can0 down
> Step 3. ip link set can0 up type can0 bitrate 1000000
> Controller will still be set to loopback mode in driver due to saved
> priv->ctrlmode.
>=20
> This patch clears priv->ctrlmode when the CAN interface is closed,
> and set it to correct mode according to next user setting.

Oliver, what do you think of this patch? It will introduce a subtle
change to the userspace.

Marc

> Signed-off-by: Dong Aisheng <b29396@freescale.com>
> ---
>  drivers/net/can/dev.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 02492d2..1fce485 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -671,6 +671,7 @@ void close_candev(struct net_device *dev)
> =20
>  	del_timer_sync(&priv->restart_timer);
>  	can_flush_echo_skb(dev);
> +	priv->ctrlmode =3D 0;
>  }
>  EXPORT_SYMBOL_GPL(close_candev);
> =20
>=20


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--2lJ9LQVaE9DOqDG1dl61GOPt5LuUJ29aR
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUV61AAAoJECte4hHFiupUlvMP/jD0s0xzLWeyLEhmO6stX7cQ
b73fQkkCIbDajtW8/YInAmOB/rXVslFEhrabRsOal6okJ16gUj/B29K4TPJ16lxV
yWAOAZCobQxdX4P5H6aTbqwibjlWk5XdHhQJh/XFKTktTppJo4YAFJ9b4pAJljOe
q8XpIZxO2T92e//K4LRfENLmHvm8WDeMmY7LYhtIqrQgSkGde0B1v3RzJtTls7Lr
78RX48G4Go1ahQTLpEU0vOOUyI11I0NqZgsdmj8WD2cMVIWlBtrbZyg/5u+N9GGv
NNsGhKlW/IE/13H5DicrHhoX7D9Qm+VyEd9Ny05eaOZRgeobM9c2sPwgHTTqjUlN
St5chCQNXnMeDRheZDb5t1rn3Iqf5JRHd7dEgCNzsL4x1xVKxKxJuWQmCcDYwhyc
4uChNYlgBxdJ/eaSZ2yQmMjybGWZEe/askTMAZ7A6DlwYljnU9gpwfgPau3yIwFP
xYt1CClZg2VurvMg9GuCeXgOkaRq9FG00eENkSXI74/LqM8rRCSp/qQr+nxD0Pr5
+qaao1SlJ/74REoBeTceoya0dRDM7u3giY6FjbXFWhuO17/PNUFnjUce4NC4uIbX
QqSTPaSGoJixYZ2LKPet1KmExRjxOMxPT2dUDC0ZeovaG0aJXAI5g32PLBerge+j
LClkChbQszlkbMFXdGmn
=V75R
-----END PGP SIGNATURE-----

--2lJ9LQVaE9DOqDG1dl61GOPt5LuUJ29aR--
