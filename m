From: Patrick McHardy <kaber@trash.net>
Subject: Re: [v1 PATCH 7/14] netfilter: Use rhashtable_lookup instead of
 lookup_compare
Date: Mon, 16 Mar 2015 11:13:46 +0000
Message-ID: <20150316111345.GA22070@acer.localdomain>
References: <20150315104306.GA21999@gondor.apana.org.au>
 <E1YX624-0005ns-CB@gondolin.me.apana.org.au>
 <20150316082842.GA10896@casper.infradead.org>
 <20150316091415.GA31089@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62646 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221AbbCPLNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 07:13:51 -0400
Content-Disposition: inline
In-Reply-To: <20150316091415.GA31089@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16.03, Herbert Xu wrote:
> On Mon, Mar 16, 2015 at 08:28:42AM +0000, Thomas Graf wrote:
> > On 03/15/15 at 09:44pm, Herbert Xu wrote:
> > > The use of rhashtable_lookup_compare in nft_hash is gratuitous
> > > since the comparison function is just doing memcmp.  Furthermore,
> > > there is cruft embedded in the comparson function that should
> > > instead be moved into the caller of the lookup.
> > > 
> > > This patch moves that cruft over and replacces the call to
> > > rhashtable_lookup_compare with rhashtable_lookup.
> > > 
> > > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> > 
> > The reason for the indirection was to not bypass the abstraction
> > nft_data_cmp() provides.
> > 
> > No objection to the change but maybe leave a comment in
> > nft_data_cmp() that if one changes nft_data_cmp() one needs to
> > look at nft_hash and see if the direct use of rhashtable_lookup()
> > is still valid.
> 
> Well we could preserve nft_data_cmp if necessary.  It'll just
> mean an extra indirect call to do the compare when needed.
> 
> Patrick?

An upcoming patchset will add transaction support to sets, which needs
the callback. So please leave it for know since it will only cause
unnecessary churn.
