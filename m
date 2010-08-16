From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GTSM and TCP accept problem
Date: Mon, 16 Aug 2010 11:43:45 +0200
Message-ID: <1281951825.2524.5.camel@edumazet-laptop>
References: <20100814214634.24a87715@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:50369 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab0HPJnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Aug 2010 05:43:50 -0400
Received: by wyb32 with SMTP id 32so5477848wyb.19
        for <netdev@vger.kernel.org>; Mon, 16 Aug 2010 02:43:49 -0700 (PDT)
In-Reply-To: <20100814214634.24a87715@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 14 ao=C3=BBt 2010 =C3=A0 21:46 -0400, Stephen Hemminger a =C3=
=A9crit :
> The implementation of Generalized TTL Security has a problem
> on the TCP accept side. Since there can be different number of
> hops for each peer, the listener ends up doing
>=20
>    socket
>    bind
>    set TTL to 255
>    listen
>    while (nfd =3D accept(peer)) {
>      info =3D lookup(peer)
>      set MINTTL to 255 - info->ttl_hops
>=20
>=20
> The problem is that a rogue peer can still do three way
> handshake causing the accept to succeed. But the rogue will
> leave a stuck connection that will then have to timeout.
>=20
> The only ways I have come up to deal with this are:
>    * have short timeout on initial data (recycle faster)
>    * push peer;MINTTL table down into kernel (per socket)
>    * have BGP do this through iptables which is a non-starter
>      for a general application that needs to run on BSD, and
>      would mess up existing firewall rules.
>=20
> Ideas welcome..
> --

Another idea would be to store the TTL of the SYN packet (or third
packet) and let application read it after accept(), allowing it to
reject the connection if it doesnt match expected TTL.



