From: Patrick McHardy <kaber@trash.net>
Subject: Re: VLAN I/F's and TX queue.
Date: Mon, 10 May 2010 16:41:40 +0200
Message-ID: <4BE81B24.4020601@trash.net>
References: <OF5A42C874.3AF220FE-ONC1257718.003ABC6E-C1257718.003F94D2@LocalDomain>	 <OF3F4D7278.DC6A6E51-ONC125771C.002B1AF4-C125771C.002C64E3@transmode.se>	 <1273222403.2261.26.camel@edumazet-laptop>  <4BE81793.3060905@trash.net> <1273502195.2221.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joakim Tjernlund <joakim.tjernlund@transmode.se>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:47463 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971Ab0EJOll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 10:41:41 -0400
In-Reply-To: <1273502195.2221.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le lundi 10 mai 2010 =E0 16:26 +0200, Patrick McHardy a =E9crit :
>=20
>> Is the intention just to avoid accounting the packet as dropped?
>> That seems fine to me since in case of NET_XMIT_CN its actually
>> not the currently transmitted packet that was dropped.
>>
>> But part of the intention of the above mentioned patch was actually
>> to inform higher layers of congestion so they can take action if
>> desired, which would be defeated by this patch.
>>
>=20
> I see, so maybe we want following patch instead ?
>=20
> (letting NET_XMIT_CN be given to caller, but accounting current packe=
t
> as transmitted ?)

Perfect, thanks. I'd suggest to change macvlan in a similar fashion
for consistency though.

In any case please feel free to add my

Acked-by: Patrick McHardy <kaber@trash.net>

> diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
> index b5249c5..55be908 100644
> --- a/net/8021q/vlan_dev.c
> +++ b/net/8021q/vlan_dev.c
> @@ -327,7 +327,7 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struc=
t sk_buff *skb,
>  	len =3D skb->len;
>  	ret =3D dev_queue_xmit(skb);
> =20
> -	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
> +	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) =
{
>  		txq->tx_packets++;
>  		txq->tx_bytes +=3D len;
>  	} else
> @@ -353,7 +353,7 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xm=
it(struct sk_buff *skb,
>  	len =3D skb->len;
>  	ret =3D dev_queue_xmit(skb);
> =20
> -	if (likely(ret =3D=3D NET_XMIT_SUCCESS)) {
> +	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) =
{
>  		txq->tx_packets++;
>  		txq->tx_bytes +=3D len;
>  	} else
>=20
>=20

