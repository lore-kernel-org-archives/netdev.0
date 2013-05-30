From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH v2] net: ethernet: xilinx_emaclite: set protocol selector
 bits when writing ANAR
Date: Thu, 30 May 2013 12:23:56 +0200
Message-ID: <51A728BC.5050208@monstr.eu>
References: <1382011039.590745.1369866978593.open-xchange@email.1und1.de>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="----enig2RREXVPTRJGUJGNFSINHF"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "renner@efe-gmbh.de" <renner@efe-gmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f180.google.com ([209.85.212.180]:36282 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S968060Ab3E3KX7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:23:59 -0400
Received: by mail-wi0-f180.google.com with SMTP id hn14so61615wib.13
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 03:23:57 -0700 (PDT)
In-Reply-To: <1382011039.590745.1369866978593.open-xchange@email.1und1.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
------enig2RREXVPTRJGUJGNFSINHF
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 05/30/2013 12:36 AM, renner@efe-gmbh.de wrote:
> This patch sets the protocol selector bits (4:0) of the PHY's MII_ADVER=
TISE
> register (ANAR) when writing ADVERTISE_ALL. The protocol selector bits =
are
> indicating IEEE 803.3u support and are fixed / read-only on some PHYs. =
Not
> setting them correctly on others (like TI DP83630) makes the PHY fall b=
ack
> to 10M HDX mode which should be avoided.
>=20
> Tested for TI DP83630 PHY on Microblaze platform.
>=20
> Signed-off-by: Jens Renner <renner@efe-gmbh.de>
> ---
> Changes in v2:
> - set ADVERTISE_ALL and protocol selector ADVERTISE_CSMA while all othe=
r
>   bits will be cleared
> - adapted patch title & description (original title: "net: ethernet:
>   xilinx_emaclite: keep protocol selector bits by reading ANAR")
>=20
>>>> David Laight <David.Laight@ACULAB.COM> hat am 28. Mai 2013 um 18:22
>>>> geschrieben:
> [...]
>>>> Given the comment shouldn't this be removing some bits?
>>>>
>>>> It is a long time since I read the definitions of the ANAR (etc).
>>>> But I remember it having at least 5 bits defined for 10M and 100M
>>>> operation (including 100T4), so the reference to keeping bits (4:0)
>>>> seems confusing.
>>>>
>>>>    David
>>>>
>>>
>>> David, thanks for your feedback!
>>> The bits I mentioned (the 5 least bits in ANAR) are the so-called pro=
tocol
>>> selection bits (at least that's what they call it at Intel, TI, Marve=
ll,
>>> Maxim,
>>> etc.). The only value that seems actually to be used is 1 (0b00001) w=
hich
>>> means
>>> 802.3 / fast ethernet capability (maybe 0 for slower devices?). 1 is =
the
>>> default value for all the 10/100(/1000) PHYs I know of, in some PHYs =
it is
>>> even
>>> hardcoded (i.e. read-only). It must not be confused with ANAR bits 9:=
5 where
>>> the actual speed and duplex mode can be selected.
>>> ADVERTISE_ALL as defined in mii.h lacks this bit, in contrast to
>>> ADVERTISE_FULL
>>> where it is set through ADVERTISE_CSMA. Whether this is correct or no=
t; at
>>> least it makes some sense to me to read what's actually written in th=
ese
>>> register bits and not to clear them. Otherwise some PHYs might fall b=
ack to
>>> 10-half as seen for the TI DP83640 which has been used to test this p=
atch.
>>> I hope this explains the reason for this patch.
>>
> [...]
>> However if you want to advertise 10M/100M HDX and FDX you need to unse=
t
>> the other speed bits (100T4 was assigned a bit, and I'm sure there wer=
e
>> extra bits reserved for higher speeds - which also need clearing).
>> Given that the ANAR is defined by 803.x you shouldn't really have a pr=
oblem!
> [...]
> You are right. The 1000BASE-T capability is advertised in another regis=
ter and
> already gets cleared one code line before (see original list mail), whi=
le the
> 100BASE-T4 bit now remains unchanged with my patch which is not intende=
d.
>=20
> drivers/net/ethernet/xilinx/xilinx_emaclite.c   |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> index 919b983..b7268b3 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -946,7 +946,8 @@ static int xemaclite_open(struct net_device *dev)
>                 phy_write(lp->phy_dev, MII_CTRL1000, 0);
>=20
>                 /* Advertise only 10 and 100mbps full/half duplex speed=
s */
> -               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL);
> +               phy_write(lp->phy_dev, MII_ADVERTISE, ADVERTISE_ALL |
> +                         ADVERTISE_CSMA);
>=20
>                 /* Restart auto negotiation */
>                 bmcr =3D phy_read(lp->phy_dev, MII_BMCR);
>=20

I have tested it on sp605 and there is no problem with autonegotiation.
On others xilinx boards behaviour should be the same.
Tested-by: Michal Simek <monstr@monstr.eu>

BTW: Going to send v2 for emaclite patches, I will CC you and will
be good if you can test them.

Thanks,
Michal


--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



------enig2RREXVPTRJGUJGNFSINHF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlGnKLwACgkQykllyylKDCGWagCfcB1xpYBKcfQW6EN0jXId43ct
BM4AmwadIP8DSZhjpp0mhwWElQ9FSqdc
=kA8J
-----END PGP SIGNATURE-----

------enig2RREXVPTRJGUJGNFSINHF--
