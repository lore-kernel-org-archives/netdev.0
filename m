From: Jonas Lippuner <jonas@lippuner.ca>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client
 regression
Date: Mon, 11 Jul 2016 08:51:25 -0700
Message-ID: <d3e0ab9d-741d-b60f-b7bc-6a58017e2fec@lippuner.ca>
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="exB9pnwPmS6dqtNenM70e54Mnr5gsok0f"
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	=?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:36407 "EHLO
	mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755085AbcGKPvh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 11:51:37 -0400
Received: by mail-pa0-f67.google.com with SMTP id ib6so13011563pad.3
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 08:51:32 -0700 (PDT)
In-Reply-To: <1468248230-5763-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--exB9pnwPmS6dqtNenM70e54Mnr5gsok0f
Content-Type: multipart/mixed; boundary="xla4KxR0F4FhqBULJ9hWJGLT5NHwrFwDW"
From: Jonas Lippuner <jonas@lippuner.ca>
To: =?UTF-8?Q?Bj=c3=b8rn_Mork?= <bjorn@mork.no>, netdev@vger.kernel.org
Cc: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
 =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Message-ID: <d3e0ab9d-741d-b60f-b7bc-6a58017e2fec@lippuner.ca>
Subject: Re: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client
 regression
References: <1468248230-5763-1-git-send-email-bjorn@mork.no>
In-Reply-To: <1468248230-5763-1-git-send-email-bjorn@mork.no>

--xla4KxR0F4FhqBULJ9hWJGLT5NHwrFwDW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Thanks Bj=C3=B8rn!

I have applied the patch to v4.6.3 of linux-stable and Juniper VPN works
with the patch. Please let me know if I should test the patch applied to
any other code revision.


Best,
Jonas


-------- Original Message  --------
Subject: [PATCH v2 net] ipv6: addrconf: fix Juniper SSL VPN client
regression
From: Bj=C3=B8rn Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
CC: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Jonas Lippuner
<jonas@lippuner.ca>, Bj=C3=B8rn Mork <bjorn@mork.no>, =E5=90=89=E8=97=A4=E8=
=8B=B1=E6=98=8E
<hideaki.yoshifuji@miraclelinux.com>
Date: 7/11/2016, 7:43:50 AM

> The Juniper SSL VPN client use a "tun" interface and seems to
> be picky about visible changes.to it. Commit cc9da6cc4f56
> ("ipv6: addrconf: use stable address generator for ARPHRD_NONE")
> made such interfaces get an auto-generated IPv6 link local address
> by default, similar to most other interface types. This made the
> Juniper SSL VPN client fail for unknown reasons.
>=20
> Fixing this regression by adding a new private netdevice flag
> which disables automatic IPv6 link local address generation, and
> making the flag default for "tun" devices.
>=20
> Setting an explicit addrgenmode will disable the flag, so userspace
> can choose to enable automatic LL generation by selecting a suitable
> addrgenmode.
>=20
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=3D121131
> Fixes: cc9da6cc4f56 ("ipv6: addrconf: use stable address generator for =
ARPHRD_NONE")
> Reported-by: Valdis Kletnieks <Valdis.Kletnieks@vt.edu>
> Reported-by: Jonas Lippuner <jonas@lippuner.ca>
> Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Cc: =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E <hideaki.yoshifuji@miraclelinu=
x.com>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
> ---
> v2 changes:
>  - added a netdevice private flag to suppress automatic IPv6 LL
>  - suppressing only for "tun" devices
>=20
>=20
> So, something like this?  It has the bonus that it can be used for *any=
*
> type of device which does not want the automatic link local addresses.
> Only enabled for "tun" for now, of course.
>=20
> Is it OK to unconditionally disable the suppression if the user sets an=

> addrgenmode?  I find that to match *my* expectations, but I don't know
> much about the ordinary user :)
>=20
> And finally, Valdis and Jonas: could you please test this version too? =
It
> works for me in my simulated setup, but I don't have the Juniper client=

> so I cannot verify that it actually solves the problem.
>=20
>=20
> Bj=C3=B8rn
>=20
>=20
>  drivers/net/tun.c         | 4 ++++
>  include/linux/netdevice.h | 4 ++++
>  net/ipv6/addrconf.c       | 7 +++++++
>  3 files changed, 15 insertions(+)
>=20
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index e16487cc6a9a..6e7558f97013 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1073,6 +1073,10 @@ static void tun_net_init(struct net_device *dev)=

>  		/* Zero header length */
>  		dev->type =3D ARPHRD_NONE;
>  		dev->flags =3D IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
> +
> +		/* IPv6 LL address is known to break some applications */
> +		dev->priv_flags |=3D IFF_SUPPRESS_AUTO_IPV6_LL;
> +
>  		break;
> =20
>  	case IFF_TAP:
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index f45929ce8157..d04ea7fcdaba 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1333,6 +1333,8 @@ struct net_device_ops {
>   * @IFF_PHONY_HEADROOM: the headroom value is controlled by an externa=
l
>   *	entity (i.e. the master device for bridged veth)
>   * @IFF_MACSEC: device is a MACsec device
> + * @IFF_SUPPRESS_AUTO_IPV6_LL: device will not get an automatic IPv6
> + *	link local address
>   */
>  enum netdev_priv_flags {
>  	IFF_802_1Q_VLAN			=3D 1<<0,
> @@ -1363,6 +1365,7 @@ enum netdev_priv_flags {
>  	IFF_RXFH_CONFIGURED		=3D 1<<25,
>  	IFF_PHONY_HEADROOM		=3D 1<<26,
>  	IFF_MACSEC			=3D 1<<27,
> +	IFF_SUPPRESS_AUTO_IPV6_LL	=3D 1<<28,
>  };
> =20
>  #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
> @@ -1392,6 +1395,7 @@ enum netdev_priv_flags {
>  #define IFF_TEAM			IFF_TEAM
>  #define IFF_RXFH_CONFIGURED		IFF_RXFH_CONFIGURED
>  #define IFF_MACSEC			IFF_MACSEC
> +#define IFF_SUPPRESS_AUTO_IPV6_LL	IFF_SUPPRESS_AUTO_IPV6_LL
> =20
>  /**
>   *	struct net_device - The DEVICE structure.
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 47f837a58e0a..331ea5ebff5f 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -3113,6 +3113,10 @@ static void addrconf_dev_config(struct net_devic=
e *dev)
>  		return;
>  	}
> =20
> +	/* this device does not want automatic IPv6 LLs */
> +	if (dev->priv_flags & IFF_SUPPRESS_AUTO_IPV6_LL)
> +		return;
> +
>  	idev =3D addrconf_add_dev(dev);
>  	if (IS_ERR(idev))
>  		return;
> @@ -5104,6 +5108,9 @@ static int inet6_set_link_af(struct net_device *d=
ev, const struct nlattr *nla)
> =20
>  		idev->addr_gen_mode =3D mode;
>  		err =3D 0;
> +
> +		/* turn off suppression since user has requested addrgen */
> +		dev->priv_flags &=3D ~IFF_SUPPRESS_AUTO_IPV6_LL;
>  	}
> =20
>  	return err;
>=20

--=20
My email is signed and I encrypt email on request.
To verify my signature or send me encrypted email,
get my public key: http://lippuner.ca/key


--xla4KxR0F4FhqBULJ9hWJGLT5NHwrFwDW--

--exB9pnwPmS6dqtNenM70e54Mnr5gsok0f
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXg8CAAAoJELH92qHy0gntnAIQAIzIKj6A2aqGU2aIDWL/kVGj
0zkp/04OM3qLHdt8AUKFhbao3Afs0mtIIaZYcVsP++ukKgoTFnpVONTDwFZaXzi8
PYEDiBQZLhiXsLT9hNkw216JUYQLTJ3OvElOotqNP7+Y9jGmgq+JKxVNI+tgNu9r
5nGjhJELCM/q4X1Wn/BpIeHMtaNazWEN8SKh67MxVssM6xYrpawWh5b7NFsdmEYb
nMsJHX4XbZ5ncykr2Gdu8hu6m8paefLLzTyvSSUiXwqC1vfUP4hxV4lWr+jM4ybR
qDXpVQUuLIs1JYHDqmw4tzOn4IWWWs3u1c3GG/AVaQpj57BeKPl1Pem09I3e2wqb
7Y4TrgEQo8Z8SGYgyc2POmNT8tG9KFja8a4iofMY9jIP0usInTa6R1UV6u9X5VK2
OkYT8OG37XsCWa7gRi6pceZ6Xpco2HUyRqdYy/O6RtIOIWr31YIT61bV5Cy/Zz8A
PLH8sZWN7DNsHGkP9BrnbSzzQngwpZXAwbsPUY+g7FcMxaOc55e8iyyzya73olhp
gFmlU6gNIdovPRTE38SBqSM0XRHTT6jjTkWuUUaVPPpbM/fc9V1gbHlkoHjTxTAv
oeBRDg5e3GNC+RMIzFIeMwCMZ/7uITZ642qaybXG3I/dHC5MbdvxpLxfdb7G42wh
5N8OC1+AL3aIUdEmaPuU
=l4IK
-----END PGP SIGNATURE-----

--exB9pnwPmS6dqtNenM70e54Mnr5gsok0f--
