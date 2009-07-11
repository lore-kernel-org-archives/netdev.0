From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net:  Fix sk reference counting in ip_push_pending_frames
 and ip6_push_pending_frames
Date: Sat, 11 Jul 2009 21:39:39 +0200
Message-ID: <4A58EA7B.1000604@gmail.com>
References: <1247334370.7128.6.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, eric.dumazet@gmail.com
To: John Dykstra <john.dykstra1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42371 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752495AbZGKTjq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2009 15:39:46 -0400
In-Reply-To: <1247334370.7128.6.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Dykstra a =E9crit :
> Commit 2b85a34e911bf483c27cfdd124aeb1605145dc80 "net: No more expensi=
ve
> sock_hold()/sock_put() on each tx" used sk_wmem_alloc rather than the=
 struct sock reference
> count to track in-flight transmit-path packets.  However, it missed t=
he __sock_put() calls
> in ip_push_pending_frames() and ip6_push_pending_frames().  This resu=
lts in too-small
> reference counts when UDP or RAW sockets are used to send more than o=
ne MTU of data.  This=20
> in turn could lead to struct sock being freed and reused while it is =
still part of an
> active socket.
>=20
> A wide variety of socket symptoms may be fixed by this patch.  It als=
o fixes one cause=20
> of WARN_ON's in sk_del_node_init() and sk_nulls_del_node_init_rcu().
>=20
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Nice, but are you aware same patch was already posted, and is waiting f=
or David
approval ?

http://patchwork.ozlabs.org/patch/29618/


> ---
>  net/ipv4/ip_output.c  |    1 -
>  net/ipv6/ip6_output.c |    1 -
>  2 files changed, 0 insertions(+), 2 deletions(-)
>=20
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index 2470262..7d08210 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -1243,7 +1243,6 @@ int ip_push_pending_frames(struct sock *sk)
>  		skb->len +=3D tmp_skb->len;
>  		skb->data_len +=3D tmp_skb->len;
>  		skb->truesize +=3D tmp_skb->truesize;
> -		__sock_put(tmp_skb->sk);
>  		tmp_skb->destructor =3D NULL;
>  		tmp_skb->sk =3D NULL;
>  	}
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7c76e3d..87f8419 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1484,7 +1484,6 @@ int ip6_push_pending_frames(struct sock *sk)
>  		skb->len +=3D tmp_skb->len;
>  		skb->data_len +=3D tmp_skb->len;
>  		skb->truesize +=3D tmp_skb->truesize;
> -		__sock_put(tmp_skb->sk);
>  		tmp_skb->destructor =3D NULL;
>  		tmp_skb->sk =3D NULL;
>  	}

