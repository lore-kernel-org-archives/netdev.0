From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 3/3] netlink: Lock out table resizes while dumping
 Netlink sockets
Date: Wed, 21 Jan 2015 16:15:55 +1100
Message-ID: <20150121051555.GA23300@gondor.apana.org.au>
References: <cover.1421759056.git.tgraf@suug.ch>
 <e164edeacaeffee43be64d4ed6a5b5e7e8923bd1.1421759056.git.tgraf@suug.ch>
 <20150120143154.GR14883@acer.localdomain>
 <20150120145551.GH20315@casper.infradead.org>
 <20150120152149.GA3012@acer.localdomain>
 <20150120153556.GJ20315@casper.infradead.org>
 <20150121050819.GA23062@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	paulmck@linux.vnet.ibm.com, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150121050819.GA23062@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 21, 2015 at 04:08:19PM +1100, Herbert Xu wrote:
> 
> OK I think I have a solution for you guys.  But first you'll need to
> wait for me to undo the nulls stuff so I can steal that bit which
> is central to my solution.
> 
> Essentially I need a bit to indicate an entry in the bucket chain
> should be skipped, either because it has just been removed or that
> it is a walker entry (see xfrm_state_walk).
> 
> The way it'll work then is exactly the same as xfrm_state_walk,
> except that the linked list is broken up into individual buckets.
> 
> Of course we'll still need to postpone resizes (and rehashes which
> is what my work is about) during a walk but I think that's a fair
> price to pay.

I failed to address the security aspect of this approach.  Obviously
this can only work if the only entites doing the walk are trusted.
Which means that the vast majority (if not all) hash table users
would be excluded, in particular, netlink.

Even with trusted cases such as netfilter I'm uneasy about this
so I don't think I'm going to go forward with this approach.

At this point I think the best thing that'll give you stable dumps
is a separate list like xfrm_state_walk.  If you did that then
we don't need to touch rhashtable at all.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
