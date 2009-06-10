From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/15]: netfilter: Use frag list abstraction interfaces.
Date: Tue, 09 Jun 2009 18:05:42 -0700 (PDT)
Message-ID: <20090609.180542.57255165.davem@davemloft.net>
References: <20090609.050224.246127309.davem@davemloft.net>
	<Pine.LNX.4.64.0906092220430.30827@ask.diku.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hawk@diku.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42896
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752300AbZFJBFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 21:05:40 -0400
In-Reply-To: <Pine.LNX.4.64.0906092220430.30827@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <hawk@diku.dk>
Date: Tue, 9 Jun 2009 22:23:52 +0200 (CEST)

> 
> On Tue, 9 Jun 2009, David Miller wrote:
> 
>> --- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
>> +++ b/net/ipv4/netfilter/nf_nat_proto_sctp.c
>>
>> @@ -57,8 +58,8 @@ sctp_manip_pkt(struct sk_buff *skb,
>> 	}
>>
>> 	crc32 = sctp_start_cksum((u8 *)hdr, skb_headlen(skb) - hdroff);
>> -	for (skb = skb_shinfo(skb)->frag_list; skb; skb = skb->next)
>> -		crc32 = sctp_update_cksum((u8 *)skb->data, skb_headlen(skb),
>> +	skb_walk_frags(skb, frag);
> 
> Think there is a semi-colon too much here, as skb_walk_frags expand to
> a for-loop statement, Right?

Fixed, thanks!
