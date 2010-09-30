From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 12:50:26 +0200
Message-ID: <4CA46B72.2090100@trash.net>
References: <20100929113757.GA23755@core.hellgate.ch>	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>	 <20100930080703.GA10827@core.hellgate.ch>	 <1285838215.2615.126.camel@edumazet-laptop>	 <1285840532.2615.196.camel@edumazet-laptop> <1285843234.2615.278.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, David Miller <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45982 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752916Ab0I3Kul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 06:50:41 -0400
In-Reply-To: <1285843234.2615.278.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30.09.2010 12:40, Eric Dumazet wrote:
> Le jeudi 30 septembre 2010 =E0 11:55 +0200, Eric Dumazet a =E9crit :
>> Le jeudi 30 septembre 2010 =E0 11:16 +0200, Eric Dumazet a =E9crit :
>>
>>> Agreed
>>>
>>> Could you try following patch, based on net-next-2.6 ?
>>
>> Here is the official patch I cooked for net-2.6 (linux-2.6)
>>
>> I tested it successfully with a tg3 NIC.
>>
>> Thanks
>>
>> [PATCH] vlan: dont drop packets from unknown vlans in promiscuous mo=
de
>>
>> Roger Luethi noticed packets for unknown VLANs getting silently drop=
ped
>> even in promiscuous mode.
>>
>> Check for promiscuous mode in __vlan_hwaccel_rx() and vlan_gro_commo=
n()
>> before drops.
>>
>> Reported-by: Roger Luethi <rl@hellgate.ch>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  net/8021q/vlan_core.c |    4 ++--
>>  1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>> index 01ddb04..ba502b4 100644
>> --- a/net/8021q/vlan_core.c
>> +++ b/net/8021q/vlan_core.c
>> @@ -24,7 +24,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct =
vlan_group *grp,
>> =20
>>  	if (vlan_dev)
>>  		skb->dev =3D vlan_dev;
>> -	else if (vlan_id)
>> +	else if (vlan_id && !(skb->dev->flags & IFF_PROMISC))
>>  		goto drop;
>> =20
>>  	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
>> @@ -102,7 +102,7 @@ vlan_gro_common(struct napi_struct *napi, struct=
 vlan_group *grp,
>> =20
>>  	if (vlan_dev)
>>  		skb->dev =3D vlan_dev;
>> -	else if (vlan_id)
>> +	else if (vlan_id && !(skb->dev->flags & IFF_PROMISC))
>>  		goto drop;
>> =20
>>  	for (p =3D napi->gro_list; p; p =3D p->next) {
>>
>=20
>=20
> Hmm, packets are delivered not only to tcpdump but also on other stac=
ks,
> on ethX.
>=20
> So this is a domain violation.

This should be fine as long as the packets are properly marked
with PACKET_OTHERHOST.
