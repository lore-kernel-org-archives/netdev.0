From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v3 7/9] net: mvmdio: add xmdio xsmi support
Date: Mon, 12 Jun 2017 13:54:35 +0200
Message-ID: <20170612115435.GC22312@kwain>
References: <20170612095745.11300-1-antoine.tenart@free-electrons.com>
 <20170612095745.11300-8-antoine.tenart@free-electrons.com>
 <20170612101739.GA4902@n2100.armlinux.org.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="Xm/fll+QQv+hsKip"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com, f.fainelli@gmail.com,
        thomas.petazzoni@free-electrons.com, nadavh@marvell.com,
        mw@semihalf.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Russell King - ARM Linux <linux@armlinux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:46734 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752652AbdFLLyr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2017 07:54:47 -0400
Content-Disposition: inline
In-Reply-To: <20170612101739.GA4902@n2100.armlinux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Xm/fll+QQv+hsKip
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Russell,

On Mon, Jun 12, 2017 at 11:17:39AM +0100, Russell King - ARM Linux wrote:
> On Mon, Jun 12, 2017 at 11:57:43AM +0200, Antoine Tenart wrote:
> > +static const struct orion_mdio_ops *orion_mdio_get_ops(struct orion_md=
io_dev *dev,
> > +						       int regnum)
> > +{
> > +	if (dev->bus_type =3D=3D BUS_TYPE_XSMI && (regnum & MII_ADDR_C45))
> > +		return &orion_mdio_xsmi_ops;
> > +	else if (dev->bus_type =3D=3D BUS_TYPE_SMI)
> > +		return &orion_mdio_smi_ops;
> > +
> > +	return ERR_PTR(-EOPNOTSUPP);
> > +}
>=20
> Oh, this is where you're doing it - I'm not sure having this complexity
> is really necessary - there is no dynamic choice between the two.  This
> seems to be way over-engineered.

You're right, there is no dynamic choice between the two. The advantage
is the logic of the read/write operations are not duplicated.

> You might as well make the SMI operations fail if MII_ADDR_C45 is set,
> and the XSMI operations fail if MII_ADDR_C45 is not set.

This check is already done for xSMI operations. But this should also be
the case for SMI ones, you're right.

> 1. the mdio read/write functions implement their own locking.
>=20
>    At the MDIO level, there is already locking in the form of a per-bus
>    lock "bus->mdio_lock" which will be taken whenever either of these
>    functions is called.  So the driver's "dev->lock" is redundant.

OK, that's a good rework to add in the series.

> 2. with the redundant locking removed, orion_mdio_write() becomes a
>    call to orion_mdio_wait_ready() followed by a call to dev->ops->write.
>    It seems that orion_mdio_wait_ready() could be a library function
>    shared between a SMI version of orion_mdio_write() and a XSMI version.
>=20
> 3. the same is really true of orion_mdio_read(), although that function
>    is a little more complex in itself, the result would actually end up
>    being simpler.

I'm not completely convinced as the read and write functions end up
being duplicated. One for SMI operations and one for xSMI. But I don't
really care, if you think this is better let's go for it.

Should I add your first patch in my series and squash the second one in
patch 7/9? (I'll also remove the bus_type member from the private
struct, as well as the one line it's used in the probe).

Thanks!
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--Xm/fll+QQv+hsKip
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZPoD6AAoJEFxNi8it27zYVmUP/juQOycv4WWBB7gNCZkoqrE/
ZeWZc7znNFeUmXgPdHSRonZlEwxwooW/Jgs0OnK9r535rhtFKJL/kfnHEQOk2Cax
ogtZx1KJFaHN/KXWUiD/ogYS3o1edLZWTRsMEN6KP3AI/wslYRs5/0SOKpL3/xNI
1oQ7Ygkn/Q9tohJyhB5pgIjYF7Za3P60L+WEvNS8K7MO18kCB3U8rnsVfF4ouUrB
yflytsopSyjuPiZDngMAOBvKhRD0/EqFtA1fgIpU1820kI/aDweyhjaSABhNmRsl
Oodr3TP545v1/7QTHesjZNDD4JA9/mWV2QrYiXgsGwJPxWBkuFZwaqeI4cT+wy1e
V0JAF4NQ4GguOG8taBn6J1YVV31bZ8VbDZFNuna0IPDRY2LHI/yAExbqfQCPOvjB
vD3cTmt1TiafEYL70yQVa4ICVaFvyOn1Pd9LCDDUY4Yn9UnsBfCk99IY7ysUAujT
7Ilq5JGLSMG7ELk3DkxwBYCqPWOUwd7KZkp+UFoH/5upewUaCgjWNiH4dsiBbKya
u5Z4r0xY7R1xvpKckjzBHW2S+eP4QqT+98K3Hoxb9Y1bXI9a1KR8kHnjq+HoIgYn
Jwc93RTfw8OYcbNfgz0ivyjDB6gQoPXNax4RAoov/qZzsmYQE6u1deTaYCyBzxPM
tz1zpMyVSf/0m2+6aDJv
=Gaay
-----END PGP SIGNATURE-----

--Xm/fll+QQv+hsKip--
