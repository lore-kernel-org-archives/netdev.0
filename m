From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Phonet: hold socket before giving it to sk_deliver_skb()
Date: Thu, 15 Oct 2009 16:52:19 +0200
Message-ID: <4AD73723.80604@gmail.com>
References: <3a7a7527184221041233e9ade71e4bf1@chewa.net> <1255611600-18534-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?=
	<remi.denis-courmont@nokia.com>
To: =?UTF-8?B?UsOpbWkgRGVuaXMtQ291cm1vbnQ=?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47776 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759646AbZJOO6A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2009 10:58:00 -0400
In-Reply-To: <1255611600-18534-1-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

R=C3=A9mi Denis-Courmont a =C3=A9crit :
> From: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.co=
m>
> ---
>  net/phonet/socket.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/phonet/socket.c b/net/phonet/socket.c
> index 8c84190..0412beb 100644
> --- a/net/phonet/socket.c
> +++ b/net/phonet/socket.c
> @@ -112,8 +112,10 @@ void pn_deliver_sock_broadcast(struct net *net, =
struct sk_buff *skb)
>  			continue;
> =20
>  		clone =3D skb_clone(skb, GFP_ATOMIC);
> -		if (clone)
> +		if (clone) {
> +			sock_hold(sknode);
>  			sk_receive_skb(sknode, clone, 0);
> +		}
>  	}
>  	spin_unlock(&pnsocks.lock);
>  }

Indeed sk_receive_skb() does a sock_put(sk)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
