From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: GRO/GSO hiding PMTU?
Date: Fri, 11 Feb 2011 10:50:22 +1100
Message-ID: <20110210235022.GA25293@gondor.apana.org.au>
References: <20110210.145555.39165146.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:37853 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757449Ab1BJXuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Feb 2011 18:50:25 -0500
Content-Disposition: inline
In-Reply-To: <20110210.145555.39165146.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 10, 2011 at 02:55:55PM -0800, David Miller wrote:
>
> I suspect that the packet arrives on eth1, accumulates into GRO, and
> thus marked as GSO as well, then GSO/TSO on output to eth0 is
> re-segmenting things transparently, and we're not getting the ICMP
> frag-needed message and the packet drop because of the skb_is_gso()
> check in ip_forward().
> 
> 	if (unlikely(skb->len > dst_mtu(&rt->dst) && !skb_is_gso(skb) &&
> 		     (ip_hdr(skb)->frag_off & htons(IP_DF))) && !skb->local_df) {
> 		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
> 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
> 			  htonl(dst_mtu(&rt->dst)));
> 		goto drop;
> 	}
> 
> So if that's what is happening, that's cute, but I think we need to
> fix this :-)

Yes this is a known problem and we do need to fix this, even if
it doesn't appear to be the cause of your immediate issue :)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
