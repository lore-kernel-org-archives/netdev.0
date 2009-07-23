From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-next-2.6] bonding: propogate vlan_features to bonding
 master
Date: Thu, 23 Jul 2009 08:03:56 +0200
Message-ID: <4A67FD4C.4080407@cosmosbay.com>
References: <24949.1240530461@death.nxdomain.ibm.com> <4A2CDB16.9030000@Voltaire.com> <4A642600.2010501@voltaire.com> <3463.1248298460@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz@voltaire.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39540 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbZGWGEM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jul 2009 02:04:12 -0400
In-Reply-To: <3463.1248298460@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh a =E9crit :
> 	Propogate the vlan_features of the slave devices to the bonding
> master device, using the same logic as for regular features.
>=20
> 	Tested by Or Gerlitz <ogerlitz@voltaire.com>, who also removed
> the debug logic from the original test patch.
>=20
> Signed-off-by: Or Gerlitz <ogerlitz@voltaire.com>
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Seems pretty cool, but I could not test it on my dev machine,
since tg3 and bnx2 drivers dont advertize yet vlan_features

>=20
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bo=
nd_main.c
> index 3bf0cc6..5a8b882 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -1331,6 +1331,7 @@ static int bond_compute_features(struct bonding=
 *bond)
>  	struct slave *slave;
>  	struct net_device *bond_dev =3D bond->dev;
>  	unsigned long features =3D bond_dev->features;
> +	unsigned long vlan_features;
>  	unsigned short max_hard_header_len =3D max((u16)ETH_HLEN,
>  						bond_dev->hard_header_len);
>  	int i;
> @@ -1343,10 +1344,14 @@ static int bond_compute_features(struct bondi=
ng *bond)
> =20
>  	features &=3D ~NETIF_F_ONE_FOR_ALL;
> =20
> +	vlan_features =3D bond->first_slave->dev->vlan_features;
>  	bond_for_each_slave(bond, slave, i) {
>  		features =3D netdev_increment_features(features,
>  						     slave->dev->features,
>  						     NETIF_F_ONE_FOR_ALL);
> +		vlan_features =3D netdev_increment_features(vlan_features,
> +							slave->dev->vlan_features,
> +							NETIF_F_ONE_FOR_ALL);
>  		if (slave->dev->hard_header_len > max_hard_header_len)
>  			max_hard_header_len =3D slave->dev->hard_header_len;
>  	}
> @@ -1354,6 +1359,7 @@ static int bond_compute_features(struct bonding=
 *bond)
>  done:
>  	features |=3D (bond_dev->features & BOND_VLAN_FEATURES);
>  	bond_dev->features =3D netdev_fix_features(features, NULL);
> +	bond_dev->vlan_features =3D netdev_fix_features(vlan_features, NULL=
);
>  	bond_dev->hard_header_len =3D max_hard_header_len;
> =20
>  	return 0;

