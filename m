From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 3.2-3.12] skbuff: skb_segment: orphan frags before copying
Date: Fri, 27 Jun 2014 17:57:43 -0700
Message-ID: <20140628005743.GA29809@kroah.com>
References: <1402070968.23860.9.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	stable <stable@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402070968.23860.9.camel@deadeye.wl.decadent.org.uk>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 06, 2014 at 05:09:28PM +0100, Ben Hutchings wrote:
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
> This is what I used in Debian for 3.2, and I believe it applies to all
> stable branches up to 3.12 inclusive.
> 
> For branches older than 3.6, this requires cherry-picking commit
> a353e0ce0fd4 ('skbuff: add an api to orphan frags').  To avoid breaking
> OOT builds of openvswitch, which will use skb_orphan_frags() if
> available, it is also necessary to cherry-pick commit dcc0fb782b3a
> ('skbuff: export skb_copy_ubufs').

Thanks, I've done this for 3.4 now.

greg k-h
