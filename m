From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [patch net-next-2.6 1/8] af_packet: use skb->skb_iif instead
 of orig_dev->ifindex
Date: Sat, 05 Mar 2011 15:03:40 +0100
Message-ID: <4D7242BC.6070009@gmail.com>
References: <1299320969-7951-1-git-send-email-jpirko@redhat.com> <1299320969-7951-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:38353 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769Ab1CEODo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Mar 2011 09:03:44 -0500
Received: by wyg36 with SMTP id 36so2995477wyg.19
        for <netdev@vger.kernel.org>; Sat, 05 Mar 2011 06:03:43 -0800 (PST)
In-Reply-To: <1299320969-7951-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 05/03/2011 11:29, Jiri Pirko a =E9crit :
> Since skb_iif has the desired value (ifindex of physical device actua=
lly
> received the traffic) use that instead.

This one cause orig_dev to be useless from the af_packet point of view,=
 which is really good.

>
> Signed-off-by: Jiri Pirko<jpirko@redhat.com>

Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

> ---
>   net/packet/af_packet.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 5efef5b..b34294e 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -627,7 +627,7 @@ static int packet_rcv(struct sk_buff *skb, struct=
 net_device *dev,
>   	sll->sll_protocol =3D skb->protocol;
>   	sll->sll_pkttype =3D skb->pkt_type;
>   	if (unlikely(po->origdev))
> -		sll->sll_ifindex =3D orig_dev->ifindex;
> +		sll->sll_ifindex =3D skb->skb_iif;
>   	else
>   		sll->sll_ifindex =3D dev->ifindex;
>
> @@ -812,7 +812,7 @@ static int tpacket_rcv(struct sk_buff *skb, struc=
t net_device *dev,
>   	sll->sll_protocol =3D skb->protocol;
>   	sll->sll_pkttype =3D skb->pkt_type;
>   	if (unlikely(po->origdev))
> -		sll->sll_ifindex =3D orig_dev->ifindex;
> +		sll->sll_ifindex =3D skb->skb_iif;
>   	else
>   		sll->sll_ifindex =3D dev->ifindex;
>

