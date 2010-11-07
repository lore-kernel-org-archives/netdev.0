From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/9] Fix leaking of kernel heap addresses in net/
Date: Sun, 07 Nov 2010 18:11:12 +0100
Message-ID: <1289149872.2478.155.camel@edumazet-laptop>
References: <1289147508.3090.140.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: chas@cmf.nrl.navy.mil, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, remi.denis-courmont@nokia.com,
	netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: Dan Rosenberg <drosenberg@vsecurity.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:52839 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0KGRLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Nov 2010 12:11:18 -0500
Received: by fxm16 with SMTP id 16so3520145fxm.19
        for <netdev@vger.kernel.org>; Sun, 07 Nov 2010 09:11:17 -0800 (PST)
In-Reply-To: <1289147508.3090.140.camel@Dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 07 novembre 2010 =C3=A0 11:31 -0500, Dan Rosenberg a =C3=A9=
crit :
> Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
>=20
> diff -urp linux-2.6.37-rc1.orig/net/ipv4/af_inet.c linux-2.6.37-rc1/n=
et/ipv4/af_inet.c
> --- linux-2.6.37-rc1.orig/net/ipv4/af_inet.c	2010-11-01 07:54:12.0000=
00000 -0400
> +++ linux-2.6.37-rc1/net/ipv4/af_inet.c	2010-11-07 10:31:41.000000000=
 -0500
> @@ -139,12 +139,13 @@ void inet_sock_destruct(struct sock *sk)
>  	sk_mem_reclaim(sk);
> =20
>  	if (sk->sk_type =3D=3D SOCK_STREAM && sk->sk_state !=3D TCP_CLOSE) =
{
> -		pr_err("Attempt to release TCP socket in state %d %p\n",
> -		       sk->sk_state, sk);
> +		pr_err("Attempt to release TCP socket in state %d %lu\n",
> +		       sk->sk_state, sock_i_ino(sk));
>  		return;
>  	}

Why a non root user can read this debugging stuff, I ask.

I suggest "dmesg" for them sends them a Windows XP system log,
and /proc/cpuinfo pretends machine is a Z80, somewhat modified to have
65536 cores.



