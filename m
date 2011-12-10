From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] udp_diag: Make it module when ipv6 is a module
Date: Sat, 10 Dec 2011 12:00:20 +0100
Message-ID: <1323514820.4016.15.camel@edumazet-laptop>
References: <4EE23561.5020804@parallels.com>
		 <4EE23626.6000104@parallels.com>
	 <1323467297.4016.10.camel@edumazet-laptop> <4EE32167.2080202@parallels.com>
	 <4EE32777.2030003@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49411 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752381Ab1LJLA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 06:00:27 -0500
Received: by eekc4 with SMTP id c4so768607eek.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 03:00:26 -0800 (PST)
In-Reply-To: <4EE32777.2030003@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 13:33 +0400, Pavel Emelyanov a =C3=
=A9crit :
> Eric Dumazet reported, that when inet_diag is built-in the udp_diag a=
lso goes
> built-in and when ipv6 is a module the udp6 lookup symbol is not foun=
d.
>=20
>   LD      .tmp_vmlinux1
> net/built-in.o: In function `udp_dump_one':
> udp_diag.c:(.text+0xa2b40): undefined reference to `__udp6_lib_lookup=
'
> make: *** [.tmp_vmlinux1] Erreur 1
>=20
> Fix this by making udp diag build mode depend on both -- inet diag an=
d ipv6.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---
>=20
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index a51e33e..1a8f93b 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -411,7 +411,7 @@ config INET_TCP_DIAG
> =20
>  config INET_UDP_DIAG
>  	depends on INET_DIAG
> -	def_tristate INET_DIAG
> +	def_tristate INET_DIAG && IPV6
> =20
>  menuconfig TCP_CONG_ADVANCED
>  	bool "TCP: advanced congestion control"

Thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
