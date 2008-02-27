From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: lockdep trace from rc2.
Date: Wed, 27 Feb 2008 12:40:36 +0100
Message-ID: <1204112436.3729.58.camel@johannes.berg>
References: <20080226.181354.33497295.davem@davemloft.net>
	 <20080226195157.46645a62@extreme> <20080226195400.3f6e010b@extreme>
	 <20080226.224010.227576469.davem@davemloft.net>
	 (sfid-20080227_064045_855572_9CE2CF8F)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PRSXrtJAXQAtO/k5a+ds"
Cc: shemminger@vyatta.com, davej@codemonkey.org.uk,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:49409 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbYB0Lkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2008 06:40:55 -0500
In-Reply-To: <20080226.224010.227576469.davem@davemloft.net> (sfid-20080227_064045_855572_9CE2CF8F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-PRSXrtJAXQAtO/k5a+ds
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Correct link: http://kerneltrap.org/mailarchive/linux-kernel/2007/4/11/=
76312

Also I just posted an explanation in this thread:

http://marc.info/?l=3Dlinux-netdev&m=3D120393645226652&w=3D2

> When I first looked at Dave's lockdep trace I grepped around and there
> are a bunch of drivers that call flush_scheduled_work like this.
>=20
> It seems that the common case is a driver that shares a lot of code
> between the suspend and ->stop paths.  Tulip is just such a case.

Bugger.

> Maybe it could do something similar to the 8139too fix at the above
> URL, but this is quite cumbersome if you ask me.
>=20
> Anyways, could someone please work on a fix for this stuff?

I think most of the instances should use cancel_work_sync() instead of
flush_scheduled_work() unless the work absolutely must still run before
suspend/stop/whatever. See bottom of the second link above, but it needs
to be done by someone familiar with the driver.

johannes

--=-PRSXrtJAXQAtO/k5a+ds
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR8VMM6Vg1VMiehFYAQLLcA/+KMeeP3pN+qprsg40mWafDcBYIain9+NH
iy2MDnyUjJmA62WrljUj94Xfuu2+ATD/RjwEejisJpvSkmV7UVEBrOUE6hbAdMBo
+3SFhZvA/1AKgd3Zg6wQt49d3Fi143caQ6gH31hMnb1T2MbiPkgVqliB9EQ/i1jp
mcgTgClWyjIMss/SdkupSF4NUrG5KqXV8wDwUsm70uxCW41GgnlrrW0xKPvhWgEu
ee5QQ11lYZgqlNR3kL9u6py+eEM2ihqstt+HKwVILtR28JHihUQeDlsoeyJnK+fc
+Dm8oKRTV3z0HHgXLrhiydEm5WZAUltHlk2BZfp69SLY+JulS1/WJ80JoAhi1bU/
0XMissHQMJfHFaPozh/iEFthJqK1+vtnTDi5+yXFUcEfpG9DuAXH/VrICPcXzklO
OkcKqyD6MPYmNuT0tHGlxUeaaQhWvDL2cL6eqOD5msh6PbM3GDUqwn3Nr8Ltk5Mh
rJibBHixzU/yvGdNbRFJPIEIp5kFORcBeBDFAinIgAhm5ihE9pbMM5jcXguE66eY
8mhVVPNw/EWtDrT3LmXpLRLKSMvfgXDCW63NeaKDpkFiB9Ne0uS0z/2LqpZjWqek
xI1CrWl4OM3dW/XPP9vRT17CJ+h212d6/ZQttBv84SaMvU3u42QLpS2VVVkgKdhi
anCHFoMQOUE=
=Ajec
-----END PGP SIGNATURE-----

--=-PRSXrtJAXQAtO/k5a+ds--

