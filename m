From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: enable GRO if real_dev supports it
Date: Wed, 15 Sep 2010 10:14:18 -0700 (PDT)
Message-ID: <20100915.101418.59680213.davem@davemloft.net>
References: <20100914.213544.112598547.davem@davemloft.net>
	<20100915163749.GA4191@mmm.home.ifup.org>
	<1284570520.2462.5.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bphilips@suse.de, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	alexander.h.duyck@intel.com, peter.p.waskiewicz.jr@intel.com,
	john.ronciak@intel.com, donald.c.skidmore@intel.com,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54700
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752598Ab0IOROA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 13:14:00 -0400
In-Reply-To: <1284570520.2462.5.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Sep 2010 19:08:40 +0200

> Le mercredi 15 septembre 2010 =E0 09:37 -0700, Brandon Philips a =E9c=
rit :
>> Currently vlan devices don't have GRO by default as none of the Ethe=
rnet
>> drivers add NETIF_F_GRO to their vlan_features.
>>=20
>> As GRO is a software feature just propogate GRO from the real_dev in=
 the
>> vlan core. There is no need to have the drivers each add NETIF_F_GRO=
 to
>> their vlan_features.
>>=20
>> Signed-off-by: Brandon Philips <bphilips@suse.de>
>> ---
>>  net/8021q/vlan_dev.c |    1 +
>>  1 files changed, 1 insertions(+), 0 deletions(-)
>>=20
>> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
>> index 3bccdd1..6fbc445 100644
>> --- a/net/8021q/vlan_dev.c
>> +++ b/net/8021q/vlan_dev.c
>> @@ -735,6 +735,7 @@ static int vlan_dev_init(struct net_device *dev)
>>  					  (1<<__LINK_STATE_DORMANT))) |
>>  		      (1<<__LINK_STATE_PRESENT);
>> =20
>> +	dev->features |=3D real_dev->features & NETIF_F_GRO;
>>  	dev->features |=3D real_dev->features & real_dev->vlan_features;
>>  	dev->gso_max_size =3D real_dev->gso_max_size;
>> =20
>=20
> Hmm, this is only part of a generic solution.
>=20
> If I enable gro with "ethtool -K eth0 gro on", should we propagate GR=
O
> on vlan eth0.555 ?

I think a better way to implement this is to set NETIF_F_GRO in
netdev->vlan_features at register_netdev() time if it is set in
netdev->features

That is the implementation I was implying earlier in this thread.
