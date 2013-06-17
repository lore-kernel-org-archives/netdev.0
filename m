From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] vlan: restore ethtool ABI to control VLAN hardware
 acceleration
Date: Mon, 17 Jun 2013 19:20:54 +0100
Message-ID: <1371493254.2086.64.camel@bwh-desktop.uk.level5networks.com>
References: <1371436083.7579.1.camel@nexus>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Fernando Luis =?ISO-8859-1?Q?V=E1zquez?= Cao
	<fernando_b1@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:45856 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586Ab3FQSU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 14:20:58 -0400
In-Reply-To: <1371436083.7579.1.camel@nexus>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-17 at 11:28 +0900, Fernando Luis V=C3=A1zquez Cao wrote=
:
> As part of the push to add 802.1ad server provider tagging support to=
 the
> kernel the VLAN features flags were renamed. Unfortunately the kernel=
 name
> for the VLAN hardware acceleration features that the kernel shows use=
r space
> was included in the rename, which broke ethtool (txvlan and rxvlan op=
tions
> do not work).

I expected something like that and said this was an ABI change, but
apparently my objection wasn't sufficient.

> This patch restores the original names, i.e. the original ABI.
> If we wanted to make clear to users that we are refering to CTAGs we =
can
> always change ethtool's short_name and long_name for these features (=
for
> example something along the lines of txvlan -> txvlan-ctag, tx-vlan-o=
ffload ->
> tx-vlan-ctag-offload).
>=20
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>

Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

> ---
>=20
> diff -urNp linux-3.10-rc5-orig/net/core/ethtool.c linux-3.10-rc5/net/=
core/ethtool.c
> --- linux-3.10-rc5-orig/net/core/ethtool.c	2013-06-09 09:41:04.000000=
000 +0900
> +++ linux-3.10-rc5/net/core/ethtool.c	2013-06-14 23:08:22.330454778 +=
0900
> @@ -60,10 +60,10 @@ static const char netdev_features_string
>  	[NETIF_F_IPV6_CSUM_BIT] =3D        "tx-checksum-ipv6",
>  	[NETIF_F_HIGHDMA_BIT] =3D          "highdma",
>  	[NETIF_F_FRAGLIST_BIT] =3D         "tx-scatter-gather-fraglist",
> -	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =3D  "tx-vlan-ctag-hw-insert",
> +	[NETIF_F_HW_VLAN_CTAG_TX_BIT] =3D  "tx-vlan-hw-insert",
> =20
> -	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =3D  "rx-vlan-ctag-hw-parse",
> -	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] =3D "rx-vlan-ctag-filter",
> +	[NETIF_F_HW_VLAN_CTAG_RX_BIT] =3D  "rx-vlan-hw-parse",
> +	[NETIF_F_HW_VLAN_CTAG_FILTER_BIT] =3D "rx-vlan-filter",
>  	[NETIF_F_HW_VLAN_STAG_TX_BIT] =3D  "tx-vlan-stag-hw-insert",
>  	[NETIF_F_HW_VLAN_STAG_RX_BIT] =3D  "rx-vlan-stag-hw-parse",
>  	[NETIF_F_HW_VLAN_STAG_FILTER_BIT] =3D "rx-vlan-stag-filter",
>=20

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
