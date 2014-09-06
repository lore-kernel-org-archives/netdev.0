From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next v2 2/2] enic: Add ethtool support to show
 classifier filters added by the driver
Date: Sat, 06 Sep 2014 04:01:22 +0100
Message-ID: <1409972482.7389.22.camel@decadent.org.uk>
References: <1405943538-3086-1-git-send-email-_govind@gmx.com>
	 <1405943538-3086-3-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-L63JtQljA6b8Z7ztgRBF"
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:36006 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750902AbaIFDBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 23:01:39 -0400
In-Reply-To: <1405943538-3086-3-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-L63JtQljA6b8Z7ztgRBF
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-07-21 at 17:22 +0530, Govindarajulu Varadarajan wrote:
> This patch impliments ethtool_ops->get_rxnfc() to display the classifier
> filter added by the driver.
[...]

ARFS and ethtool RXNFC are two different interfaces for setting filters
and they shouldn't be confused with each other.

In the sfc driver, I made the filters inserted through each interface
invisible from the other.  The mlx4_en driver also appears to keep the
two sets of filters separate.

I can see that it is useful to be able to find out which filters have
been inserted through ARFS, but it should be possible to distinguish
them from those inserted through RXNFC.  Please don't include those
filters when ETHTOOL_GRXCLSRLCNT or ETHTOOL_GRXCLSRLALL are used.

Either add new command numbers for getting ARFS filters (the same
structures will do), or define some kind of extension flag for this
purpose.

Ben.

--=20
Ben Hutchings
Experience is directly proportional to the value of equipment destroyed.
                                                         - Carolyn Scheppne=
r

--=-L63JtQljA6b8Z7ztgRBF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVAp5B+e/yOyVhhEJAQovKRAAw7tR2+lx77qDExeXhiyxzVP9AL+4OD8o
Or0t5faI2Vf2ckntK5FAfyovFys7HkFFIFtWYIxQttJvEdyHr/W79H+sU6kJ7d4G
kPvanJq24a+GzdjrZlG66euZscbONEnHqPZBK0pqY0OXhY43XLVD+xCbwItyvBjR
q8iA+RmiGwjbxZ4R3rr9HjDIqZM9TYBgn9VyOenQ+3QSi1rOgSjXKNNO0rDdmBcZ
0MgbYWY4QQnOuwAMOI2MFRNxnoE1p7OkP8unLHpvf8iAVl3DrucSp+/7afEt3dG0
1VUwreH8WBoWl1GNA81YdmK2pbETHKOfj9uBJu1+J4pNmw/oka9wgwmn+ae0IJr/
F4g2XYa0ymiyKTZRs6Gg25HVG800iNexe+zHQCrni4gpghQuT0CK+ZN/nJ94ENrI
9AQHDVyS/ls7iqUwqZ3lDkXetLiOepS8PecF1Hmq5584KUNh93RigRl8QtkSDn6j
rYf5dfQmITNH4GwUFsfGYSk1J/AkpM83+OYxZ5d39AjPy8N9dqNYCDUmeTeYqJUa
vDzQ53x4BZYi04DF2DS1aj8HpvcfTAhEDePEzyaNbr4dxyFyI9iI7dcQDCd/GvgO
+YutagrrrA140d+0j2kkFBGQonfUsY2/UHmHYw3AKD0C5H5Cx86iIRRYNyOFFvjQ
R+Glm+uqu2w=
=MbcE
-----END PGP SIGNATURE-----

--=-L63JtQljA6b8Z7ztgRBF--
