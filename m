From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [2.6 PATCH] ipchains masquerade must select maddr correctly
Date: Wed, 3 Dec 2003 02:50:56 +0200 (EET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0312030231240.1237-100000@u.domain.uli>
References: <20031202162208.04629dab.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <laforge@gnumonks.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20031202162208.04629dab.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

On Tue, 2 Dec 2003, David S. Miller wrote:

> > 	The attached patch fixes ipchains masquerade to use
> > correctly the routing. This bug-to-bug compatibility with 2.2
> > is not valid from long time. Also, a missing unlock is added.
>
> Slow down.
>
> I don't think it's always desirable to specify a specific TOS when
> we're working with an input packet.  In fact, what you're doing all
> over the tree is going to cause the routing cache size to explode in
> some very real usage.

	Yes, it can grow up to 8 times (IPTOS_RT_MASK is 3 bits) if
we detect different rt tos values. In fact, ipchains is the only
case where tos is not provided :) For some users may be this is
not only a maddr selection, may be they have real routes by tos
for this public IP. Perhaps, TOS matching and hash key should be
a sysctl/compile time option? Then a site that does not use tos
for routing can safely run PMTUD without problems. I think, it is
a common case not to route by tos.

	The good news is that for ipchains this is in->out traffic
and may be there is only one tos value per path.

Regards

--
Julian Anastasov <ja@ssi.bg>
