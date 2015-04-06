From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: protect skb->sk accesses from recursive
 dereference inside the stack
Date: Mon, 06 Apr 2015 16:14:25 -0400 (EDT)
Message-ID: <20150406.161425.780590849435253068.davem@davemloft.net>
References: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48162 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753707AbbDFUO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Apr 2015 16:14:27 -0400
In-Reply-To: <1427900864-13891-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Wed,  1 Apr 2015 17:07:44 +0200

> From: "hannes@stressinduktion.org" <hannes@stressinduktion.org>
> 
> We should not consult skb->sk for output decisions in xmit recursion
> levels > 0 in the stack. Otherwise local socket settings could influence
> the result of e.g. tunnel encapsulation process.
> 
> ipv6 does not conform with this in three places:
> 
> 1) ip6_fragment: we do consult ipv6_npinfo for frag_size
> 
> 2) sk_mc_loop in ipv6 uses skb->sk and checks if we should
>    loop the packet back to the local socket
> 
> 3) ip6_skb_dst_mtu could query the settings from the user socket and
>    force a wrong MTU
> 
> Furthermore:
> In sk_mc_loop we could potentially land in WARN_ON(1) if we use a
> PF_PACKET socket ontop of an IPv6-backed vxlan device.
> 
> Reuse xmit_recursion as we are currently only interested in protecting
> tunnel devices.
> 
> Cc: Jiri Pirko <jiri@resnulli.us>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

So I'm applying this now for 'net' and queueing it up for -stable.

In net-next, we're going to pass the tunnel socket pointer down as per
the work I've been doing over the weekend.
