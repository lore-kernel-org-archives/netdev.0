From: Patrick McHardy <kaber@trash.net>
Subject: Re: [XFRM]: Always reroute in tunnel mode
Date: Sat, 19 Feb 2005 07:23:06 +0100
Message-ID: <4216DB4A.2000109@trash.net>
References: <4214381F.5020507@trash.net> <20050217113654.GA10346@gondor.apana.org.au> <4214DF5B.3010608@trash.net> <20050217203805.GA4047@gondor.apana.org.au> <42150B36.5080609@trash.net> <20050217221031.GA4554@gondor.apana.org.au> <42152283.4030800@trash.net> <20050217151122.098c6def.davem@davemloft.net> <20050218095344.GA19307@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050218095344.GA19307@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>Put it another way, my solution to Patrick's inconsistency would be to
>always inherit the routing decision from the top to the bottom of the
>bundle.  For example, suppose you had
>
>ip ro add 192.168.0.0/16 \
>	nexthop via 10.0.0.1 dev eth0 \
>	nexthop via 10.0.0.2 dev eth0
>
>Then the packets to 192.168.0.0/16 should be sent via 10.0.0.1/10.0.0.2
>regardless of what IPsec protections are applied to it.
>
I agree it is a nice alternative to the current way. It would solve
another inconsistency caused by overriding the routing result in
tunnel mode: on output we don't care about oif, so packets from a
socket will be tunneled independent of sk_bound_dev_if. On input
packets won't be delivered to the socket if the encapsulated
packet arrived on a different interface.

Regards
Patrick
