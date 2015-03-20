From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Fri, 20 Mar 2015 10:02:20 +0000
Message-ID: <20150320100220.GH21258@acer.localdomain>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
 <20150320093634.GA17344@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35197 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbCTKCZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 06:02:25 -0400
Content-Disposition: inline
In-Reply-To: <20150320093634.GA17344@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20.03, Herbert Xu wrote:
> On Mon, Mar 16, 2015 at 08:14:15PM +1100, Herbert Xu wrote:
> > On Mon, Mar 16, 2015 at 08:28:42AM +0000, Thomas Graf wrote:
> >
> > > The reason for the indirection was to not bypass the abstraction
> > > nft_data_cmp() provides.
> > > 
> > > No objection to the change but maybe leave a comment in
> > > nft_data_cmp() that if one changes nft_data_cmp() one needs to
> > > look at nft_hash and see if the direct use of rhashtable_lookup()
> > > is still valid.
> > 
> > Well we could preserve nft_data_cmp if necessary.  It'll just
> > mean an extra indirect call to do the compare when needed.
> 
> FWIW I've decided to ditch nft_data_cmp unless someone can show
> me that it's really necessary.  The reason is that nft_hash_lookup
> already uses memcmp instead of nft_data_cmp.

I don't care about nft_data_cmp, but I do care about being able to
override the compare function.
