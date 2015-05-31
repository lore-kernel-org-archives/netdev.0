From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Sun, 31 May 2015 20:59:39 +0100
Message-ID: <1433102379.6319.110.camel@decadent.org.uk>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-+M0WZLu4MuVFhQOYUFn+"
Cc: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org,
	jdzheng@broadcom.com
To: Arun Parameswaran <aparames@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:58545 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751142AbbEaT7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 May 2015 15:59:50 -0400
In-Reply-To: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-+M0WZLu4MuVFhQOYUFn+
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
> Hi,
> The patch fixes 2 issues with 'ethtool' getting/setting parametres in
> the do_gset() do_sset() API's.
>=20
> I have pushed a patch to the Kernel to fix an issue in the handling of
> the 'ethtool' commands which got accepted.
> This Kernel patch was based on Linux v4.1-rc4 and is available in:
> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1
>=20
> The Kernel was always clearing the command from the 'ethtool' resulting
> in all operations to deal with PHY0. This prevents querying/setting
> PHY 1's settings.
[...]

Each net device can be associated with a single PHY at a time, and the
ETHTOOL_GSET implementation should fill in the PHY address in the
ethtool_cmd::phy_address field.  Where there are multiple PHYs that can
be connected to the net device's MAC, an ETHTOOL_SSET operation can be
used to change that PHY address.

The ethtool API is not meant for controlling other PHYs that aren't
connected to the MAC; if you want to do that then create more net
devices for them or use the MDIO ioctls.

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-+M0WZLu4MuVFhQOYUFn+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWtoMOe/yOyVhhEJAQpyrg//e/XmI62oRW6wpwV29OsMKb9h8XYq34L6
8iz8BKgdyD4zNx4gtscPYj1axduR593mjusjtQcr+D+gaIZl7Gs7oiVlTnlE2+2U
ECZ4RWtHZL8QYpc9nrhgTFO7YD/mxc81ZfjvB4K/+9rStmp9XRC/OHhZUDmhFri4
oUFxKsW1b9IuE4hX/58ONvA9OBO7h8SfbYg/U8QhEtA0g544rc7/HX0XqbqLIJNF
qX9gWvNcuRcrWPALKqRSLVDAztjKWFVKQSaW47YZfp1/aHaKH281a+1RaGkX9FSr
5UJn5uQUlOPk/OSxf3DWclZBstSBhXB1RUQ3XgQhVThikgnv9wAJiDoBGl5tmUFH
maQ+jLkTZTynXhKVbuZIgjl4QAFU9/uk1mnxopS4MoP6rFC/GbitEYTj89gArcA1
0WmYSvi9RT2qtpEAQRPXjfbl90OI7UFGUBtCezH/73BYCmg6HmYTTHe/i7yy9wwa
VWJ4QcdFVqy4hh3hQV7g/XkP7VgVd6DDL8HKH0aqEkSLUG2H4yjePTMGCwzmT3Js
CiNjZ9icNoJy0pXsreQwafToVs9Xlpq1BGU5UuVFrXTkv3PBtsW2ObqOxMNZhSAw
pQnxGBvc44PKzSWqJP2XalXNdejFRgXS2XLTEJV3Sx79soPYp92sdq3XzPaIHU8a
67pjGPVI25c=
=+Pce
-----END PGP SIGNATURE-----

--=-+M0WZLu4MuVFhQOYUFn+--
