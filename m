From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next] rhashtable: remove insecure_max_entries param
Date: Tue, 25 Apr 2017 16:17:49 +0200
Message-ID: <20170425141749.GD11322@breakpoint.cc>
References: <20170425094134.21885-1-fw@strlen.de>
 <20170425110415.GA25167@gondor.apana.org.au>
 <20170425112356.GB11322@breakpoint.cc>
 <20170425132837.GA25657@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:49484 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1763279AbdDYORz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:17:55 -0400
Content-Disposition: inline
In-Reply-To: <20170425132837.GA25657@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu <herbert@gondor.apana.org.au> wrote:
> On Tue, Apr 25, 2017 at 01:23:56PM +0200, Florian Westphal wrote:
> >
> > What extra cost?
> > 
> > The only change is that ht->nelems has to be right-shifted by one,
> > I don't think that warrants extra space in struct rhashtable, its
> > already way too large (I think we can reduce its size further).
> 
> I see at least one hole on 64-bit which means that you can fit
> it into struct rhashtable for free.

I'd rather close that hole by removing more stuff from rhastable and
rhashtable_params structs instead.

F.e. why do we need to have two key_len (one in params, one in
struct rhashtable)?

Or why does rhashtable use size_t in rhashtable_params to e.g. store
a key offset? Just using 'unsigned int' instead would shrink
rhashtable_params by 16 bytes.

I'd have less of an issue with this if we'd be talking about
something computationally expensive, but this is about storing
an extra value inside a struct just to avoid one "shr" in insert path...
