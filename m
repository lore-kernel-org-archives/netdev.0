From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: [PATCH 11/15]: netfilter: Use frag list abstraction interfaces.
Date: Tue, 9 Jun 2009 22:23:52 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0906092220430.30827@ask.diku.dk>
References: <20090609.050224.246127309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:48011 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbZFIUYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2009 16:24:53 -0400
In-Reply-To: <20090609.050224.246127309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 9 Jun 2009, David Miller wrote:

> --- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
> +++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
>
> @@ -57,8 +58,8 @@ sctp_manip_pkt(struct sk_buff *skb,
> 	}
>
> 	crc32 = sctp_start_cksum((u8 *)hdr, skb_headlen(skb) - hdroff);
> -	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
> -		crc32 = sctp_update_cksum((u8 *)skb->data, skb_headlen(skb),
> +	skb_walk_frags(skb, frag);

Think there is a semi-colon too much here, as skb_walk_frags expand to a 
for-loop statement, Right?

> +		crc32 = sctp_update_cksum((u8 *)frag->data, skb_headlen(frag),
> 					  crc32);
> 	crc32 = sctp_end_cksum(crc32);
> 	hdr->checksum = crc32;

Cheers,
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
