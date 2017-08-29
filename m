From: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: RE: [patch v1 1/2] dt-bindings: net: add binding documentation for
 mlxsw thermal control
Date: Tue, 29 Aug 2017 17:57:01 +0000
Message-ID: <AM4PR05MB33300CC580ADD6CDABD13167A29F0@AM4PR05MB3330.eurprd05.prod.outlook.com>
References: <1504032311-195988-1-git-send-email-vadimp@mellanox.com>
 <1504032311-195988-2-git-send-email-vadimp@mellanox.com>
 <20170829172254.GG8235@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org" <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org" <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>,
        "ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170829172254.GG8235-g2DYL2Zd6BY@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew-g2DYL2Zd6BY@public.gmane.org]
> Sent: Tuesday, August 29, 2017 8:23 PM
> To: Vadim Pasternak <vadimp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Cc: robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org; davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org; jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org;
> ivecera-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org; devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> Subject: Re: [patch v1 1/2] dt-bindings: net: add binding documentation f=
or
> mlxsw thermal control
>=20
> > +- compatible		: "mellanox,mlxsw_minimal"
>=20
> Interesting product name. Is there a mlxsw_maximal planned?
>=20

Hi Andrew,

Thank you very much for review.

No plans for such product. We just have fully functional drivers for differ=
ent
kind of Mellanox switch devices like spectrum, switchib, switchx2. All of t=
hem
work over PCI bus. The minimal is supposed to be used for the chassis
management and we uses it at BMC side. It works over I2C bus and doesn't
depend on switch type. So it has a minaml functionality, so name "minimal".

> > +- reg			: The I2C address of the device.
> > +
> > +Optional properties:
> > +- cooling-phandle	: phandle of the cooling device, which is to be used
> > +			  for the zone thermal control.
> > +			  If absent, cooling device controlled internally by
> > +			  the ASIC may be used.
> > +
> > +- trips			: the nodes to describe a point in the
> temperature
> > +			  domain with key temperatures at which cooling is
> > +			  recommended. Each node must contain the next
> values:
> > +			  - type: the trip type. Expected values are:
> > +			    0 - a trip point to enable active cooling;
> > +			    1 - a trip point to enable passive cooling;
> > +			    2 - a trip point to notify emergency;
> > +			  - temperature: unsigned integer indicating the trip
> > +			    temperature level in millicelsius;
> > +			  - minimum cooling state allowed within the trip
> node;
> > +			  - maximum cooling state allowed within the trip
> node;
> > +
> > +Example:
> > +	asic_thermal: mlxsw_minimal@48 {
> > +		compatible =3D "mlxsw_minimal";
>=20
> You missed the vendor part.

Acked.

>=20
> > +		reg =3D <0x48>;
> > +		status =3D "disabled";
>=20
> An example with it disabled?

We just use it in such way at BMC side. It's disabled by default and upon
event indicating the good health for the device the device driver is
connected. I can remove it from the example. But for BMC it's actually
the default state.

>=20
> > +		cooling-phandle =3D <&cooling>;
> > +
> > +		trips {
> > +			trip@0 {
> > +				trip =3D <0 75000 0 0>;
> > +			};
>=20
> I don't know much about the thermal subsystem. But looking at other
> example binding documents, you seem to do something different here to
> other drivers. Why do you not use what seems to be the common format:

In mlxsw_thermal driver we have definition for the thermal trips, which con=
tains
the type, like  "active" of "passive", temperature  in millicelsius and min=
/max states
for cooling device. These vector defines thermal trip points.
The hysteresis parameter is not relevant.

For example, ASIC thermal sensor is associated with the cooling device like=
:
&pwm_tacho {
...
	cooling: fan@0 {
		reg =3D <0x00>;
		cooling-levels =3D /bits/ 8 <125 151 177 203 229 255>;
		aspeed,fan-tach-ch =3D /bits/ 8 <0x00>;
	};

And the below sub-nodes
			trip@0 {
				trip =3D <0 75000 0 0>;
			};
			trip@1 {
				trip =3D <2 85000 1 5>;
			};
			trip@3 {
				trip =3D <2 105000 5 5>;
			};

defines that PWM should be at default speed (125), while temperature is
below 75000, should be at max speed (255), while temperature is above=20
10500, and should step according the temperate trend between.

Thanks,
Vadim.

>=20
>                trips {
>                         cpu_alert0: cpu-alert0 {
>                                 temperature =3D <90000>; /* millicelsius =
*/
>                                 hysteresis =3D <2000>; /* millicelsius */
>                                 type =3D "active";
>                         };
>                         cpu_alert1: cpu-alert1 {
>                                 temperature =3D <100000>; /* millicelsius=
 */
>                                 hysteresis =3D <2000>; /* millicelsius */
>                                 type =3D "passive";
>                         };
>                         cpu_crit: cpu-crit {
>                                 temperature =3D <125000>; /* millicelsius=
 */
>                                 hysteresis =3D <2000>; /* millicelsius */
>                                 type =3D "critical";
>                         };
>                 };
>=20
> 	Andrew
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
