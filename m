From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [16/*] [INET] Take IPsec overhead into account in tunnels
Date: Tue, 15 Mar 2005 10:20:48 -0800
Message-ID: <20050315102048.18261722.davem@davemloft.net>
References: <20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050315095837.GA7130@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 20:58:37 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch uses dst_mtu instead of dst_pmtu in the various tunnel
> implementations.  As it is they simply ignore the IPsec overhead.
> This leads to bogus MTU values inside the tunnels.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.

> BTW, we're doing lazy MTU updates in the tunnel xmit functions.
> When a packet with DF set hits us and exceeds the updated MTU,
> we will send an ICMP packet back which is good.
> 
> Unfortunately when a packet with DF clear hits us as we update
> the MTU downwards, the packet will be silently discarded instead
> of fragmented (well we will send an ICMP back to ourselves but
> we already knew that MTU value :).
> 
> I presume we want to fix this, right?

I think so, although it could be argued that in the end it really
doesn't matter.  The final argument though is that quality of
implementation says we shouldn't drop the frame for such a reason.
