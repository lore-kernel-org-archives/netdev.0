From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Wed, 25 Aug 2010 09:39:01 +0200
Message-ID: <1282721941.2467.705.camel@edumazet-laptop>
References: <20100825071626.GA13681@kryten>  <20100825071701.GA14962@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, miltonm@bga.com
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:43605 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124Ab0HYHjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 03:39:07 -0400
Received: by wyb35 with SMTP id 35so342335wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 00:39:05 -0700 (PDT)
In-Reply-To: <20100825071701.GA14962@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 17:17 +1000, Anton Blanchard a =C3=
=A9crit :
> We were hard coding 4096 when sizing sysctl_tcp_max_orphans which
> causes problems when PAGE_SIZE is not 4k. We calculate an order based=
 on
> PAGE_SHIFT so the count should be based on PAGE_SIZE
>=20
> Signed-off-By: Milton Miller <miltonm@bga.com>
> Signed-off-by: Anton Blanchard <anton@samba.org>
> ---
>=20
> Index: powerpc.git/net/ipv4/tcp.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- powerpc.git.orig/net/ipv4/tcp.c	2010-08-25 17:04:51.190305401 +10=
00
> +++ powerpc.git/net/ipv4/tcp.c	2010-08-25 17:05:15.463884764 +1000
> @@ -3270,7 +3270,7 @@ void __init tcp_init(void)
>  		;
>  	if (order >=3D 4) {
>  		tcp_death_row.sysctl_max_tw_buckets =3D 180000;
> -		sysctl_tcp_max_orphans =3D 4096 << (order - 4);
> +		sysctl_tcp_max_orphans =3D PAGE_SIZE << (order - 4);
>  		sysctl_max_syn_backlog =3D 1024;
>  	} else if (order < 3) {
>  		tcp_death_row.sysctl_max_tw_buckets >>=3D (3 - order);
> --

Considering your previous mail, I suggest you add

	sysctl_tcp_max_orphans =3D max(sysctl_tcp_max_orphans,
		     percpu_counter_batch * num_possible_cpus());




