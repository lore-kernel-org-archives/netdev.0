From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH net-next 10/18] net: mvpp2: use the GoP interrupt for
 link status changes
Date: Tue, 25 Jul 2017 10:47:35 +0200
Message-ID: <20170725084735.GC2860@kwain>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-11-antoine.tenart@free-electrons.com>
 <CAPv3WKcHtAKPKcfdC7xE-duhwMSRgSRW9_2B33Ru3KNfczZzMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="6zdv2QT/q3FMhpsV"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        "David S. Miller" <davem@davemloft.net>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Gregory =?iso-8859-1?Q?Cl=E9ment?=
        <gregory.clement@free-electrons.com>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        nadavh@marvell.com,
        Russell King - ARM Linux <linux@armlinux.org.uk>,
        Stefan Chulski <stefanc@marvell.com>, netdev@vger.kernel.org,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:48972 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751695AbdGYKlb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 06:41:31 -0400
Content-Disposition: inline
In-Reply-To: <CAPv3WKcHtAKPKcfdC7xE-duhwMSRgSRW9_2B33Ru3KNfczZzMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6zdv2QT/q3FMhpsV
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Marcin,

On Tue, Jul 25, 2017 at 12:58:20AM +0200, Marcin Wojtas wrote:
>=20
> This patch requires also:
>=20
> diff --git a/drivers/net/ethernet/marvell/mvpp2.c
> b/drivers/net/ethernet/marvell/mvpp2.c
> index 4694d4f..369819f 100644
> --- a/drivers/net/ethernet/marvell/mvpp2.c
> +++ b/drivers/net/ethernet/marvell/mvpp2.c
> @@ -6625,6 +6625,7 @@ static int mvpp2_stop(struct net_device *dev)
>  {
>         struct mvpp2_port *port =3D netdev_priv(dev);
>         struct mvpp2_port_pcpu *port_pcpu;
> +       struct mvpp2 *priv =3D port->priv;
>         int cpu;
>=20
>         mvpp2_stop_dev(port);
> @@ -6633,6 +6634,10 @@ static int mvpp2_stop(struct net_device *dev)
>         /* Mask interrupts on all CPUs */
>         on_each_cpu(mvpp2_interrupts_mask, port, 1);
>=20
> +       if (priv->hw_version =3D=3D MVPP22 && !port->phy_node && port->li=
nk_irq) {
> +               free_irq(port->link_irq, port);
> +       }
> +
>         free_irq(port->irq, port);
>         for_each_present_cpu(cpu) {
>                 port_pcpu =3D per_cpu_ptr(port->pcpu, cpu);
>=20
> Otherwise a sequence: ifconfig up/down/up results in faults.

You're right, thanks for the patch! I'll squash it in v2.

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--6zdv2QT/q3FMhpsV
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEEM7Tg8N8kXOlT7hOhXE2LyK3bvNgFAll3BacACgkQXE2LyK3b
vNgSaw/7BNAEdFYLYlcCy6ugjsGymgjWcSisIH6NIruS6qOaueB7yzeOTzP9M4D8
KhcQsM7gskjtpyuzmUQkI/WmzQHRn+LTLn81Cg1otyWMx0rs+FQ1vy8gtAhMwzHc
771F2Y3voDS9ZaZh7XwF6QASguBF1V+U8YvraBof9VY3KeOx6qFjRYw73bgYvRsZ
dl2GZUcuE7ij7HqhJmvlZXs6E4oe/9f9fwXNQmJWkrJsfGFXRw6L56OW5YocpiXv
od30R8CG2kwSdf2cX6x/udLkUoAHtp+N5FpM93l7JYNht7gcm8MIbXgVfqFLo7L+
AM7/ylkvo4A7USRTXOhyOWXk7DjaCnJ1hUYGh/ilsg+yGKs+SbY3e0q5c1qgzDb4
ZypnLgSNr3JVn+1t2WGyOAZUNWZG9FRG9/nPFpUboXoMIDWrog1fG/1o2wdaxmn0
lsIWpJLdO9jb/uy/+CP3zTEdbNEetgkkPeluoBHvD2Ed9TEMe2lw5kKSlSnekWwq
UXWMblI80KQs0YBDH7rzenA/XGS5fcbckw99cpTMf/XiYWNxVk+WqpvyEZ/1Mcjm
HXR5GlaR13+79rIWHtuTc2Gh8X/mj58Rgog6NUlG/yvvnQbD55+kSiC8SMF25EGy
AJyhMg8eJutiiaO5M0m9B2iWZdDcutDjQccZ8FOTIbz0Eezi1Xc=
=9KrA
-----END PGP SIGNATURE-----

--6zdv2QT/q3FMhpsV--
