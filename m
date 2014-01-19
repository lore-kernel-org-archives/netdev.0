From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3] net/dt: Add support for overriding phy configuration
 from device tree
Date: Sun, 19 Jan 2014 15:34:14 +0000
Message-ID: <1390145654.16433.102.camel@deadeye.wl.decadent.org.uk>
References: <7510122.cayuQ6qt8r@wuerfel>
	 <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-g+jb+UpMZLok7E/iYvC5"
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, kishon@ti.com
To: Matthew Garrett <matthew.garrett@nebula.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:59715 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752230AbaASPej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 10:34:39 -0500
In-Reply-To: <1389999459-9483-1-git-send-email-matthew.garrett@nebula.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-g+jb+UpMZLok7E/iYvC5
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-01-17 at 17:57 -0500, Matthew Garrett wrote:
> Some hardware may be broken in interesting and board-specific ways, such
> that various bits of functionality don't work. This patch provides a
> mechanism for overriding mii registers during init based on the contents =
of
> the device tree data, allowing board-specific fixups without having to
> pollute generic code.
[...]
> --- a/Documentation/devicetree/bindings/net/phy.txt
> +++ b/Documentation/devicetree/bindings/net/phy.txt
> @@ -23,6 +23,21 @@ Optional Properties:
>    assume clause 22. The compatible list may also contain other
>    elements.
> =20
> +The following properties may be added to either the phy node or the pare=
nt
> +ethernet device. If not present, the hardware defaults will be used.
> +
> +- phy-mii-advertise-10half: 1 to advertise half-duplex 10MBit, 0 to disa=
ble
> +- phy-mii-advertise-10full: 1 to advertise full-duplex 10MBit, 0 to disa=
ble
> +- phy-mii-advertise-100half: 1 to advertise half-duplex 100MBit, 0 to di=
sable
> +- phy-mii-advertise-100full: 1 to advertise full-duplex 100MBit, 0 to di=
sable
> +- phy-mii-advertise-100base4: 1 to advertise 100base4, 0 to disable
> +- phy-mii-advertise-1000half: 1 to advertise half-duplex 1000MBit, 0 to =
disable
> +- phy-mii-advertise-1000full: 1 to advertise full-duplex 1000MBit, 0 to =
disable

Are these really all needed?  Apparently there is a standard 'max-speed'
property on Ethernet devices already, which I think is probably
sufficient to express the actual restrictions of some boards.

> +- phy-mii-manual-master: 1 to enable manual master/slave configuration, =
0
> +  to disable manual master/slave configuration
[...]

Although the standard calls this 'manual', if it's set in the DT it
won't really be a manual setting.  The description should probably
clarify that.

I think the name should include 'master-slave' or 'clock-role' rather
than just 'master', as currently it suggests only the master role can be
forced.

Ben.

--=20
Ben Hutchings
friends: People who know you well, but like you anyway.

--=-g+jb+UpMZLok7E/iYvC5
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIVAwUAUtvwdue/yOyVhhEJAQpktQ//QNzIw7A2wI0tIGy485xO5OH36N6VPO4e
oS2bFp77f5bq5K4ycLnaL7/TYYBEOpoinlRk3EXhJAIfjf3OtwRviQcc2Uo6WQRk
6tFMBMwMWtkqiSgBCdAp5l5lXwmrjsAcNO+8vNWajU8p0ZmbSxLiwjZL/umI5Mmh
nqjEhg3Q/Akq3mZnwmbQX1MtpfeW/Apu6sr+k7X2Ey9xgzat6DE8CafkcZUEQKTc
ptCPQ/ynWOUFYvXTvg/F+SKYE86vgbzroB1CyYUy9keFVvPTeHCVyjV/TTe93hoD
ASDvy7JigZFTjwUYCsIyUmPY3T6s/cdDcPbp93SZKpqrb5Vq2iIaIOLnrlqjtBXG
gvX6AMxtjPT/mx2ObqepVWxDzfDxQDFquwRaQc4J17Uk9CcU1464cMIPVyjvRRIu
P8TJwoglYYslAkUoF/9acSEH1KdTqwKzjdpTsHtiH78fWf7xK0cB/PqFJUVO9z7G
vjFWrBuHHujPG+XioK/ROD/nB6iy6wVrjsco3M4DViYfnMLvD7dTFMLu3RO3ao0o
dnxbM/eUZ8mR4+nz7Z4onYq/2hAV+pZqQw/9E1YcoDB92ESESTatacVO1m+YP0Ii
p7yNj4XMlvzv2LKUeiz76WGbkWtB4u0XxW2eUl3DSoAFJcrYpTG2UDw3gFfJcVf3
LvokKbEz5fg=
=JLlz
-----END PGP SIGNATURE-----

--=-g+jb+UpMZLok7E/iYvC5--
