From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 13:23:56 +0200
Message-ID: <20170425112356.GB11322@breakpoint.cc>
References: <20170425094134.21885-1-fw@strlen.de>
 <20170425110415.GA25167@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:48412 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1946697AbdDYLYG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 07:24:06 -0400
Content-Disposition: inline
In-Reply-To: <20170425110415.GA25167@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> Florian Westphal <fw@strlen.de> wrote:
> > no users in the tree, insecure_max_entries is always set to
> > ht->p.max_size * 2 in rhtashtable_init().
> > 
> > Replace only spot that uses it with a ht->p.max_size check.
> 
> I'd suggest that as this needs to be computed every time we insert
> an element that you keep the value in struct rhashtable, but as an
> internal value as opposed to a paramter that is set by the user.

What extra cost?

The only change is that ht->nelems has to be right-shifted by one,
I don't think that warrants extra space in struct rhashtable, its
already way too large (I think we can reduce its size further).

Thanks,
Florian
