From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] netem:  de-GSO packets before enqueing
Date: Fri, 13 Jan 2012 11:20:28 -0800
Message-ID: <20120113112028.4a24d988@nehalam.linuxnetplumber.net>
References: <1326400930.2740.10.camel@bwh-desktop>
	<20120112220328.GA10813@gondor.apana.org.au>
	<20120112165720.4545c670@nehalam.linuxnetplumber.net>
	<1326470097.3826.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1326470097.3826.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Jan 2012 16:54:57 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 12 janvier 2012 =E0 16:57 -0800, Stephen Hemminger a =E9crit=
 :
> > Probably something like this is needed (untested).
> >=20
> > This issue was discovered when looking at the skb_checksum path for=
 the
> > netem corruption operation, but it is a general problem.
> > Network emulation operations like corruption and drop want to opera=
te
> > on a per-packet (not per-segment) basis. This patch does GSO in sof=
tware
> > if necessary to break up packets.  Code is similar to logic in xfrm=
_output.
> >=20
> > Although it appears that the operation is not work conserving, it i=
s okay
> > because the higher level qdisc operations account for packets by in=
crementing
> > by gso_size.
>=20
> gso_size ok, but what about qlen ?
>=20
> We end up splitting one GSO skb in multiple segments, but shouldnt we
> instruct upper qdisc(s) that qlen was increased, sort of
> qdisc_tree_increase_qlen() call ?
>=20
>=20
>=20

Also, does pkt_len need to be set in cb after de-gso?
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
