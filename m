From: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Subject: Re: [PATCH v5] can: xilinx CAN controller support.
Date: Tue, 11 Mar 2014 15:31:12 +0100
Message-ID: <531F1E30.4040203@pengutronix.de>
References: <5254bfec-c6fd-4681-a34d-706d51e60fbb@VA3EHSMHS004.ehs.local> <531DD2C4.5060109@pengutronix.de> <f1e2f08f-05fc-40d3-8437-4c6817d631cb@AM1EHSMHS010.ehs.local> <531F0636.4050608@pengutronix.de> <a99feda0-7463-4781-bb73-90b99e65b014@CO9EHSMHS028.ehs.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="s6hbhFM2k7JuRJMTdBPESiGGTKRN0GCnw"
Cc: "linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org" <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Michal Simek <michals-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>,
	"wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org" <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>,
	"fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org" <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Soren Brinkmann <sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
To: Appana Durga Kedareswara Rao <appana.durga.rao-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a99feda0-7463-4781-bb73-90b99e65b014-QhSrsHip19sNTaRkHJHP0bjjLBE8jN/0@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--s6hbhFM2k7JuRJMTdBPESiGGTKRN0GCnw
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 03/11/2014 03:08 PM, Appana Durga Kedareswara Rao wrote:

>>>>> +   struct napi_struct napi;
>>>>> +   u32 (*read_reg)(const struct xcan_priv *priv, enum xcan_reg reg=
);
>>>>> +   void (*write_reg)(const struct xcan_priv *priv, enum xcan_reg r=
eg,
>>>>> +                   u32 val);
>>>>> +   struct net_device *dev;
>>>>> +   void __iomem *reg_base;
>>>>> +   unsigned long irq_flags;
>>>>> +   struct clk *aperclk;
>>>>> +   struct clk *devclk;
>>>>
>>>> Please rename the clock variables to match the names in the DT.
>>>>
>>> The clock names are different for axi CAN and CANPS case.
>>> So will make them as busclk and devclk Are you ok with this?
>>
>> Why not "ref_clk" and "aper_clk" as used in the DT?
>>
> One of the comments I got from the Soren(sorenb-gjFFaj9aHVfQT0dZR+AlfA@public.gmane.org)
> Is the  clock-names must match the data sheet.
> If I Modify the clock names then it is different names for AXI CAN
> and CANPS case.

Sorry, my faul, I thought the names are already these from the
datasheet. As S=C3=B6ren pointed out please use 's_axi_aclk' and
'can_clk' for the DT and for the the variable names in the private
struct, too.

The 'official' name of the ip core seems to be axi_can, should we rename
the driver? I suspect, that Michal wants to keep xilinx in the name for
marketing reasons :P

[...]

>>>>> +/**
>>>>> + * xcan_chip_start - This the drivers start routine
>>>>> + * @ndev:  Pointer to net_device structure
>>>>> + *
>>>>> + * This is the drivers start routine.
>>>>> + * Based on the State of the CAN device it puts
>>>>> + * the CAN device into a proper mode.
>>>>> + *
>>>>> + * Return: 0 on success and failure value on error  */ static int
>>>>> +xcan_chip_start(struct net_device *ndev) {
>>>>> +   struct xcan_priv *priv =3D netdev_priv(ndev);
>>>>> +   u32 err;
>>>>> +   unsigned long timeout;
>>>>> +
>>>>> +   /* Check if it is in reset mode */
>>>>> +   err =3D set_reset_mode(ndev);
>>>>> +   if (err < 0)
>>>>> +           return err;
>>>>> +
>>>>> +   err =3D xcan_set_bittiming(ndev);
>>>>> +   if (err < 0)
>>>>> +           return err;
>>>>> +
>>>>> +   /* Enable interrupts */
>>>>> +   priv->write_reg(priv, XCAN_IER_OFFSET, XCAN_INTR_ALL);
>>>>> +
>>>>> +   /* Check whether it is loopback mode or normal mode  */
>>>>> +   if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
>>>>> +           /* Put device into loopback mode */
>>>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET,
>>>> XCAN_MSR_LBACK_MASK);
>>>>> +   else
>>>>> +           /* The device is in normal mode */
>>>>> +           priv->write_reg(priv, XCAN_MSR_OFFSET, 0);
>>>>> +
>>>>> +   if (priv->can.state =3D=3D CAN_STATE_STOPPED) {
>>>>
>>>> Your device is in stopped mode, add you go though set_reset_mode()
>>>> already.
>>>
>>> Will remove this if condition I putted this condition here because in=

>>> set_reset_mode we are putting the Device state in Stopped state.
>>
>> So the device is in CAN_STATE_STOPPED, as this code just went through
>> set_reset_mode() some lines ago. so it makes no sense to check if it
>> (still) is (the code runs serialized here).
>>
>=20
> After removing the if condition and the line(CAN_STATE_STOPPED from
> the set_reset_mode) the code for chip_start is below It is better to
> check whether it is really Configured in the loopback or normal mode=20
> That's why kept the loops as it is.
>=20
> static int xcan_chip_start(struct net_device *ndev)
> {
>         struct xcan_priv *priv =3D netdev_priv(ndev);
>         u32 err;
>         unsigned long timeout;
>=20
>         /* Check if it is in reset mode */
>         err =3D set_reset_mode(ndev);
>         if (err < 0)
>                 return err;
>=20
>         err =3D xcan_set_bittiming(ndev);
>         if (err < 0)
>                 return err;
>=20
>         /* Enable interrupts */
>         priv->write_reg(priv, XCAN_IER_OFFSET, XCAN_INTR_ALL);
>=20
>         /* Check whether it is loopback mode or normal mode  */
>         if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK)
>                 /* Put device into loopback mode */
>                 priv->write_reg(priv, XCAN_MSR_OFFSET, XCAN_MSR_LBACK_M=
ASK);
>         else
>                 /* The device is in normal mode */
>                 priv->write_reg(priv, XCAN_MSR_OFFSET, 0);

What about using two temp variables? Like this (untested, though):

	u32 reg_msg;
	u32 reg_sr_mask;

	if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
		reg_msr =3D XCAN_MSR_LBACK_MASK;
		reg_sr_mask =3D XCAN_SR_LBACK_MASK;
	} else {
		reg_msr =3D 0x0;
		reg_sr_mask =3D XCAN_SR_NORMAL_MASK;
	}

	priv->write_reg(priv, XCAN_MSR_OFFSET, reg_msr);
	priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);

	timeout =3D jiffies + XCAN_TIMEOUT;
	while (!(priv->read_reg(priv, XCAN_SR_OFFSET) & reg_sr_mask)) {
		if (time_after(jiffies, timeout)) {
			netdev_warn(ndev, "time out waiting for correct mode\n")
			return -ETIMEDOUT;
			}
		usleep_range(500, 10000);
	}

>=20
>         priv->write_reg(priv, XCAN_SRR_OFFSET, XCAN_SRR_CEN_MASK);
>         timeout =3D jiffies + XCAN_TIMEOUT;
>         if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>                 while ((priv->read_reg(priv, XCAN_SR_OFFSET)
>                                 & XCAN_SR_LBACK_MASK) =3D=3D 0) {
>                         if (time_after(jiffies, timeout)) {
>                                 netdev_warn(ndev,
>                                         "timedout for loopback mode\n")=
;
>                                 return -ETIMEDOUT;
>                         }
>                         usleep_range(500, 10000);
>                 }
>         } else {
>                 while ((priv->read_reg(priv, XCAN_SR_OFFSET)
>                                 & XCAN_SR_NORMAL_MASK) =3D=3D 0) {
>                         if (time_after(jiffies, timeout)) {
>                                 netdev_warn(ndev,
>                                         "timedout for normal mode\n");
>                                 return -ETIMEDOUT;
>                         }
>                         usleep_range(500, 10000);
>                 }
>         }
>         netdev_dbg(ndev, "status:#x%08x\n",
>                         priv->read_reg(priv, XCAN_SR_OFFSET));
>=20
>         priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
>         return 0;
> }

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--s6hbhFM2k7JuRJMTdBPESiGGTKRN0GCnw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Using GnuPG with Icedove - http://www.enigmail.net/

iEYEARECAAYFAlMfHjAACgkQjTAFq1RaXHPucACgklJJ6wu+OQoyQs41gCD9WM/t
uW8AnAmGAiSzSZZftZT9G3wZ2KY0N4xg
=EpQl
-----END PGP SIGNATURE-----

--s6hbhFM2k7JuRJMTdBPESiGGTKRN0GCnw--
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
