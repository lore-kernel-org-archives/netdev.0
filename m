From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon, 02 Mar 2015 23:05:34 -0500 (EST)
Message-ID: <20150302.230534.2012113468290945834.davem@davemloft.net>
References: <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150302.171747.1423128180512348489.davem@davemloft.net>
	<1425355325.5130.157.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754577AbbCCEFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 23:05:36 -0500
In-Reply-To: <1425355325.5130.157.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Mar 2015 20:02:05 -0800

> About the GRO layout change, reason why 'struct sk_buff *last;' is at
> the end of struct napi_gro_cb is that this field is not used in fast
> path.

Understood.

While reviewing this I noticed that the jiffies timestamp in GRO cb
could really be u32 if we want instead of full "unsigned long".

> Note : We could try to use one bit in skb to advertise zero shinfo(skb).
> 
> Many skbs have a zeroed shinfo() (but shinfo->dataref == 1) , and
> dereferencing skb_shinfo adds a cache line miss. 
> 
> -> We could avoid memset(shinfo, 0, offsetof(struct skb_shared_info,
> dataref)) & atomic_set(&shinfo->dataref, 1); 
> 
>  in alloc_skb() and friends completely.
> 
> Unfortunately this kind of change would be quite invasive...

Right, all these kinds of things touch everything.
