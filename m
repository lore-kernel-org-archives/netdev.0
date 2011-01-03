From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Mon, 03 Jan 2011 10:27:47 +0100
Message-ID: <1294046867.2892.101.camel@edumazet-laptop>
References: <1294007971-18878-1-git-send-email-stefani@seibold.net>
	 <1294008562.2535.263.camel@edumazet-laptop>
	 <1294008917.18963.3.camel@wall-e>
	 <alpine.LNX.2.00.1101022356550.11481@swampdragon.chaosbits.net>
	 <1294045732.19666.6.camel@wall-e>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jesper Juhl <jj@chaosbits.net>, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	netdev@vger.kernel.org, shemminger@vyatta.com,
	daniel.baluta@gmail.com, jochen@jochen.org
To: Stefani Seibold <stefani@seibold.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1294045732.19666.6.camel@wall-e>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 03 janvier 2011 =C3=A0 10:08 +0100, Stefani Seibold a =C3=A9cr=
it :

> This will not work for two reasons:
>=20
> - First there is no way to detect a dead connection. A connection can
> stay for a very long time without data transfer.
>=20
> - Second it will not save against a attack where all communication sl=
ots
> will be eaten by an attacker and then new valid connections will be n=
ot
> handled.
>=20
> The only thing what is possible to make an ioctl call which allows th=
e
> user land client to cancel connections.=20
>=20
> But this will be in my opinion dead code, because white lists of trus=
ted
> address must be fostered and this will make the upgrading of a
> infrastructure to complicate.
>=20
>=20

Yep, and as UDP messages can easily spoofed, this means you need more
than a list of trusted addresses. You also need to encapsulate the thin=
g
in an secured layer.

Stefani, your implementation has very litle chance being added in
standard kernel, because it is not correctly layered, or documented.

Copying hundred (thousand ?) of lines from existing code only shows
there is a design error in your proposal. It means every time we have t=
o
make a change in this code, we'll have to do it twice.

SUNRPC uses UDP/TCP sockets, and use callbacks to existing UDP/TCP code=
,
maybe you should take a look to implement an UDPCP stack in kernel.

=46or instance, a pure socket API seems not the correct choice for UDPC=
P,
since a transmit should give a report to user, of frame being
delivered/aknowledged or not to/by the remote side ?

With send(), this means you have only one message in transit, no
asynchronous handling.

At least you forgot to document the API, and restrictions.
