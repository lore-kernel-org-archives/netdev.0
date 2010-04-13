From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 18:36:40 +0200
Message-ID: <1271176600.16881.533.camel@edumazet-laptop>
References: <20100413093408.GA16595@myhost.felk.cvut.cz>
	 <1271155163.16881.244.camel@edumazet-laptop>
	 <20100413112726.GB16595@myhost.felk.cvut.cz>
	 <1271161297.16881.293.camel@edumazet-laptop>
	 <20100413162326.GD16595@myhost.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:46094 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab0DMQgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 12:36:46 -0400
Received: by bwz19 with SMTP id 19so13028bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 09:36:44 -0700 (PDT)
In-Reply-To: <20100413162326.GD16595@myhost.felk.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 18:23 +0200, Michal Svoboda a =C3=A9crit =
:
> Eric Dumazet wrote:
> > sock1 =3D socket(AF_INET, SOCK_DGRAM, 0);
> > setsockopt(sock1, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
> > addr.sin_addr.s_addr =3D htonl(0x7f000001);
> > if (bind(sock1, (struct sockaddr *)&addr, sizeof(addr)))
> > 	perror("bind1");
> >=20
> > sock2 =3D socket(AF_INET, SOCK_DGRAM, 0);
> > setsockopt(sock2, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
> > addr.sin_addr.s_addr =3D INADDR_ANY; /* or htonl(0x7f000001); */
> > if (bind(sock2, (struct sockaddr *)&addr, sizeof(addr)))
> > 	perror("bind2");
> > }
>=20
> Well, now if I send to 127.0.0.1, who gets the datagram? I guess sock=
2,
> so it steals from sock1. What practical use does this have?
>=20

No, sock1 will get the frame.

In udp receive (kernel), we chose the socket with highest score.
A socket bound to an IP address (not 0.0.0.0) has a bonus.
A connected socket has an extra bonus.
A socket bound to a device has an extra bonus.

> > Therefore, applications should not use REUSEADDR on unicast UDP, un=
less
> > it is a non security issue (for example, if it is able to react to =
any
> > new IP addresses added by the administrator on the machine, and com=
plain
> > loudly if another application could bind() before itself)
>=20
> I don't think that in that case REUSEADDR would be useful because you
> can already claim new addresses without it, either by binding a separ=
ate
> socket to each IP or by binding to 0.0.0.0. Moreover the detection of
> the "complain" case would be very tricky, at least on first sight.
>=20
> > REUSADDR has a meaning for multicast, but for unicast... this is ha=
rdly
> > useful ?
>=20
> So would it be somehow possible to deliver the datagram to both socke=
ts
> (for example if they would be SO_BROADCAST as well)?

Not without a change in kernel. AFAIK no other OS do that anyway.


