From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Fix up truesize after pskb_expand_head() in wireless stack
Date: Mon, 5 Jan 2009 14:32:28 +0100
Message-ID: <20090105133228.GP496@one.firstfloor.org>
References: <20090104174339.GX496@one.firstfloor.org> <1231090388.3296.17.camel@johannes> <20090104184136.GY496@one.firstfloor.org> <20090104.224916.253586382.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andi@firstfloor.org, johannes@sipsolutions.net,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linville@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:35794 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbZAENSh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 08:18:37 -0500
Content-Disposition: inline
In-Reply-To: <20090104.224916.253586382.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> At a minimum you need to add a skb->sk == NULL warn-on and abort path
> here, otherwise we will corrupt socket accounting and just explode
> somewhere else.  Adding this patch as-is will just introduce a new

I ran the patch for a few days now and nothing exploded, no messages.
I can add a skb->sk check and see if it triggers.

> There are cases where the Tx path of the wireless loops back packets
> back to the Rx path, and in such cases we certainly could see sockets
> attached to the SKB.
> 
> And Johannes is right,

He keeps talking about cases like monitoring sockets that don't
apply, which makes me somewhat suspicious of his analysis.

> absolutely cannot modify ->truesize blindly.  You can't change the
> truesize value if a socket is attached.

But pskb_expand_head modifies the size so obviously 
truesize needs to change too. So you're saying pskb_expand_head() 
is illegal when there might be a socket attached? Somehow
I suspect a lot of the pskb_expand_head() callers are failing
that requirement.

Ok I guess we could call skb_orphan() unconditionally.

Or if you guys have a better patch I can test.

-Andi

-- 
ak@linux.intel.com
