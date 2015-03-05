From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Thu, 05 Mar 2015 16:06:03 -0500 (EST)
Message-ID: <20150305.160603.1420680288391678472.davem@davemloft.net>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
	<1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org, fw@strlen.de
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33381 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751220AbbCEVGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 16:06:06 -0500
In-Reply-To: <1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Mar 2015 12:03:03 -0800

> Yes, but then your patch is all about reducing flow compares to a single
> u32 comparison in qdiscs (and elsewhere)
> 
> choke for example explicitly wants to make sure we drop a companion
> if incoming packet belongs to the same flow.
> 
> Relying on a 'strong hash' whatever it can be was not considered in
> Choke paper. There is no mention of a stochastic match.
> 
> If we no longer can store the keys in skb->cb[], fine (although I claim
> skb->cb[] size should be irrelevant, see our discussion on this topic
> with Florian)
>  -> Just recompute the keys, using a local variable, from packet
> content. Yes, it will be more expensive, but hey, we get what we want.
> 
> Same for sfq : your skb_get_hash_perturb() doesn't address the point I
> made earlier.
> 
> It is only giving a false sense of security.
> I would rather not spread it.
> (Note that there is no documentation or changelog to explain the
> pro/cons)
> 
> I doubt OVS would condense their flow keys in a single u32...

I'm largely siding with Eric on this.  And the Choke argument is
a strong one.

Therefore I'm deferring this series for now, more thought and work
is definitely needed.
