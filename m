From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCHv2] ipv6: implementation of reverse path filtering
Date: Mon, 06 Jun 2011 12:29:12 -0700 (PDT)
Message-ID: <20110606.122912.2162766375813456175.davem@davemloft.net>
References: <1307362957.3098.7.camel@edumazet-laptop>
	<1307382805-5753-1-git-send-email-eric@regit.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: eric@regit.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:37375 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab1FFTah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 15:30:37 -0400
In-Reply-To: <1307382805-5753-1-git-send-email-eric@regit.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Leblond <eric@regit.org>
Date: Mon,  6 Jun 2011 19:53:25 +0200

> This patch provides a basic implementation of reverse path filtering
> for IPv6. Functionnality can be activatedor desactivated through an
> rp_filter entry similar to the IPv4 one.
> 
> The functionnality is disabled by default for backward compatibility
> but should be enable on all IPv6 routers/firewalls for security reason.
> 
> This implementation is heavily based on the patch Denis Semmau proposed
> in 2006.
> 
> Signed-off-by: Eric Leblond <eric@regit.org>

Do you know that this will make every forwarding route lookup up to 3
times slower?

And you're not even caching the result like we do in ipv4, so every
single forwarded PACKET, eats this overhead.

Also, when enabled, this often breaks IPSEC.

Frankly, when I remove the routing cache from ipv4, I want to get
rid of RP filtering entirely.

I think the BSD guys did the right thing, and put this in the
firewalling code.

Then people can add a forwarding rule that does this reverse path
lookup, and the rest of the world doesn't need to eat this overhead.

Finally, I want you to tell everyone why you want this change.  People
might find a less painful way to fix that issue.
