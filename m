From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 11/13] udp_diag: Implement the get_exact dumping
 functionality
Date: Fri, 09 Dec 2011 22:48:17 +0100
Message-ID: <1323467297.4016.10.camel@edumazet-laptop>
References: <4EE23561.5020804@parallels.com>
	 <4EE23626.6000104@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:49412 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761Ab1LIVsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2011 16:48:23 -0500
Received: by eekc4 with SMTP id c4so593803eek.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 13:48:22 -0800 (PST)
In-Reply-To: <4EE23626.6000104@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 09 d=C3=A9cembre 2011 =C3=A0 20:24 +0400, Pavel Emelyanov a=
 =C3=A9crit :
> Do the same as TCP does -- lookup a socket in the given udp_table,
> check cookie, fill the reply message with existing inet socket dumpin=
g
> helper and send one back.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

> +
> +	if (req->sdiag_family =3D=3D AF_INET)
> +		sk =3D __udp4_lib_lookup(&init_net,
> +				req->id.idiag_src[0], req->id.idiag_sport,
> +				req->id.idiag_dst[0], req->id.idiag_dport,
> +				req->id.idiag_if, tbl);
> +	else if (req->sdiag_family =3D=3D AF_INET6)
> +		sk =3D __udp6_lib_lookup(&init_net,
> +				(struct in6_addr *)req->id.idiag_src,
> +				req->id.idiag_sport,
> +				(struct in6_addr *)req->id.idiag_dst,
> +				req->id.idiag_dport,
> +				req->id.idiag_if, tbl);
> +	else

OK, but what happens if IPv6 is a module ?

  LD      .tmp_vmlinux1
net/built-in.o: In function `udp_dump_one':
udp_diag.c:(.text+0xa2b40): undefined reference to `__udp6_lib_lookup'
make: *** [.tmp_vmlinux1] Erreur 1
