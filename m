From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Openswan dev] IPComp
Date: Sat, 3 Jul 2004 21:37:32 +1000
Sender: dev-bounces@lists.openswan.org
Message-ID: <20040703113732.GA22082@gondor.apana.org.au>
References: <E1BgYk6-0007M3-00@gondolin.me.apana.org.au>
	<Pine.LNX.4.44.0407031301460.27704-100000@expansionpack.xtdnet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@lists.openswan.org>
To: Paul Wouters <paul@xelerance.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0407031301460.27704-100000@expansionpack.xtdnet.nl>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@lists.openswan.org>
List-Help: <mailto:dev-request@lists.openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@lists.openswan.org?subject=subscribe>
Errors-To: dev-bounces@lists.openswan.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 03, 2004 at 01:02:56PM +0200, Paul Wouters wrote:
> 
> He seems to have generic memory problems though, so I don't think this is an 
> openswan or kernel ipsec bug.

He's probably having a memory fragmentation problem, but allocating
64K physically contiguous memory is something that should never be
done over and over again.  As the IPCOMP init function is called
regularly, this needs to be fixed.

I haven't looked at the IPCOMP code in detail, but I'd guess that
we're allocating 64K as the largest IP packet size is 64K.

Would it be possible to adjust the size of the buffer according
to the packet size and allocate it in ipcomp_input()/ipcomp_output()
instead?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
