From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [NF+IPsec 4/6]: Make IPsec input processing symetrical to output
Date: Mon, 17 Oct 2005 11:46:29 +1000
Message-ID: <20051017014629.GB32661@gondor.apana.org.au>
References: <4352EEC8.9000602@trash.net>
	<20051017.094919.56989341.yoshfuji@linux-ipv6.org>
	<4352FD49.4090201@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <4352FD49.4090201@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 17, 2005 at 03:24:25AM +0200, Patrick McHardy wrote:
>
> For IPv6 this probably can be changed, I just kept the code in sync
> for now. For IPv4 it is necessary to pass it through the entire stack
> again to make netfilter fully usable without lots of code duplication
> or unusual limitations, especially for NAT. So the question is whether
> we want to keep the code and behaviour of IPv4 and IPv6 in sync or
> not. I think we should.

I can see the concern of processing pure transport mode packets in IPv6
twice in the stack because IPsec in IPv6 is used for a totally different
purpose compared to IPv4.

So how about this? We let the SA tell us whether they want to go through
netfilter again.  So each SA will carry a flag which determines whether
packets through it should go through netfilter.

This flag would only affect transport mode SAs of course.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
