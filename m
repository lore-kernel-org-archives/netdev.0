From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC 00/14] shrink skb cb to 44 bytes
Date: Mon, 02 Mar 2015 17:17:47 -0500 (EST)
Message-ID: <20150302.171747.1423128180512348489.davem@davemloft.net>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
	<1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netdev@vger.kernel.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751266AbbCBWRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 17:17:52 -0500
In-Reply-To: <1425325763.5130.123.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 02 Mar 2015 11:49:23 -0800

> Size of skb->cb[] is not the major factor. Trying to gain 4 or 8 bytes
> is not going to improve performance a lot.
> 
> The real problem is that we clear it in skb_alloc()/build_skb(), instead
> of each layer doing so at demand, and only the part that matters for
> this layer.
> 
> Basically, skb->cb[] could be 80 or 160 bytes instead of 48, and we
> should not care, as long as no layer does a stupid/lazy 
> 
> memset(skb->cb, 0, sizeof(skb->cb))
> 
> Presumably skb_clone() could be extended to receive the length of
> skb->cb[] that current layer cares about.

Regardless, I think Florian's work has value.
