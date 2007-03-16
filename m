From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/5] AF_RXRPC: Move generic skbuff stuff from XFRM code to generic code [try #2]
Date: Fri, 16 Mar 2007 13:36:08 +0000
Message-ID: <20070316133608.GB2173@infradead.org>
References: <20070316125008.3740.44693.stgit@warthog.cambridge.redhat.com> <20070316125021.3740.49616.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, hch@infradead.org,
	arjan@infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:47247 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519AbXCPNgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 09:36:11 -0400
Content-Disposition: inline
In-Reply-To: <20070316125021.3740.49616.stgit@warthog.cambridge.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 16, 2007 at 12:50:21PM +0000, David Howells wrote:
> Move generic skbuff stuff from XFRM code to generic code so that AF_RXRPC can
> use it too.
> 
> Signed-Off-By: David Howells <dhowells@redhat.com>
> ---
> 
>  include/linux/skbuff.h |    4 +
>  include/net/esp.h      |    2 -
>  net/core/skbuff.c      |  173 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/xfrm/xfrm_algo.c   |  169 -----------------------------------------------
>  4 files changed, 177 insertions(+), 171 deletions(-)

> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -1481,5 +1481,9 @@ static inline int skb_is_gso(const struct sk_buff *skb)
>  	return skb_shinfo(skb)->gso_size;
>  }
>  
> +struct scatterlist;

normally we try to put structure forward declarations at the top of the
header instead of spreading it around all over.

> +extern int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int len);
> +extern int skb_cow_data(struct sk_buff *skb, int tailbits, struct sk_buff **trailer);

please make sure no line is longer than 80 characters.  Also shouldn't
prototypes normally be above inlines?  Or at least grouped into logical
areas?

> +/*
> + * fill a scatter-gather list with pointers into a part of a socket buffer
> + * chain
> + */

This could probably use a kdoc comment now that it's a public symbol.

> +/*
> + * Check that skb data bits are writable. If they are not, copy data
> + * to newly created private area. If "tailbits" is given, make sure that
> + * tailbits bytes beyond current end of skb are writable.
> + *
> + * Returns amount of elements of scatterlist to load for subsequent
> + * transformations and pointer to writable trailer skb.
> + */

Same here.
