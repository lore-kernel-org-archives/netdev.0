From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH v2 1/1] alx: add a simple AR816x/AR817x device driver
Date: Thu, 20 Jun 2013 22:58:28 +0100
Message-ID: <1371765508.8771.17.camel@deadeye.wl.decadent.org.uk>
References: <1370899609-13954-1-git-send-email-johannes@sipsolutions.net>
	 <1370899746-14219-1-git-send-email-johannes@sipsolutions.net>
	 <1371518286.3495.60.camel@deadeye.wl.decadent.org.uk>
	 <1371764438.8333.20.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7KUUBVN+vW4+Ay53O0U4"
Cc: netdev@vger.kernel.org, mcgrof@do-not-panic.com, kvalo@adurom.com,
	adrian.chadd@gmail.com, Johannes Stezenbach <js@sig21.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:34989 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758272Ab3FTV6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 17:58:36 -0400
In-Reply-To: <1371764438.8333.20.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7KUUBVN+vW4+Ay53O0U4
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2013-06-20 at 23:40 +0200, Johannes Berg wrote:
> (+Johannes, I have a question for you almost at the end of this email)
>=20
> On Tue, 2013-06-18 at 02:18 +0100, Ben Hutchings wrote:
>=20
> > > +config ALX
> > > +	tristate "Qualcomm Atheros AR816x/AR817x support"
> > > +	depends on PCI
> > > +	select CRC32
> > > +	select NET_CORE
> >=20
> > Why NET_CORE?  It looks like a lot of drivers are selecting it because
> > MII depends on it, but this doesn't select MII.  (Actually, it's
> > ridiculous that MII depends on NET_CORE.  I'll see what I can do about
> > that.)
>=20
> Yeah, no idea, just copy/paste. Lots of drivers seem to do this, for no
> particular reason it seems?

As I said, most of them select MII which depended on NET_CORE, so they
really did need to select NET_CORE too.  I've now fixed that.

[...]
> > > +	if (hw->link_speed !=3D SPEED_UNKNOWN) {
> > > +		ethtool_cmd_speed_set(ecmd,
> > > +				      hw->link_speed - hw->link_speed % 10);
> > > +		ecmd->duplex =3D hw->link_speed % 10;
> >=20
> > Please use separate fields for speed and duplex.
>=20
> Heh, ok. I actually played with this a bit and didn't like it much
> either way ... There doesn't seem to be any combined enum, and if you
> use separate fields then one is valid only if the other has a certain
> value, etc... Anyway, I'll change it.

It seems to be a widely used trick, but it means that you may accept
silly settings like speed =3D 99 duplex =3D 1.

[...]
> > You should break out the code that
> > sets ecmd->supported from alx_get_settings() and then do something like=
:
> >=20
> > 	if (ecmd->advertising & ~alx_get_supported_mask())
> > 		return -EINVAL;
> >=20
> > here.
>=20
> That... seems strange? It would rely on ADVERTISED_* and SUPPORTED_*
> having the same value, which is probably true, but it still seems
> confusing?

It is true and should remain true.  I don't know why they were ever
defined separately in the first place.

[...]
> > I couldn't find where auto-negotiated flow control is programmed after
> > the link comes up.  Maybe it isn't?
>=20
> No idea, sorry. I clearly have a lot to learn about how ethernet devices
> typically work, should it be programmed?

When autoneg is enabled, the PHY should perform autonegotiation whenever
it detects an electrical link; if successful it will configure itself
for the negotiated link speed and duplex, and trigger a link interrupt.
But unless there is firmware running on the controller, the driver
usually has to read PHY registers to get the result and then configure
the MAC speed, duplex and flow control accordingly.

Ben.

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-7KUUBVN+vW4+Ay53O0U4
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIVAwUAUcN7BOe/yOyVhhEJAQpDkQ//dyzH70vrBUwoVhLExON3NdzYpsPUY/aQ
lb2fQrFuoJ7ewiDa5ow47ZzCKOzHnEcRWuis+D2KuGnyzvCl8wzWxh8vT2nEmfk1
JGSyVYYVuR7AmOXiY/St3WzKNxB3pTJnd8m0OfzHGTghN1OofY6G82VKj7lIEViw
4QkjjickkFDuT1+itWjovV972eV6DV+arFKUDX+BiruwckSEhMPN8UNLvYIYksYb
WHbRxaZ2KiOdlAy7GTWyBoxCzzdT1fvQSS8eYbwmz8ANAa+PcFV/+jZwziMBKeHt
vQPA0+6AukbFcLZQtF467kSlazZ3Pw/cajkemY3eb1Vkm/RmsSO6aYOwvnUpPB/1
okff+qg0/6+d/KVPgvZgjnIpTplbTe+NvBOnBm41FHmUrt8Oe7NJ0NErpPD4WiTK
Q0W+84sv6MJ21EUUj7Wu8d2bs1Xy3tbUGeuCWU+DWSCy+gKL+x9CDQSLk1pBGRWh
w05M9vDKDzayAzleUccEDSmYmmhau7G+/n6XMaSUiFmNgWZyIuI0Uwq82NrE2CZ9
9KnjnAa2ht6+Vvff8Z00C1ebWgxaj1xQa5u1eacyQsSdgYM6/CbVtg7m59zymS71
jskQ0GJazht4trBsCjQRGf2MUBvmmnssbVeFYfeelZ9gpuZ+DZePMAhFboTABXXJ
9NnMtXfzFG0=
=LvSN
-----END PGP SIGNATURE-----

--=-7KUUBVN+vW4+Ay53O0U4--
