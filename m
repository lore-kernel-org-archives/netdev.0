From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net 2/4] rtl8150: Use heap buffers for all register access
Date: Mon, 6 Feb 2017 16:25:20 +0000
Message-ID: <20170206162520.GA3442@decadent.org.uk>
References: <20170204165451.GU3442@decadent.org.uk>
 <20170204165631.GW3442@decadent.org.uk>
 <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="Gv4AD2GulCTyUAWX"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
        Petko Manolov <petkan@nucleusys.com>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:39288 "EHLO
        shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753425AbdBFQZW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 11:25:22 -0500
Content-Disposition: inline
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027CA6E@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Gv4AD2GulCTyUAWX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Feb 06, 2017 at 04:09:18PM +0000, David Laight wrote:
> From: Ben Hutchings
[...]
> > +	ret =3D usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
> > +			      RTL8150_REQ_GET_REGS, RTL8150_REQT_READ,
> > +			      indx, 0, buf, size, 500);
> > +	if (ret > 0 && ret <=3D size)
> > +		memcpy(data, buf, ret);
>=20
> If ret > size something is horridly wrong.
> Silently not updating the callers buffer at all cannot be right.

Yes, it seems strange to check this.  I originally wrote this as ret >
0, but then I checked the usbnet core and found __usbnet_read_cmd()
has the second comparison as well.

> > +	kfree(buf);
> > +	return ret;
>=20
> I can't help feeling that it would be better to add a wrapper to
> usb_control_msg() that does the kmalloc() and memcpy()s and
> drop that into all the call sites.

It might be.  Right now I'm trying to patch up a bunch of regressions
rather than argue over an API change.

Ben.

--=20
Ben Hutchings
Experience is what causes a person to make new mistakes instead of old ones.

--Gv4AD2GulCTyUAWX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUBWJijcOe/yOyVhhEJAQpbxRAAhWKV2wSltPIN//2bg0abUW/gjbmASsp3
QBSmPhbySCe4CP93AswAsnFUNComx7BkWWfjqfitEnIyv2FAz5JRVhT+b5hTkZ0q
XNhzGocUuSxH9w/KeslGoX5PSTzpNiS2rDLsOD1cihIygeWpy6g1A7ltfpOojGxB
Yk/Gv2vYt2Bz5HwRqTxHsU4bzxSZnd6zAE6B6P0Klhu4fMdiFdKdylsnjYgoifoz
ErXbprgxdx/BooGZXeJeDT3WAHj35Fo2/JdRqmXnefbxuPTXXOjQqcjYeGAWVR5G
nPqY433zjWLwPu9EwqrLEHlWr7vujQpBDbnBWoVLEX8XBwuaEkb59pyeOXRmgJAj
CNhVO39tuOvBVgKX/KYZt8/f9FVF3rEqEewCFsBfKt5EIbMiP9mr7r1ti58mk9+x
u+PYs35AYThHigONIh8z21FRK0ev6aDVBDucV3iq0kPl2zSP1qimA+83qC9w0zIN
k+wwO7t4CjPr4AecuY/ZYu7jC4MNDrLk9X08rM8jFTHDFHfyPLy82IxYkQMR1Lz8
KeAChHf/ysyfiYZITodwupNLFJbHkUcyoAVFWvDem+N9Yj5jl9Nnhu2HfPLNLr3M
fcsn/qhdfhwUzvv5pULBuefGjVbhoRlAfWvBkPPyWKeGZM3SaWEElLB/Sg/xetRq
UAVjIcvlipc=
=4bgB
-----END PGP SIGNATURE-----

--Gv4AD2GulCTyUAWX--
