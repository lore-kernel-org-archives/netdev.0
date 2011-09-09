From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/2] GRETH: avoid overwrite IP-stack's IP-frags checksum
Date: Fri, 09 Sep 2011 15:29:27 +0200
Message-ID: <1315574967.2294.28.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1315487676-16733-1-git-send-email-daniel@gaisler.com>
	 <1315487676-16733-2-git-send-email-daniel@gaisler.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, kristoffer@gaisler.com
To: Daniel Hellstrom <daniel@gaisler.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43482 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933424Ab1IIN31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 09:29:27 -0400
Received: by wyh22 with SMTP id 22so1571465wyh.19
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2011 06:29:26 -0700 (PDT)
In-Reply-To: <1315487676-16733-2-git-send-email-daniel@gaisler.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 08 septembre 2011 =C3=A0 15:14 +0200, Daniel Hellstrom a =C3=A9=
crit :
> The GRETH GBIT core does not do checksum offloading for IP
> segmentation. This patch adds a check in the xmit function to
> determine if the stack has calculated the checksum for us.
>=20
> Signed-off-by: Daniel Hellstrom <daniel@gaisler.com>
> ---
>  drivers/net/greth.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/greth.c b/drivers/net/greth.c
> index 9d39fb9..27ba855 100644
> --- a/drivers/net/greth.c
> +++ b/drivers/net/greth.c
> @@ -489,7 +489,8 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct=
 net_device *dev)
>  	if (nr_frags !=3D 0)
>  		status =3D GRETH_TXBD_MORE;
> =20
> -	status |=3D GRETH_TXBD_CSALL;
> +	if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> +		status |=3D GRETH_TXBD_CSALL;
>  	status |=3D skb_headlen(skb) & GRETH_BD_LEN;
>  	if (greth->tx_next =3D=3D GRETH_TXBD_NUM_MASK)
>  		status |=3D GRETH_BD_WR;
> @@ -512,7 +513,9 @@ greth_start_xmit_gbit(struct sk_buff *skb, struct=
 net_device *dev)
>  		greth->tx_skbuff[curr_tx] =3D NULL;
>  		bdp =3D greth->tx_bd_base + curr_tx;
> =20
> -		status =3D GRETH_TXBD_CSALL | GRETH_BD_EN;
> +		status =3D GRETH_BD_EN;
> +		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL)
> +			status | GRETH_TXBD_CSALL;
		typo here ?


>  		status |=3D frag->size & GRETH_BD_LEN;
> =20
>  		/* Wrap around descriptor ring */
