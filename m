From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: IP header identification field is zero, why?
Date: Thu, 08 Oct 2009 11:18:28 +0200
Message-ID: <4ACDAE64.5020101@gmail.com>
References: <f4f837ab0910070704k7a193be9i285573b423b96ba2@mail.gmail.com>	 <4ACCABE0.2070804@gmail.com> <f4f837ab0910080208g143ceb1dj538680ff62e6bb37@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45943 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751530AbZJHJTH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 05:19:07 -0400
In-Reply-To: <f4f837ab0910080208g143ceb1dj538680ff62e6bb37@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thomas yang a =E9crit :

> The IP ID for TCP is non-zero, but for UDP is zero,  strange.
>=20
> I want to make the IP ID (not always zero) for UDP packets, what shou=
ld I do?
> (I want to use 'IP header ID, flags, offset, protocol' to identify an
> IP packets)

As I said, you can connect() your udp socket, if you send/receive trafi=
c to/from a given destination.

if (connected_sock)
	res =3D connect(sock, (struct sockaddr *)&addr, sizeof(addr));

(Only once)


Then, your sendto() can be faster (because no route lookup is performed=
)

   if (sendto(sock, buffer, psize, 0,
                  connected_socks ? NULL : (struct sockaddr *)&addr,
                                   sizeof(struct sockaddr_in)) !=3D -1)

Then linux *will* generate an ID for each datagram.
