From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: core: don't account for udp header size when
 computing seglen
Date: Tue, 08 Apr 2014 22:06:00 -0400 (EDT)
Message-ID: <20140408.220600.925628398524560053.davem@davemloft.net>
References: <1396990288-10692-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756210AbaDICGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Apr 2014 22:06:07 -0400
In-Reply-To: <1396990288-10692-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Tue,  8 Apr 2014 22:51:28 +0200

> In case of tcp, gso_size contains the tcpmss.
> 
> For UFO (udp fragmentation offloading) skbs, gso_size is the fragment
> payload size, i.e. we must not account for udp header size.
> 
> Otherwise, when using virtio drivers, a to-be-forwarded UFO GSO packet
> will be needlessly fragmented in the forward path, because we think its
> individual segments are too large for the outgoing link.
> 
> Fixes: de960aa9ab4d ("net: add and use skb_gso_transport_seglen()")
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Reported-by: Tobias Brunner <tobias@strongswan.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

I agree completely with the fix, but not necessarily with the Fixes:
tag.

All that commit did was move the code to a common location, it
always had this bug.

I suppose you could list the subsequent commit, the one that started
using this helper in the IP forwarding code, as what this "Fixes".

Thanks Florian.
