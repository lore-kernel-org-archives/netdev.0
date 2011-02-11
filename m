From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO/GSO hiding PMTU?
Date: Fri, 11 Feb 2011 17:37:53 +1100
Message-ID: <20110211063753.GA29940@gondor.apana.org.au>
References: <20110210.145555.39165146.davem@davemloft.net> <20110210235022.GA25293@gondor.apana.org.au> <20110210.222216.104050992.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110210.222216.104050992.davem@davemloft.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 10, 2011 at 10:22:16PM -0800, David Miller wrote:
>
> I gave it a shot but it isn't easy.  We can figure out the length of
> the IP headers just fine, but the rest of the value we need to add
> to the MSS (the TCP header length) is transport specific which kind
> of implies a transport dependent gso proto op of some sort.

That's pretty much where I gave up :)

> Or we just hack it, admit that only TCP creates GSO packets, and
> directly check for TCP protcol and then inspect the TCP header
> length :-)

Sure we can do that for now.

What I wanted to do if I ever get enough time to work on this is
to record the transport header length in a gso_hlen field so we
can fix this properly.

We currently have a useless gso_segs field that only has one or
two users that don't even need it.  We could easily get rid of it
and use that space for gso_hlen instead.

The gso_hlen field only needs to be filled in at the few spots
that generate GSO packets, i.e.,

1) TCP
2) Virt backends like tun.c
3) GRO

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
