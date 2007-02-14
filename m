From: Mike Accetta <maccetta@laurelnetworks.com>
Subject: Re: 2.6.20 crash in tcp_tso_segment()
Date: Wed, 14 Feb 2007 11:27:09 -0500
Message-ID: <18248.1171470429@mdt.dhcp.pit.laurelnetworks.com>
References: <20070213175121.GA27281@gondor.apana.org.au>
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from paperclip.laurelnetworks.com ([63.94.127.69]:45963 "EHLO
	paperclip.laurelnetworks.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932364AbXBNQ1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Feb 2007 11:27:35 -0500
In-reply-to: Your message of "Wed, 14 Feb 2007 04:51:21 +1100."
             <20070213175121.GA27281@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu writes:
> 
> [NETFILTER]: Clear GSO bits for TCP reset packet
> 
> The TCP reset packet is copied from the original.  This
> includes all the GSO bits which do not apply to the new
> packet.  So we should clear those bits.
> 
> Spotted by Patrick McHardy.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Something like this is needed for all trees with GSO.
> Actually it applies to TSO too although the effect there
> is a bit harder to notice.
> 
> Cheers,
> -- 
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv4/netfilter/ipt_REJECT.c b/net/ipv4/netfilter/ipt_REJECT.
> c
> index a9eb363..80f739e 100644
> --- a/net/ipv4/netfilter/ipt_REJECT.c
> +++ b/net/ipv4/netfilter/ipt_REJECT.c
> @@ -80,6 +80,10 @@ static void send_reset(struct sk_buff *oldskb, int hook)
>  	nskb->mark = 0;
>  	skb_init_secmark(nskb);
>  
> +	skb_shinfo(nskb)->gso_size = 0;
> +	skb_shinfo(nskb)->gso_segs = 0;
> +	skb_shinfo(nskb)->gso_type = 0;
> +
>  	tcph = (struct tcphdr *)((u_int32_t*)nskb->nh.iph + nskb->nh.iph->ihl);
>  
>  	/* Swap source and dest */

I picked up this patch and we ran the overnight stress tests that had been
experiencing this problem against it.  No problems so far, which based on
past results probably means the problem has indeed been fixed.  Thank you!
--
Mike Accetta

ECI Telecom Ltd.
Data Networking Division (previously Laurel Networks)
