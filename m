From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Mon, 5 Dec 2005 09:15:20 +1100
Message-ID: <20051204221520.GB17056@gondor.apana.org.au>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
	<20051122103038.GA31532@gondor.apana.org.au>
	<20051122103139.GA4632@gondor.apana.org.au>
	<20051122121358.GA9057@gondor.apana.org.au>
	<438A5837.5040706@trash.net>
	<20051128045611.GA9571@gondor.apana.org.au>
	<43936905.2000700@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <43936905.2000700@trash.net>
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

On Sun, Dec 04, 2005 at 11:09:09PM +0100, Patrick McHardy wrote:
> 
> Thanks, I've added the correct patch now :) Unless I missed something,
> it was still missing a call to dst_output after the last transform
> in xfrm4_output_finish, unless we keep the loop in dst_output.

Good catch.  The lines

		err = 0;
		if (!skb->dst->xfrm)
			break;

should read

		if (!skb->dst->xfrm)
			return dst_output(skb);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
