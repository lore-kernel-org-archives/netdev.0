From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv4: use IS_ENABLED() macro to cleanup code
Date: Wed, 26 Oct 2011 08:34:34 +0200
Message-ID: <1319610874.18883.8.camel@edumazet-laptop>
References: <1319526752.3834.12.camel@edumazet-laptop>
	 <20111025.193037.1312584002692004360.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40433 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754417Ab1JZGek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 02:34:40 -0400
Received: by wwe6 with SMTP id 6so1927883wwe.1
        for <netdev@vger.kernel.org>; Tue, 25 Oct 2011 23:34:39 -0700 (PDT)
In-Reply-To: <20111025.193037.1312584002692004360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 25 octobre 2011 =C3=A0 19:30 -0400, David Miller a =C3=A9crit =
:

> net/ipv4/ip_sockglue.c: In function =E2=80=98do_ip_setsockopt=E2=80=99=
:
> net/ipv4/ip_sockglue.c:523:29: error: =E2=80=98LOOPBACK4_IPV6=E2=80=99=
 undeclared (first use in this function)
> net/ipv4/ip_sockglue.c:523:29: note: each undeclared identifier is re=
ported only once for each function it appears in
>=20
> This fails because ip_sockglue.c guards the net/transp_v6.h header
> inclusion with a real CPP guard.

Yep, it seems compiler was not able to perform optimisation of dead
code.

        if (IS_ENABLED(CONFIG_IPV6) &&
            (sk->sk_family =3D=3D PF_INET ||
             (!((1 << sk->sk_state) &
                (TCPF_LISTEN | TCPF_CLOSE)) &&
             inet->inet_daddr !=3D LOOPBACK4_IPV6))) {

Never mind, this will wait 3.3 :)
