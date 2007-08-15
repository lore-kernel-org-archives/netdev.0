From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: set_multicast_list vs. set_rx_mode
Date: Wed, 15 Aug 2007 14:44:26 +0200
Message-ID: <1187181866.3998.46.camel@johannes.berg>
References: <1187181208.3998.44.camel@johannes.berg>
	 <46C2F2B5.60803@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-CyYXZnKVPWgc7xtaY1Wn"
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:52485 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbXHOMlr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Aug 2007 08:41:47 -0400
In-Reply-To: <46C2F2B5.60803@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-CyYXZnKVPWgc7xtaY1Wn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-08-15 at 14:33 +0200, Patrick McHardy wrote:
> Johannes Berg wrote:
> > Is it intentional that in the case where set_rx_mode is assigned, you
> > still need to assign set_multicast_list even if it won't ever be called
> > as a flag for SIOCADDMULTI?
> >=20
> > I was thinking of converting the wireless code to use set_rx_mode and
> > assign set_multicast_list only if the underlying hardware supports
> > multicast filtering, and it seems that is well-supported, but it does
> > seem a bit weird that set_multicast_list degrades to a flag.
>=20
>=20
> Indeed, I missed that. It should check for !dev->set_multicast_list &&
> !dev->set_rx_mode before returning -EINVAL.

Ok. Want me to send a patch?

And then the expected behaviour is that set_rx_mode will set
IFF_ALLMULTI if it can't honour the list, right?

johannes

--=-CyYXZnKVPWgc7xtaY1Wn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGwvUq/ETPhpq3jKURAoilAJ0ePYL5dEeYuF9owbdy/tXy0bSapACgkkWv
7WHeMBhjHTJUTPEyBFOfTn8=
=rzsr
-----END PGP SIGNATURE-----

--=-CyYXZnKVPWgc7xtaY1Wn--

