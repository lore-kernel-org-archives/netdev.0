From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] net-gre: clear skb->queue_mapping in GRE recv path
Date: Sat, 25 Sep 2010 08:46:46 +0200
Message-ID: <1285397206.2478.97.camel@edumazet-laptop>
References: <pvm39syraqr.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60475 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750746Ab0IYGrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Sep 2010 02:47:06 -0400
Received: by fxm3 with SMTP id 3so1105581fxm.19
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 23:47:05 -0700 (PDT)
In-Reply-To: <pvm39syraqr.fsf@chavey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 24 septembre 2010 =C3=A0 16:18 -0700, chavey@google.com a =C3=
=A9crit :
> From: chavey <chavey@google.com>
> Date: Fri, 24 Sep 2010 15:05:02 -0700
>=20
> A continuous stream of errors:
>=20
>   slbgre0 received packet on queue [123], but number of RX queues is =
1
>   net_ratelimit: 155786 callbacks suppressed
>=20
> is filling up /var/log/messages.
>=20
> This is due to not unsetting skb->queue_mapping in the GRE receive pa=
th.
>=20
> Signed-off-by: chavey <chavey@google.com>
> ---
>  net/ipv4/ip_gre.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 945b20a..53bdb97 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -641,6 +641,7 @@ static int ipgre_rcv(struct sk_buff *skb)
>  		}
> =20
>  		skb_tunnel_rx(skb, tunnel->dev);
> +		skb_set_queue_mapping(skb, 0);
> =20
>  		skb_reset_network_header(skb);
>  		ipgre_ecn_decapsulate(iph, skb);


Laurent

Please use you full name in your signature,=20

Then, have you seen Tom Herbert patch yesterday ?

http://patchwork.ozlabs.org/patch/65583/

He suggested to place this skb_set_queue_mapping(skb, 0) inside
skb_tunnel_rx(), so that we dont patch every tunnel driver ...

Thanks


