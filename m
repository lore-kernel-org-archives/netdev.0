From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next, V3 0/2] net: force refragmentation for DF
 reassembed skbs
Date: Wed, 27 May 2015 13:04:01 -0400 (EDT)
Message-ID: <20150527.130401.726728313381454100.davem@davemloft.net>
References: <1432305171-21932-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37268 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751600AbbE0REE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 13:04:04 -0400
In-Reply-To: <1432305171-21932-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 22 May 2015 16:32:49 +0200

> output path tests:
> 
>     if (skb->len > mtu) ip_fragment()
> 
> This breaks connectivity in one corner case:
>  If the skb was reassembled, but has the DF bit set and ..
>  .. its reassembled size is <= outdev mtu ..
>  .. we will forward a DF packet larger than what the sender
>     transmitted on wire.
> 
> If a router later in the path can't forward this packet, it will send an
> icmp error in response to an mtu that the original sender never exceeded.
> 
> This changes ipv4 defrag/output path to
> 
> a) force refragmentation for DF reassembled skbs and
> b) set DF bit on all fragments when refragmenting if it was set on original
> frags.
 ...

Series applied, thanks Florian.
