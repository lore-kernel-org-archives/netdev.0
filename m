From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH V3 2/6] net/ethtool: support get coalesce per queue
Date: Sun, 17 Jan 2016 02:06:33 +0000
Message-ID: <1452996393.2519.33.camel@decadent.org.uk>
References: <1452780487-10581-1-git-send-email-kan.liang@intel.com>
	 <1452780487-10581-2-git-send-email-kan.liang@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-p4PVOjxoCubHyjCgCRA9"
Cc: jesse.brandeburg@intel.com, andi@firstfloor.org,
	f.fainelli@gmail.com, alexander.duyck@gmail.com,
	jeffrey.t.kirsher@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	mitch.a.williams@intel.com, ogerlitz@mellanox.com,
	edumazet@google.com, jiri@mellanox.com, sfeldma@gmail.com,
	gospo@cumulusnetworks.com, sasha.levin@oracle.com,
	dsahern@gmail.com, tj@kernel.org, cascardo@redhat.com,
	corbet@lwn.net
To: kan.liang@intel.com, netdev@vger.kernel.org, davem@davemloft.net,
	bwh@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:53975 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753152AbcAQCG4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 21:06:56 -0500
In-Reply-To: <1452780487-10581-2-git-send-email-kan.liang@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-p4PVOjxoCubHyjCgCRA9
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-01-14 at 09:08 -0500, kan.liang@intel.com wrote:
[...]
> @@ -1814,6 +1840,10 @@ int dev_ethtool(struct net *net, struct ifreq *ifr=
)
> =C2=A0	case ETHTOOL_GTUNABLE:
> =C2=A0		break;
> =C2=A0	case ETHTOOL_PERQUEUE:
> +		if (copy_from_user(&sub_cmd, useraddr + sizeof(ethcmd), sizeof(sub_cmd=
)))
> +			return -EFAULT;
> +		if (sub_cmd =3D=3D ETHTOOL_GCOALESCE)
> +			break;

ETHTOOL_PERQUEUE should be handled before the containing switch(), so
we can then apply the switch() to sub_cmd; something like this:

	if (ethcmd =3D=3D ETHTOOL_PERQUEUE) {
		if (copy_from_user(&sub_cmd, useraddr + sizeof(ethcmd), sizeof(sub_cmd)))
			return -EFAULT;
	} else {
		sub_cmd =3D ethcmd;
	}

	switch (sub_cmd) {
	...
	}

Ben.

> =C2=A0	default:
> =C2=A0		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
> =C2=A0			return -EPERM;
--=20
Ben Hutchings
Theory and practice are closer in theory than in practice.
                                - John Levine, moderator of comp.compilers
--=-p4PVOjxoCubHyjCgCRA9
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVpr3Kee/yOyVhhEJAQo0ug//URCny0On3QfIt5RAK8rb14fSe8Og8GR+
IB/a385DEf0ygjkiuma1uWrloZIFIZ/wL/FMzOSJ/Xfu3As12leCfmSmx9vDAjP6
cyXwYHYZboi+7+vPzaaR9kaelPO3vGHK6Zt5XKqVjfaeWw2yQGdsXy+2HmnD2Fzu
YE9rAcFLNd9+EAwapzjiJPSPdUdTOoF4sg9xH1eX33ZjgTHjcAuNTfc53n6f8Grx
xcG3xaHSGtzM7ryvIkNM3YbFllzmtYAM7zdpiTiwjW++GbzJPWQK/lXnDWppPaBO
TDMpf5He1S84Sch8081guxHUI9p38IZRbQTsqp9hVZAVBapA3BcEIkSLAqQJ38z2
4erjsxUi8fUFoR5wwsNTT6jbkgLE5bslrRZjI29UhRrKxWzNmA5M8Bgn928SGTG4
SfMZTo5M46aNrFKk9v5dgFI51fn0ach7ysn+2T7Ox8FnGfky1ufSzzIwlTVUpNp8
jlM10YTJAyzkDEYg5PrOn5FFvGBy4jys7/fvc+o9WQ5SsGG1O1b0L4pL2SjHKz1V
4b51q3rifgiyPLTaTNFOF+EhFba8IuaB3Uihak5E0ZBwpFgLo+lFvLWmCACmBLNQ
0He0VfHKqmUHC5bLbdVQKor+YYN44qebSpTp1s7N+xqA6QLu+v3sF2eaNmMUBgIA
BrRpYaMhI88=
=kV/X
-----END PGP SIGNATURE-----

--=-p4PVOjxoCubHyjCgCRA9--
