From: Michael Grzeschik <mgr@pengutronix.de>
Subject: Re: [PATCH v2] can: c_can: add xceiver enable/disable support
Date: Wed, 20 Jan 2016 17:46:40 +0100
Message-ID: <20160120164640.GC14234@pengutronix.de>
References: <1453297443-23279-1-git-send-email-m.grzeschik@pengutronix.de>
 <87k2n4fcl5.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-can@vger.kernel.org, mkl@pengutronix.de,
	kernel@pengutronix.de, wg@grandegger.com
To: =?iso-8859-15?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <87k2n4fcl5.fsf@nemi.mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Wed, Jan 20, 2016 at 05:19:18PM +0100, Bj=F8rn Mork wrote:
> Michael Grzeschik <m.grzeschik@pengutronix.de> writes:
>=20
> > @@ -1263,6 +1271,10 @@ int register_c_can_dev(struct net_device *de=
v)
> >  	 */
> >  	pinctrl_pm_select_sleep_state(dev->dev.parent);
> > =20
> > +	priv->reg_xceiver =3D devm_regulator_get(priv->device, "xceiver")=
;
> > +	if (IS_ERR(priv->reg_xceiver))
> > +		return PTR_ERR(priv->reg_xceiver);
> > +
> >  	c_can_pm_runtime_enable(priv);
> > =20
> >  	dev->flags |=3D IFF_ECHO;	/* we support local echo */
>=20
> Do you really want to leave priv->reg_xceiver pointing to an ERR_PTR =
in
> case of error?

No, therefore the priv->reg_xceiver will be returned in case of error.
This codepath is called once on device registration.

Michael

--=20
Pengutronix e.K.                           |                           =
  |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
Peiner Str. 6-8, 31137 Hildesheim, Germany | Phone: +49-5121-206917-0  =
  |
Amtsgericht Hildesheim, HRA 2686           | Fax:   +49-5121-206917-555=
5 |
