From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC v1] hand off skb list to other cpu to submit to upper
	layer
Date: Wed, 25 Feb 2009 14:36:56 +0800
Message-ID: <20090225063656.GA32635@gondor.apana.org.au>
References: <1235525270.2604.483.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jesse.brandeburg@intel.com
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49252 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752846AbZBYGhB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 01:37:01 -0500
Content-Disposition: inline
In-Reply-To: <1235525270.2604.483.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zhang, Yanmin <yanmin_zhang@linux.intel.com> wrote:
> =EF=BB=BFSubject: hand off skb list to other cpu to submit to upper l=
ayer
> From: =EF=BB=BFZhang Yanmin <yanmin.zhang@linux.intel.com>
>=20
> Recently, I am investigating an ip_forward performance issue with 10G=
 IXGBE NIC.
> I start the testing on 2 machines. Every machine has 2 10G NICs. The =
1st one seconds
> packets by pktgen. The 2nd receives the packets from one NIC and forw=
ards them out
> from the 2nd NIC. As NICs supports multi-queue, I bind the queues to =
different logical
> cpu of different physical cpu while considering cache sharing careful=
ly.
>=20
> Comparing with sending speed on the 1st machine, the forward speed is=
 not good, only
> about 60% of sending speed. As a matter of fact, IXGBE driver starts =
NAPI when interrupt
> arrives. When ip_forward=3D1, receiver collects a packet and forwards=
 it out immediately.
> So although IXGBE collects packets with NAPI, the forwarding really h=
as much impact on
> collection. As IXGBE runs very fast, it drops packets quickly. The be=
tter way for
> receiving cpu is doing nothing than just collecting packets.

This doesn't make sense.  With multiqueue RX, every core should be
working to receive its fraction of the traffic and forwarding them
out.  So you shouldn't have any idle cores to begin with.  The fact
that you do means that multiqueue RX hasn't maximised its utility,
so you should tackle that instead of trying redirect traffic away
from the cores that are receiving.

Of course for NICs that don't support multiqueue RX, or where the
number of RX queues is less than the number of cores, then a scheme
like yours may be useful.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
