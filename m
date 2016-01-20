From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 17:19:18 +0100
Message-ID: <87k2n4fcl5.fsf@nemi.mork.no>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mkl@pengutronix.de, wg@grandegger.com, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@pengutronix.de
To: Michael Grzeschik <m.grzeschik@pengutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
	(Michael Grzeschik's message of "Wed, 20 Jan 2016 14:44:03 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Grzeschik <m.grzeschik@pengutronix.de> writes:

> @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *dev)
>  	 */
>  	pinctrl_pm_select_sleep_state(dev->dev.parent);
> =20
> +	priv->reg_xceiver =3D devm_regulator_get(priv->device, "xceiver");
> +	if (IS_ERR(priv->reg_xceiver))
> +		return PTR_ERR(priv->reg_xceiver);
> +
>  	c_can_pm_runtime_enable(priv);
> =20
>  	dev->flags |=3D IFF_ECHO;	/* we support local echo */

Do you really want to leave priv->reg_xceiver pointing to an ERR_PTR in
case of error?



Bj=C3=B8rn
