From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 0/2] Fix couple of issues with 'ethtool' get/set API's
Date: Mon, 01 Jun 2015 19:07:13 +0100
Message-ID: <1433182033.6319.178.camel@decadent.org.uk>
References: <1432334609-3971-1-git-send-email-aparames@broadcom.com>
	 <1433102379.6319.110.camel@decadent.org.uk> <556C92E3.3030707@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-S8QIwqxLVcqpUhdPYnY8"
Cc: Ben Hutchings <bwh@kernel.org>, netdev@vger.kernel.org,
	jdzheng@broadcom.com
To: Arun Parameswaran <aparames@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:33921 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752259AbbFASHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:07:20 -0400
In-Reply-To: <556C92E3.3030707@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-S8QIwqxLVcqpUhdPYnY8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-06-01 at 10:14 -0700, Arun Parameswaran wrote:
> On 15-05-31 12:59 PM, Ben Hutchings wrote:
> > On Fri, 2015-05-22 at 15:43 -0700, Arun Parameswaran wrote:
> >> Hi,
> >> The patch fixes 2 issues with 'ethtool' getting/setting parametres in
> >> the do_gset() do_sset() API's.
> >>
> >> I have pushed a patch to the Kernel to fix an issue in the handling of
> >> the 'ethtool' commands which got accepted.
> >> This Kernel patch was based on Linux v4.1-rc4 and is available in:
> >> https://github.com/Broadcom/cygnus-linux/tree/net-core-ethtool-fix-v1
> >>
> >> The Kernel was always clearing the command from the 'ethtool' resultin=
g
> >> in all operations to deal with PHY0. This prevents querying/setting
> >> PHY 1's settings.
> > [...]
> >=20
> > Each net device can be associated with a single PHY at a time, and the
> > ETHTOOL_GSET implementation should fill in the PHY address in the
> > ethtool_cmd::phy_address field.  Where there are multiple PHYs that can
> > be connected to the net device's MAC, an ETHTOOL_SSET operation can be
> > used to change that PHY address.
> >=20
> The above can be done by the driver when there is one PHY per MAC. In our
> case we have multiple PHYs controlled by the same MAC. I should have
> clarified this earlier, I apologize.

I understand that you can have multiple PHYs on the same MDIO bus, but
not how the MAC can use them at the same time.  Is this hardware level
bonding?  Or are multiple PHYs needed for a single link?

> When we specify the 'phyad', in the command line, we were expecting the
> 'ethtool' to fetch/set data for that 'phyad'. This is the intend of the
> patch.
>=20
> With the patch (in 'ethtool' and Kernel), if 'phyad' is not specified, it
> will still function as you described above, it will be up to the driver t=
o
> return the proper 'phyad' and related settings.
[...]

But without the patch in ethtool and other programs calling this API
(it's not just the ethtool command!), you get random junk as the
phy_address.  How will you tell whether it's valid or not?

Ben.

--=20
Ben Hutchings
Power corrupts.  Absolute power is kind of neat.
                           - John Lehman, Secretary of the US Navy 1981-198=
7

--=-S8QIwqxLVcqpUhdPYnY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWyfUee/yOyVhhEJAQoIHw//eug6NA+HJ8jnwb4LkifIYRhzJOKSZJuu
PqVj/LLeHYD/WvBsvPfBnwQ6YtpWEe0V8OMhJxhCUsg10/f4RL+HWUTZvB16qEgV
QOIZLhUJjjHSbijW5tPupHgpFTvUqghUkRbMZ5Mrwo7uQcnM0zjfifIWCIzmOpQ9
UcIu5zs5A6Q8i+zbZCMgcVFmTowPd9xozDvmNOwVg5jHZrS7/5y3R3Q0zXnSUaG2
c9Tu4gEBmpepnLajuUwbbIugD6X696yy1QdzPQSr6WUKaaWFAA3kL7WjUgGR+sc9
THCvKSRl26Nh4Th1xr0xWHyXE6hxen4wURXJWiAXu+9Ld2SdSIv/KImdJ6WYmkrj
AeuVVYnurjQdU6bd+gUTT8KolGevZFfdKV/4b6T4DLadWaxKTKA/fE/99y72fj41
ZKKDogb84gzmMooZqCrINolF6Cj5SaKViySr0RWOAcTIoObmGCeZH2/iOzySBadK
Atin59F0nDohCA3neVscJ3QUiucUb4cmWlWO6jcGKZ2kvncEL5Sv0h8Z1DnNwFwP
U8QBBiyg5eGhR8TIe4SZQ6uA+BksmnTAWPQASHfQw4Ud/38kAGLOUPzFEt4SVAVW
jO0qiLYIjWqsizA1c0M4ojMCgXZWXaMp2zqMM31MpRnGiqTKHfBuCwQj0Fw6FweK
bgqNmb086IU=
=QtWO
-----END PGP SIGNATURE-----

--=-S8QIwqxLVcqpUhdPYnY8--
