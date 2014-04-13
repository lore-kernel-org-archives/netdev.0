From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before
 copying
Date: Sun, 13 Apr 2014 19:20:18 -0400 (EDT)
Message-ID: <20140413.192018.492900316749077186.davem@davemloft.net>
References: <20140410.215420.576903689381200176.davem@davemloft.net>
	<1397392513.10849.75.camel@deadeye.wl.decadent.org.uk>
	<1397429860.10849.86.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stable@vger.kernel.org, mst@redhat.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: ben@decadent.org.uk
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1397429860.10849.86.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ben Hutchings <ben@decadent.org.uk>
Date: Sun, 13 Apr 2014 23:57:40 +0100

> From: "Michael S. Tsirkin" <mst@redhat.com>
> 
> commit 1fd819ecb90cc9b822cd84d3056ddba315d3340f upstream.
> 
> skb_segment copies frags around, so we need
> to copy them carefully to avoid accessing
> user memory after reporting completion to userspace
> through a callback.
> 
> skb_segment doesn't normally happen on datapath:
> TSO needs to be disabled - so disabling zero copy
> in this case does not look like a big deal.
> 
> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> [bwh: Backported to 3.2.  As skb_segment() only supports page-frags *or* a
>  frag list, there is no need for the additional frag_skb pointer or the
>  preparatory renaming.]
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> For branches older than 3.6, commit a353e0ce0fd4 ('skbuff: add an api to
> orphan frags') is needed before this.  This is untested and I would
> appreciate a review.

I didn't do this backport because it seemed risky unless Michael
or someone else tested it thoroughly.
