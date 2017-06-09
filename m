From: Antoine Tenart <antoine.tenart@free-electrons.com>
Subject: Re: [PATCH v2 7/8] net: mvmdio: add xmdio support
Date: Fri, 9 Jun 2017 10:25:41 +0200
Message-ID: <20170609082541.GC31464@kwain>
References: <20170608092653.25221-1-antoine.tenart@free-electrons.com>
 <20170608092653.25221-8-antoine.tenart@free-electrons.com>
 <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="Md/poaVZ8hnGTzuv"
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        davem@davemloft.net, jason@lakedaemon.net, andrew@lunn.ch,
        gregory.clement@free-electrons.com,
        sebastian.hesselbarth@gmail.com,
        thomas.petazzoni@free-electrons.com, mw@semihalf.com,
        linux@armlinux.org.uk, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:58390 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751515AbdFII0L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 04:26:11 -0400
Content-Disposition: inline
In-Reply-To: <a60a0b26-62b1-7c9e-e846-215747dddb1f@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Md/poaVZ8hnGTzuv
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Jun 08, 2017 at 09:42:21AM -0700, Florian Fainelli wrote:
> On 06/08/2017 02:26 AM, Antoine Tenart wrote:
> > This patch adds the xMDIO interface support in the mvmdio driver. This
> > interface is used in Ethernet controllers on Marvell 370, 7k and 8k (as
> > of now). The xSMI interface supported by this driver complies with the
> > IEEE 802.3 clause 45 (while the SMI interface complies with the clause
> > 22). The xSMI interface is used by 10GbE devices.
>=20
> In the previous version you were properly defining a new compatibles
> strings for xmdio, but now you don't and instead you runtime select the
> operations based on whether MII_ADDR_C45 is set in the register which is
> fine from a functional perspective.
>=20
> If I get this right, the xMDIO controller is actually a superset of the
> MDIO controller and has an extra MVMDIO_XSMI_ADDR_REG register to
> preform C45 accesses?

This is also a mistake. It's not a superset as the register offsets are
different. So we can't use the same smi operations in both cases. We
would need dedicated xmdio smi operations, but I don't think there is a
board where a c22 PHY is connected to the xMDIO interface.

I'll add smi and xsmi flags and return -ENOTSUPP based on the
MII_ADDR_C45 bit and flags combination. If the need to support smi
operations on the xMDIO bus arise it will be fairly easy to implement in
the future. I'll rename the ops functions as well to differentiate mdio
and xmdio operations.

Thanks,
Antoine

--=20
Antoine T=E9nart, Free Electrons
Embedded Linux and Kernel engineering
http://free-electrons.com

--Md/poaVZ8hnGTzuv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJZOluFAAoJEFxNi8it27zY9X4P/0G7azy/989m2vKB8ktWZ/CK
vgMZAdX4foBz1Sf6/qViPh+WMbliIhAWi+gFq71KuF0mtCnonpWAQnbxhDxv2mKp
3BCXhyb4NDRigQKcA3OEClXmuFurHOxqhH4HftQC7cUt5qPCXKUKPxjfwW5bbx0g
MV1apK2jrPCFH7tZrJ9mgkftVR6TVB86GbpjZ9heE659065SgcdZNEowvKBLtHKm
Wrap95s1u4LYKvBl9jE7iySH3mqWu/nAuj+Ixgd730f5w+90jKTBXPxuZb/7AJZb
YHpQyxXwRTJXepKlth5FWIzsMFkIUCbi7zKK7SX/uf1Fw/0FVfwFW9jAOIepUlGX
2Rrsc0415rV3aoZOUDlDGFDXSvSpRNNA76zvTLALULhzGO5Nki9xUKNOzOakx4w2
MwH8Jz71NxNBLLbBdC6jRSrYyL3TUsfSYVDujhm+dpAVIy4JXSjBNarFXouEEwgn
JQ8nTfCbIfg6LFvUzEPMzJBgDFtKX9oMCs1OIUez37s2g7XvXQLORPwCanAxi4K6
PKBdM5o5fOMXNILMf0mK90Ungw3heA5nbGX7Or+2X4DnS5ji9LeVfj7tQAFAWv/i
oN+BejiS8WY1HiPw10OjvMsPtURXDwsTzM+gbdz9ccHsMPFA1jmlaN2ASivwm4r+
N8wo2d2STg8Glpu45GPD
=arFW
-----END PGP SIGNATURE-----

--Md/poaVZ8hnGTzuv--
