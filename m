From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Fix sysctl_tcp_max_orphans when PAGE_SIZE != 4k
Date: Thu, 26 Aug 2010 06:45:31 +0200
Message-ID: <1282797931.2681.663.camel@edumazet-laptop>
References: <20100825071626.GA13681@kryten> <20100825071701.GA14962@kryten>
	 <1282758634.2487.576.camel@edumazet-laptop>
	 <20100825.165759.27789477.davem@davemloft.net>
	 <20100826003834.GA17882@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	miltonm@bga.com
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34640 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751920Ab0HZEph (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 00:45:37 -0400
Received: by wyb35 with SMTP id 35so1685400wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 21:45:36 -0700 (PDT)
In-Reply-To: <20100826003834.GA17882@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 26 ao=C3=BBt 2010 =C3=A0 10:38 +1000, Anton Blanchard a =C3=A9=
crit :
> Hi Dave,
>=20
> > Yeah, something like the following, Anton?
>=20
> Thanks! I tested on a 512GB box. One thing:
>=20
> # cat /proc/sys/net/ipv4/tcp_max_syn_backlog=20
> 128
>=20
> We probably want to use max():
>=20
> > -	sysctl_max_syn_backlog =3D min(128, cnt / 256);
> > +	sysctl_max_syn_backlog =3D max(128, cnt / 256);
>=20

I believe I make this min()/max() error once per week, sorry ;)

In my mind, I say "I want a minimum value of 128", then I write :

val =3D min(128, val);

instead of=20

val =3D max(128, val);

Oh well...

> With that change:
>=20
> # cat /proc/sys/net/ipv4/tcp_max_orphans=20
> 262144
> # cat /proc/sys/net/ipv4/tcp_max_tw_buckets
> 262144
> # cat /proc/sys/net/ipv4/tcp_max_syn_backlog=20
> 2048
>=20
>=20
> Tested-by: Anton Blanchard <anton@samba.org>
>=20
> Anton

Seems pretty good to me, thanks !

BTW, we now auto-limit ehash to 512*1024 slots, so you probably have
same results on a 128GB or 4096GB machine ;)



