From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] Yield in netlink_broadcast when congested
Date: Sun, 17 Oct 2004 01:51:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041016235137.GE19714@rei.reeler.org>
References: <20041016113006.GA12843@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pablo Neira <pablo@eurodev.net>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <20041016113006.GA12843@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Herbert Xu <20041016113006.GA12843@gondor.apana.org.au> 2004-10-16 21:30
> So here is my proposal: if we detect signs of impending congestion
> in netlink_broadcast(), and that we're in a sleepable context, then
> we yield().
> 
> This gives the receivers a chance to pull down the messages without
> having the sender spinning indefinitely.  I've tested it on my UP
> machine and it does resolve the problem for ip monitor.

Looks good.

Up to how many receivers does that work? We would still see the
effect if too many receivers are registered, right?

I haven't had the time to read through the previous conversion so
I don't know if this has come up so far but we could request an ACK
from each receiver an congest based on the following strategy:

SS := Last serial sent
SR := Last serial received
LL := Lower congestion limit to ignore short bursts
UL := Upper congestion limit to avoid infinite congestion:

Congestion map for (SS - SR)
0..LL: NOP
LL..UL: dp-congestion
UL..MAX: NOP

The biggest problem is that I don't know of any application
handling ACK requests properly yet.

Just a wild idea anyway, I'm not even sure whether it's worth
the effort.
