From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [23/*] [IPV4] Kill remaining unnecessary uses of dst_pmtu
Date: Fri, 18 Mar 2005 10:41:51 -0800
Message-ID: <20050318104151.068adf9f.davem@davemloft.net>
References: <20050306213214.7d8a143d.davem@davemloft.net>
	<20050307103536.GB7137@gondor.apana.org.au>
	<20050308102741.GA23468@gondor.apana.org.au>
	<20050314102614.GA9610@gondor.apana.org.au>
	<20050314105313.GA21001@gondor.apana.org.au>
	<20050314111002.GA29156@gondor.apana.org.au>
	<20050315091904.GA6256@gondor.apana.org.au>
	<20050315095837.GA7130@gondor.apana.org.au>
	<20050318090310.GA28443@gondor.apana.org.au>
	<20050318091129.GA28658@gondor.apana.org.au>
	<20050318091918.GA28944@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org, kaber@trash.net,
        netdev@oss.sgi.com
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050318091918.GA28944@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 18 Mar 2005 20:19:18 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> Once again here is a couple of trivial dst_pmtu/dst_mtu replacements.
> In both locations, we can only have simple dst entries which means
> that dst == dst->path.
> 
> BTW, this is the rule that we should apply in future for uses of
> dst_mtu/dst_pmtu (or other metrics on dst).  If the only dst's that
> can appear are simple dst's (dst == dst->path), then we should use
> dst_mtu or dst_metric.  If dst != dst->path, then whoever is writing
> the code will need to think about which of dst or dst->path is the
> right one.
> 
> In most instances dst will be the one.  However, as we have seen in
> ip_append_data, dst->path may be needed rarely.  In particular, if
> we're doing fragmentation immediately after IPsec, then you may need
> it.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, and thanks for the nice succinct version of the rule :-)
