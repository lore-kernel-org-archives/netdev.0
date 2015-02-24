From: Patrick McHardy <kaber@trash.net>
Subject: Re: Ottawa and slow hash-table resize
Date: Tue, 24 Feb 2015 16:25:22 +0000
Message-ID: <20150224162521.GK3713@acer.localdomain>
References: <20150223184904.GA24955@linux.vnet.ibm.com>
 <20150224085909.GC17306@casper.infradead.org>
 <54EC46AB.3030302@iogearbox.net>
 <20150224104232.GK3713@acer.localdomain>
 <54ECA374.7060402@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	davem@davemloft.net, alexei.starovoitov@gmail.com,
	herbert@gondor.apana.org.au, ying.xue@windriver.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	josh@joshtriplett.org
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45805 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbbBXQZ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 11:25:28 -0500
Content-Disposition: inline
In-Reply-To: <54ECA374.7060402@akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24.02, Josh Hunt wrote:
> On 02/24/2015 04:42 AM, Patrick McHardy wrote:
> >On 24.02, Daniel Borkmann wrote:
> >>
> >>Simplest fix would be, similarly as in other users:
> >>
> >>diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
> >>index 61e6c40..47abdca 100644
> >>--- a/net/netfilter/nft_hash.c
> >>+++ b/net/netfilter/nft_hash.c
> >>@@ -192,6 +192,7 @@ static int nft_hash_init(const struct nft_set *set,
> >>  		.key_offset = offsetof(struct nft_hash_elem, key),
> >>  		.key_len = set->klen,
> >>  		.hashfn = jhash,
> >>+		.max_shift = 20, /* 1M */
> >>  		.grow_decision = rht_grow_above_75,
> >>  		.shrink_decision = rht_shrink_below_30,
> >>  	};
> >>
> >>But I presume Josh wanted to resend his code ... or wait for nft
> >>folks to further review?
> >
> >We're perfectly fine with that patch, although I'd say lets use a
> >slightly larger value (24) to cover what we know people are doing
> >using ipset.
> 
> I just sent a patch similar to Daniel's in the set 'nft hash resize fixes'
> using a max_shift value of 24. I still think this value should be tunable,
> but sent the patch to fix the immediate expansion problem for now.

Thanks. I actually don't think we should require that parameter at
all, any limits shouldn't be imposed by the data structure but by
the code using it. We're perfectly fine using the available memory
as a limit if the users wants this, provided that hash expansion
succeeds and the lookups stay fast.

But for now let's just fix the immediate problem, I agree.
