From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN packets silently dropped in promiscuous mode
Date: Thu, 30 Sep 2010 12:40:34 +0200
Message-ID: <1285843234.2615.278.camel@edumazet-laptop>
References: <20100929113757.GA23755@core.hellgate.ch>
	 <AANLkTi=QAoVH9KU8FAH6iscWt_mKnZpU3P9QqgFRLqXM@mail.gmail.com>
	 <20100930080703.GA10827@core.hellgate.ch>
	 <1285838215.2615.126.camel@edumazet-laptop>
	 <1285840532.2615.196.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Jesse Gross <jesse@nicira.com>,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: Roger Luethi <rl@hellgate.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52921 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752857Ab0I3Kkj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 06:40:39 -0400
Received: by fxm4 with SMTP id 4so562576fxm.19
        for <netdev@vger.kernel.org>; Thu, 30 Sep 2010 03:40:37 -0700 (PDT)
In-Reply-To: <1285840532.2615.196.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 30 septembre 2010 =C3=A0 11:55 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le jeudi 30 septembre 2010 =C3=A0 11:16 +0200, Eric Dumazet a =C3=A9c=
rit :
>=20
> > Agreed
> >=20
> > Could you try following patch, based on net-next-2.6 ?
>=20
> Here is the official patch I cooked for net-2.6 (linux-2.6)
>=20
> I tested it successfully with a tg3 NIC.
>=20
> Thanks
>=20
> [PATCH] vlan: dont drop packets from unknown vlans in promiscuous mod=
e
>=20
> Roger Luethi noticed packets for unknown VLANs getting silently dropp=
ed
> even in promiscuous mode.
>=20
> Check for promiscuous mode in __vlan_hwaccel_rx() and vlan_gro_common=
()
> before drops.
>=20
> Reported-by: Roger Luethi <rl@hellgate.ch>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/8021q/vlan_core.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
> index 01ddb04..ba502b4 100644
> --- a/net/8021q/vlan_core.c
> +++ b/net/8021q/vlan_core.c
> @@ -24,7 +24,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct v=
lan_group *grp,
> =20
>  	if (vlan_dev)
>  		skb->dev =3D vlan_dev;
> -	else if (vlan_id)
> +	else if (vlan_id && !(skb->dev->flags & IFF_PROMISC))
>  		goto drop;
> =20
>  	return (polling ? netif_receive_skb(skb) : netif_rx(skb));
> @@ -102,7 +102,7 @@ vlan_gro_common(struct napi_struct *napi, struct =
vlan_group *grp,
> =20
>  	if (vlan_dev)
>  		skb->dev =3D vlan_dev;
> -	else if (vlan_id)
> +	else if (vlan_id && !(skb->dev->flags & IFF_PROMISC))
>  		goto drop;
> =20
>  	for (p =3D napi->gro_list; p; p =3D p->next) {
>=20


Hmm, packets are delivered not only to tcpdump but also on other stacks=
,
on ethX.

So this is a domain violation.

Patch is not applicable as is.



