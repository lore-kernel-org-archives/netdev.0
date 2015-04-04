From: Pavel Nakonechny <pavel.nakonechny@skitlab.ru>
Subject: Re: [PATCH] net: dsa: fix filling rtable from OF description
Date: Sat, 04 Apr 2015 20:10:09 +0300
Message-ID: <43287962.B6uVbMGNYa@kuro.zhome>
References: <1941340.ZSOIoOXLWB@pavel.skitlab.int> <20150404163814.GA19428@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <robh+dt@kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Fabian Frederick <fabf@skynet.be>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Joe Perches <joe@perches.com>, linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150404163814.GA19428@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew

=D0=92 =D0=BF=D0=B8=D1=81=D1=8C=D0=BC=D0=B5 =D0=BE=D1=82 4 =D0=B0=D0=BF=
=D1=80=D0=B5=D0=BB=D1=8F 2015 18:38:14 =D0=BF=D0=BE=D0=BB=D1=8C=D0=B7=D0=
=BE=D0=B2=D0=B0=D1=82=D0=B5=D0=BB=D1=8C Andrew Lunn =D0=BD=D0=B0=D0=BF=D0=
=B8=D1=81=D0=B0=D0=BB:
> There is the code after applying your patch:
>=20
> static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
>                                         struct dsa_chip_data *cd,
>                                         int chip_index, int port_inde=
x,
>                                         struct device_node *link)
> {
>         const __be32 *reg;
>         int link_sw_addr;
>         struct device_node *parent_sw;
>         int len;
>=20
>         parent_sw =3D of_get_parent(link);
>         if (!parent_sw)
>                 return -EINVAL;
>=20
> link is the phandle to the port in other switch. parent_sw is then th=
e
> switch property.
yep

>         reg =3D of_get_property(parent_sw, "reg", &len);
>         if (!reg || (len !=3D sizeof(*reg) * 2))
>                 return -EINVAL;
>=20
> So now you get the reg property. This is documented as:
>=20
> - reg                   : Describes the switch address on the MII bus
Yes, but read further in the entry example:
"reg =3D <16 0>;	/* MDIO address 16, switch 0 in tree */"


>         link_sw_addr =3D be32_to_cpup(reg + 1);
Now we extract switch number (" + 1"), but not switch MDIO address.

>=20
>         if (link_sw_addr >=3D pd->nr_chips)
>                 return -EINVAL;
>=20
> This is now not making much sense.
>=20
> Looking up the MII bus address seems wrong. You want the chip number,
> not its address.
Yes, you are right that its wrong to take MII address, but this code is=
 taking=20
switch number, not its address. I can agree that this is silly, but it =
is not=20
my code originally and patch fixes other thing.
