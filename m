From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-next-2.6 PATCH v2] net: consolidate netif_needs_gso()
	checks
Date: Sun, 7 Mar 2010 09:43:24 +0800
Message-ID: <20100307014324.GA19589@gondor.apana.org.au>
References: <20100227001954.32474.62766.stgit@localhost.localdomain> <20100227.032725.158512690.davem@davemloft.net> <20100227155245.GB3176@gondor.apana.org.au> <4B92ACB6.1090909@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:48813 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752950Ab0CGBnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Mar 2010 20:43:33 -0500
Content-Disposition: inline
In-Reply-To: <4B92ACB6.1090909@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Mar 06, 2010 at 11:27:50AM -0800, John Fastabend wrote:
>
> It looks like dev_gso_segment() could be used to "Verify header  
> integrity only" according to the comment?  If this is true I think the  
> logic should probably be
>
> 		if (netif_needs_gso(dev, skb)) {
> 			if (unlikely(dev_gso_segment(skb)))
> 				goto out_kfree_skb;
> 			if (skb->next)
> 				goto gso;
> 		} 		do your thing
>
> 		
>
> That way we linearize the skb if necessary in the case were  
> dev_gso_segment() only verifies the header and does not return a list of  
> segments.

If we needed to linearise the skb then dev_gso_segment should
perform the segmentation.  Is there a case where it doesn't?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
