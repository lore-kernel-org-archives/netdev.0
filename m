From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kenel level packet capturing
Date: Wed, 19 Oct 2011 09:12:11 +0200
Message-ID: <1319008331.17914.4.camel@edumazet-laptop>
References: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
	 <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: raviraj joshi <raviraj.j1991@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 19 octobre 2011 =C3=A0 12:24 +0530, raviraj joshi a =C3=A9c=
rit :
> Hi,
>=20
> We are making a kernel level packet capture module as a part of our B=
E project .
> We are finding it difficult to understand kenel networking code.
> We studied structures and functions like sk_buff, netif_rx(),dev_allo=
c_skb.
>=20
> However we were not able to trace the actual path a simple packet fol=
lows.
>=20
> Moreover we tried to count the no of times netif_rx function was
> called it was much much lower than amount of packets actually being
> received.
>=20
> Can anyone please let us know the reason for this and how to approach
> the problem of writing a kernel level packet capture module ,resoruce=
s
> we need to refer to (we are currently constrained to documents on
> kernel-networking available online).
>=20

Most drivers call netif_receive_skb() from softirq handler

netif_rx() is used only on cases where we are in hard irq handler, or w=
e
want to avoid a recursion (tunnels for example)

To install a packet capture, you should take a look at dev_add_pack()
and friends [ net/packet/af_packet.c being a good reference ]



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
