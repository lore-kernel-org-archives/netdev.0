From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: deliver skbs on inactive slaves to exact
 matches
Date: Mon, 14 Jun 2010 15:38:28 +0200
Message-ID: <1276522708.2478.89.camel@edumazet-laptop>
References: <20100603193011.4916.12354.stgit@jf-dev2-dcblab>
	 <20100614132120.GA24785@redhat.com>
	 <1276522483.2478.88.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Fastabend <john.r.fastabend@intel.com>, fubar@us.ibm.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:49941 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753963Ab0FNNie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jun 2010 09:38:34 -0400
Received: by wyb40 with SMTP id 40so3854765wyb.19
        for <netdev@vger.kernel.org>; Mon, 14 Jun 2010 06:38:33 -0700 (PDT)
In-Reply-To: <1276522483.2478.88.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 juin 2010 =C3=A0 15:34 +0200, Eric Dumazet a =C3=A9crit :

> [PATCH] net: fix deliver_no_wcard regression on loopback device
>=20
> deliver_no_wcard is not being set in skb_copy_header.
> In the skb_cloned case it is not being cleared and
> may cause the skb to be dropped when the loopback device
> pushes it back up the stack.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Oh I forgot :

Tested-by: Markus Trippelsdorf <markus@trippelsdorf.de>

> ---
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index 9f07e74..bcf2fa3 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -532,6 +532,7 @@ static void __copy_skb_header(struct sk_buff *new=
, const struct sk_buff *old)
>  	new->ip_summed		=3D old->ip_summed;
>  	skb_copy_queue_mapping(new, old);
>  	new->priority		=3D old->priority;
> +	new->deliver_no_wcard	=3D old->deliver_no_wcard;
>  #if defined(CONFIG_IP_VS) || defined(CONFIG_IP_VS_MODULE)
>  	new->ipvs_property	=3D old->ipvs_property;
>  #endif
>=20


