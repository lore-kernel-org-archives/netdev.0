From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] x25: remove the BKL
Date: Thu, 27 Jan 2011 14:20:47 +0100
Message-ID: <1296134447.2614.5.camel@edumazet-laptop>
References: <1295993854-4971-1-git-send-email-arnd@arndb.de>
	 <AANLkTim=d4Tok-ri1BozZUfBFS=rofaodN8ZBA5AjKKd@mail.gmail.com>
	 <201101271317.01502.arnd@arndb.de>  <201101271338.39295.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Hendry <andrew.hendry@gmail.com>,
	linux-kernel@vger.kernel.org, linux-x25@vger.kernel.org,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201101271338.39295.arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 27 janvier 2011 =C3=A0 13:38 +0100, Arnd Bergmann a =C3=A9crit=
 :
> diff --git a/net/x25/x25_out.c b/net/x25/x25_out.c
> index d00649f..f1a6ff1 100644
> --- a/net/x25/x25_out.c
> +++ b/net/x25/x25_out.c
> @@ -68,8 +68,11 @@ int x25_output(struct sock *sk, struct sk_buff *sk=
b)
>  		frontlen =3D skb_headroom(skb);
> =20
>  		while (skb->len > 0) {
> -			if ((skbn =3D sock_alloc_send_skb(sk, frontlen + max_len,
> -							noblock, &err)) =3D=3D NULL){
> +			release_sock(sk);
> +			skbn =3D sock_alloc_send_skb(sk, frontlen + max_len,
> +						   1, &err);
> +			lock_sock(sk);
> +			if (!skbn) {
>  				if (err =3D=3D -EWOULDBLOCK && noblock){
>  					kfree_skb(skb);
>  					return sent;

This part looks strange :

noblock variable became "const 1 : NOBLOCK"

Why releasing socket if you dont block in sock_alloc_send_skb() ?
