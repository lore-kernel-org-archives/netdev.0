From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [15/*] [INET] Fix IPsec calculation in
 ip_append_data/ip6_append_data
Date: Tue, 15 Mar 2005 10:18:46 -0800
Message-ID: <20050315101846.53027d2f.davem@davemloft.net>
References: <20050214221006.GA18415@gondor.apana.org.au>
	<20050214221200.GA18465@gondor.apana.org.au>
	<20050214221433.GB18465@gondor.apana.org.au>
	<20050214221607.GC18465@gondor.apana.org.au>
	<20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050315091904.GA6256@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 15 Mar 2005 20:19:04 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This patch fixes the IPsec overhead handling in ip_append_data and
> ip6_append_data.  As it is they assume that the IPsec overhead is
> constant.  This is not true as with ESP the IPsec overhead will vary
> as the MTU varies.
> 
> The result is that they may produce packets that will exceed the MTU
> when ESP is used.  Had it taken the trailer_len into account, it would
> have produced packets less than the real MTU.
> 
> By switching to dst_mtu we get the optimal result.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Looks nice.  Applied, thanks Herbert.
