From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] rhashtable: provide len to obj_hashfn
Date: Sun, 22 Mar 2015 07:31:09 +0000
Message-ID: <20150322073108.GA7910@acer.localdomain>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
 <1426952290-18962-2-git-send-email-kaber@trash.net>
 <20150321230618.GB31869@gondor.apana.org.au>
 <20150322044746.GA31192@acer.localdomain>
 <20150322072202.GA2125@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, davem@davemloft.net, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51497 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbbCVHbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 03:31:14 -0400
Content-Disposition: inline
In-Reply-To: <20150322072202.GA2125@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.03, Herbert Xu wrote:
> On Sun, Mar 22, 2015 at 04:47:47AM +0000, Patrick McHardy wrote:
> >
> > Correct, the set extensions are added on demand and contain an offset
> > for every extension type. The offset is usually not, but may be
> > different for different elements.
> > 
> > Embedding the offset is not something I want to do. Again, this stuff
> > is meant to be as compact as possible and it serves no purpose at all.
> > What is the problem with using these callbacks?
> 
> Maybe I'm not seeing everything but from this patch and what
> you sent me last time ([PATCH 0/9 WIP] nf_tables: set extensions
> and dynamic updates) it appears that NFT_SET_EXT_KEY is always
> present so if you always added it first to the template it would
> be at a fixed offset, no?

That's true so far, however I have a trie set implementation queued up
that will make this optional. For nft_hash, sure, it will always be
present, wouldn't make much sense otherwise :)

The offset is currently fixed, however that's not something that is
guaranteed by the implementation but purely by how the code is
arranged. It would be somewhat fragile to rely on this.

> But whatever, I don't really care about this so go ahead and add
> the key length to obj_hash.

Thanks for the review!
