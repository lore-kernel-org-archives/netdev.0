From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] netem:  de-GSO packets before enqueing
Date: Fri, 13 Jan 2012 16:54:57 +0100
Message-ID: <1326470097.3826.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1326400930.2740.10.camel@bwh-desktop>
	 <20120112220328.GA10813@gondor.apana.org.au>
	 <20120112165720.4545c670@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20120112165720.4545c670@nehalam.linuxnetplumber.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 12 janvier 2012 =C3=A0 16:57 -0800, Stephen Hemminger a =C3=A9=
crit :
> Probably something like this is needed (untested).
>=20
> This issue was discovered when looking at the skb_checksum path for t=
he
> netem corruption operation, but it is a general problem.
> Network emulation operations like corruption and drop want to operate
> on a per-packet (not per-segment) basis. This patch does GSO in softw=
are
> if necessary to break up packets.  Code is similar to logic in xfrm_o=
utput.
>=20
> Although it appears that the operation is not work conserving, it is =
okay
> because the higher level qdisc operations account for packets by incr=
ementing
> by gso_size.

gso_size ok, but what about qlen ?

We end up splitting one GSO skb in multiple segments, but shouldnt we
instruct upper qdisc(s) that qlen was increased, sort of
qdisc_tree_increase_qlen() call ?



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
