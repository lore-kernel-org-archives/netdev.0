From: David Miller <davem@davemloft.net>
Subject: Re: [IPV4]: Add an 'rtable' field in struct sk_buff to alias 'dst'
 field and avoid casts
Date: Mon, 03 Mar 2008 23:23:42 -0800 (PST)
Message-ID: <20080303.232342.221759327.davem@davemloft.net>
References: <47CCF71D.2030800@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60775
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbYCDHXn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 02:23:43 -0500
In-Reply-To: <47CCF71D.2030800@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 04 Mar 2008 08:15:41 +0100

> @@ -223,7 +223,7 @@ static int br_nf_pre_routing_finish_ipv6(struct sk_buff *skb)
>  	}
>  	nf_bridge->mask ^= BRNF_NF_BRIDGE_PREROUTING;
>  
> -	skb->dst = (struct dst_entry *)&__fake_rtable;
> +	skb->dst = &__fake_rtable.u.dst;
>  	dst_hold(skb->dst);
>  
>  	skb->dev = nf_bridge->physindev;

Any reason this case (and the next 3 hunks) can't simply
use just plain "&__fake_rtable"?  That would probably
look nicer and match the rest of this patch.


