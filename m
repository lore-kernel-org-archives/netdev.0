From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: problem with flowi structure
Date: Fri, 17 Sep 2010 19:51:27 +0200
Message-ID: <1284745887.2235.7.camel@edumazet-laptop>
References: <AANLkTi=bGsvMqnTSanA73FhDH_DashmXTcA1sddtj0P6@mail.gmail.com>
	 <1284650768.3352.37.camel@edumazet-laptop>
	 <AANLkTimo1AeBS3rpQj0KtZL15Ct-DGTQMBUsL8hrVNOL@mail.gmail.com>
	 <1284652453.3352.38.camel@edumazet-laptop>
	 <AANLkTi=Y7beG4vPDx5eNg-gTN1CVg_G=1+dWwi2Xd2-R@mail.gmail.com>
	 <AANLkTim7TeMCG9RQyrrk8WS4+S_y1q06+8FG2-X=1cB-@mail.gmail.com>
	 <AANLkTimpnqNSE21u=2qjb5VGJrn_3_--Bqp4veCNXMPE@mail.gmail.com>
	 <1284714533.3391.53.camel@edumazet-laptop>
	 <AANLkTi=r__RA=5UfNnhsKizDF6OFVYXcSe9KOPx1zW0u@mail.gmail.com>
	 <1284741295.3391.100.camel@edumazet-laptop>
	 <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: AIJAZ BAIG <aijazbaig1@gmail.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Nicola Padovano <nicola.padovano@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45530 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148Ab0IQRvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Sep 2010 13:51:32 -0400
In-Reply-To: <AANLkTi=t2=jqu3XCC-3LK7x1_icke168Bqt-kmds6eOt@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dont top post, please.

Le vendredi 17 septembre 2010 =C3=A0 19:05 +0200, Nicola Padovano a =C3=
=A9crit :
> ok man :)
> the last question is about  fl.nl_u.ip4_u.saddr =3D 0...
> is it a kind of "jolly" selector of the source address?
> i.e. if we have a simplified cache route
>=20
> SOURCE IP    DEST IP    NEXT HOP
> ips1                  google         nexthop1
> ips2                  google         nexthop2
>=20
> with
> ...saddr =3D 0
> ....daddr =3D google
> ....tos =3D....
> i get nexthop1 or nexthop2. right?


Not "or" but exactly one.

If you have say 65534 ip addresses on your host (a full /16 network)

192.168.X.Y

If you want to send a frame from 182.168.1.2 to google, for sure the
route you are going to use is :

192.168.1.2  ->  google


If you want to send a frame from 182.168.10.20 to google, for sure the
route you are going to use is :

192.168.10.20  ->  google

and not the 192.168.1.2 -> google

if you say now :

Send a packet to google, please, I dont care of what source address you
chose, but I am interested to receive an answer, of course. (applicatio=
n
does not use bind() system call, only a send())

Then we look at the routing table given all the keys (for example, the
socket FWMARK or TOS value), and choose the primary address of the
network device the routes takes to join google.



