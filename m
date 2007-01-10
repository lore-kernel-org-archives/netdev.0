From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [IPSEC] flow: Cache negative results
Date: Thu, 11 Jan 2007 10:27:58 +1100
Message-ID: <20070110232758.GB13180@gondor.apana.org.au>
References: <20070110072251.GA27030@gondor.apana.org.au> <200701101111.43688.paul.moore@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3436 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S965246AbXAJX2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jan 2007 18:28:04 -0500
To: Paul Moore <paul.moore@hp.com>
Content-Disposition: inline
In-Reply-To: <200701101111.43688.paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Paul:

On Wed, Jan 10, 2007 at 11:11:43AM -0500, Paul Moore wrote:
> 
> I'm far from a flow cache expert (David, James, and Venkat will probably be 
> able to give you much better feedback) I did notice a few things which may or 
> may not be issues ... comments below.  FWIW, I believe Venkat is right in 
> that it shouldn't have any effect on the LSM code.
> 
> However, there is one other thing that came up when I was looking at your 
> patch, unrelated to your changes, that I wanted to ask about: in 
> net/core/flow.c:flow_entry_kill() ...
> 
> > static void flow_entry_kill(int cpu, struct flow_cache_entry *fle)
> > {
> >        if (fle->object)
> 
> Should this be "if (fle->object_ref)"?
> 
> >                atomic_dec(fle->object_ref);
> >        kmem_cache_free(flow_cachep, fle);
> >        flow_count(cpu)--; 
> > }

Yep this is a real bug.  Thanks for spotting it!

Although with Venkat's suggestion this change is no longer needed.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
