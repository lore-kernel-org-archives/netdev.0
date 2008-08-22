From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] [PATCH] ip: skip IP checksum for skbs with
 CHECKSUM_UNNECESSARY set
Date: Fri, 22 Aug 2008 18:33:20 -0400
Message-ID: <20080822183320.1d8fbe34@speedy>
References: <200808222224.32311.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:46248 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbYHVWdX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2008 18:33:23 -0400
In-Reply-To: <200808222224.32311.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 22 Aug 2008 22:24:31 +0300
Octavian Purdila <opurdila@ixiacom.com> wrote:

> 
> We are working on a completely in hardware LRO implementation and this patch 
> would simplify the hardware implementation. Is this acceptable?
> 
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -415,7 +415,8 @@ int ip_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt,
>  
>         iph = ip_hdr(skb);
>  
> -       if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> +       if (!skb_csum_unnecessary(skb) &&
> +           unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
>                 goto inhdr_error;
>  
>         len = ntohs(iph->tot_len);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

The overhead of the additional conditional might outweigh any benefit.
