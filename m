From: Markus Pargmann <mpa@pengutronix.de>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 15:01:18 +0100
Message-ID: <2136394.8KvYBfKku7@adelgunde>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart2510196.RoLemYplT6"; micalg="pgp-sha256"; protocol="application/pgp-signature"
Cc: Michael Grzeschik <m.grzeschik@pengutronix.de>, mkl@pengutronix.de,
	wg@grandegger.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-can@vger.kernel.org
To: kernel@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.4.pengutronix.de ([92.198.50.35]:32915 "EHLO
	metis.ext.4.pengutronix.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751205AbcATOBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jan 2016 09:01:21 -0500
In-Reply-To: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart2510196.RoLemYplT6
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

Hi,

On Wednesday 20 January 2016 14:44:03 Michael Grzeschik wrote:
> This patch adds support to enable and disable the xceiver
> in case it's switchable by the regulator framework.
>=20
> Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>

Reviewed-by: Markus Pargmann <mpa@pengutronix.de>

> ---
> v1 -> v2:
>  - always returning PTR_ERR in case devm_regulator_get fails
>  - removed inline wrapper functions with checks for xceiver =3D=3D NU=
LL
>=20
>  drivers/net/can/c_can/c_can.c | 12 ++++++++++++
>  drivers/net/can/c_can/c_can.h |  1 +
>  2 files changed, 13 insertions(+)
>=20
> diff --git a/drivers/net/can/c_can/c_can.c b/drivers/net/can/c_can/c_=
can.c
> index f91b094..0723aeb 100644
> --- a/drivers/net/can/c_can/c_can.c
> +++ b/drivers/net/can/c_can/c_can.c
> @@ -36,6 +36,7 @@
>  #include <linux/io.h>
>  #include <linux/pm_runtime.h>
>  #include <linux/pinctrl/consumer.h>
> +#include <linux/regulator/consumer.h>
> =20
>  #include <linux/can.h>
>  #include <linux/can/dev.h>
> @@ -612,6 +613,10 @@ static int c_can_start(struct net_device *dev)
>  =09else
>  =09=09pinctrl_pm_select_default_state(priv->device);
> =20
> +=09err =3D regulator_enable(priv->reg_xceiver);
> +=09if (err)
> +=09=09return err;
> +
>  =09return 0;
>  }
> =20
> @@ -626,6 +631,9 @@ static void c_can_stop(struct net_device *dev)
> =20
>  =09/* deactivate pins */
>  =09pinctrl_pm_select_sleep_state(dev->dev.parent);
> +
> +=09regulator_disable(priv->reg_xceiver);
> +
>  =09priv->can.state =3D CAN_STATE_STOPPED;
>  }
> =20
> @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *dev)=

>  =09 */
>  =09pinctrl_pm_select_sleep_state(dev->dev.parent);
> =20
> +=09priv->reg_xceiver =3D devm_regulator_get(priv->device, "xceiver")=
;
> +=09if (IS_ERR(priv->reg_xceiver))
> +=09=09return PTR_ERR(priv->reg_xceiver);
> +
>  =09c_can_pm_runtime_enable(priv);
> =20
>  =09dev->flags |=3D IFF_ECHO;=09/* we support local echo */
> diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_=
can.h
> index 8acdc7f..59246e3 100644
> --- a/drivers/net/can/c_can/c_can.h
> +++ b/drivers/net/can/c_can/c_can.h
> @@ -213,6 +213,7 @@ struct c_can_priv {
>  =09u32 comm_rcv_high;
>  =09u32 rxmasked;
>  =09u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
> +=09struct regulator *reg_xceiver;
>  };
> =20
>  struct net_device *alloc_c_can_dev(void);
>=20

=2D-=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |

--nextPart2510196.RoLemYplT6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJWn5MvAAoJEEpcgKtcEGQQ8t8QAKKYiJjJm6ySSPfM9tFAms5q
DRPAhSXB31PLVBdTkyFczWqt5x6p6sohhBnLnSA78pCQa9aJ2wDFIqQ7uS//mOqk
/ZucfWmapbcwWBIgYa9T1m07lKPVIXOcY4cdMRZnfQ17q1rKcBZUf83C874CzNBP
sNE0FBqqpAwLC8hL9QJ0CxVtGVbDQN1JM8ZNfn8H1pK7UeNKLHPVxTJb59eCPSLH
rUxH07KLGDSuEBhidsbOivPYKMLL8KMSVQ8Q2Q2rpJZ8WuOsZfZMBrGupW1qztrz
YlDg6FmsWkBT++oOiaL9qWezVsSrPN/RwYZovwFwGtDp8s8WsyuOYHl/zFrLGZ/9
t55ItOzemJtsGeqsfznYVVYVshosuIZDPP2is7ooYKR/JOcycxkSU5De/NxlHX6T
m2yf0YSkxekIeiQhqlhtHiN2ZvCDJF16X8KZ1HLSbk7JgtLCLj9wbgXV+cywPlKE
+Cb87CzIgEPKSyeOeZrVLPvZxvBK3TlYwAchrb3shGOusR6gNp3B1c+B9+SRykUn
bhGQ2A7ux1b2hxMrat0FvI9oJ+m9nBJ5f7afyovl5yartrgmDBmZvKKXo25aMQgU
vMmizeGbbm60PA6LucPxFO/gyNm7bnR3zwwMI1iiYZ0MlYdkSKhoiNQDl7vg/tD4
DLAY7StoPKR7WPsfH15k
=NX7C
-----END PGP SIGNATURE-----

--nextPart2510196.RoLemYplT6--
