From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [17/*] [NET] Replace dst_pmtu with dst_mtu
Date: Tue, 15 Mar 2005 10:24:50 -0800
Message-ID: <20050315102450.0f3f1618.davem@davemloft.net>
References: <20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050315100522.GA7275@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050315100522.GA7275@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 21:05:22 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch replaces most of the other uses of dst_pmtu with dst_mtu.
> As far as I can tell these are either identical because dst->path == dst,
> or they're a straightforward replacement of (the slightly incorrect)
> dst_pmtu(dst) - dst->header_Len with dst_mtu(dst).
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

> At this point the only remaining user of dst_pmtu is ipt_REJECT which
> will go away either when we use icmp_send in there or when I replace
> it with dst_mtu.

Yes, I saw that posting on netfilter-devel where you asked Rusty
why icmp_send() wasn't directly used even though it appears it
should be.

> We can now remove the other users of dst->path as well with the removal
> of that attribute itself as the goal.

Ok, sounds great.

So, at that point, I guess the next task is to handle PMTU events of already
encrypted packets properly?  We still have that problem right?  When the
ICMP payload is encrypted we have to cache some information on IPSEC output
so that a proto+SPI key can find us the encrypted inner IP header info, which
we'll need in order to process (and/or forward) the ICMP PMTU information
correctly.
