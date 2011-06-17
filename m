From: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
Subject: Re: [PATCH 1/2] IGMP snooping: set mrouters_only flag for IPv4
 traffic properly
Date: Fri, 17 Jun 2011 13:39:01 +0900
Message-ID: <1308285541.3761.7.camel@nausicaa>
References: <1307933995.2704.11.camel@nausicaa>
	 <1308013301.3896.6.camel@nexus.oss.ntt.co.jp>
	 <1308013483.3896.9.camel@nexus.oss.ntt.co.jp>
	 <20110616.231447.1625738654020726451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.hengli.com.au, shemminger@vyatta.com,
	netdev@vger.kernel.org, kakuta.hayato@oss.ntt.co.jp
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from serv2.oss.ntt.co.jp ([222.151.198.100]:37657 "EHLO
	serv2.oss.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751606Ab1FQEjF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2011 00:39:05 -0400
In-Reply-To: <20110616.231447.1625738654020726451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Fernando Luis V=C3=A1zquez Cao <fernando@oss.ntt.co.jp>
> Date: Tue, 14 Jun 2011 10:04:43 +0900
>=20
> > Upon reception of a IGMP/IGMPv2 membership report the kernel sets t=
he
> > mrouters_only flag in a skb that may be a clone of the original skb=
, which
> > means that sometimes the bridge loses track of membership report pa=
ckets (cb
> > buffers are tied to a specific skb and not shared) and it ends up f=
orwading
> > join requests to the bridge interface.
> >=20
> > This can cause unexpected membership timeouts and intermitent/perma=
nent loss
> > of connectivity as described in RFC 4541 [2.1.1. IGMP Forwarding Ru=
les]:
> >=20
> >     A snooping switch should forward IGMP Membership Reports only t=
o
> >     those ports where multicast routers are attached.
> >     [...]
> >     Sending membership reports to other hosts can result, for IGMPv=
1
> >     and IGMPv2, in unintentionally preventing a host from joining a
> >     specific multicast group.
> >=20
> >=20
> > Signed-off-by: Fernando Luis Vazquez Cao <fernando@oss.ntt.co.jp>
> > Tested-by: Hayato Kakuta <kakuta.hayato@oss.ntt.co.jp>
>=20
> Applied.

Thank you David.

By the way, What kernel version(s) are you targeting for these two
patches. It would be great if we could get them upstream before 3.0
comes out. Without this fix the IGMP snooping code is simply unusable i=
n
certain configurations.

- Fernando

