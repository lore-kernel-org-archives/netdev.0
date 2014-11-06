From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] ipv6: mld: fix add_grhead skb_over_panic for
 devs with large MTUs
Date: Wed, 05 Nov 2014 22:14:11 -0500 (EST)
Message-ID: <20141105.221411.110310506063834477.davem@davemloft.net>
References: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lw1a2.jing@gmail.com, netdev@vger.kernel.org, edumazet@google.com,
	hannes@stressinduktion.org, david.stevens@oracle.com
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50741 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbaKFDOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:14:15 -0500
In-Reply-To: <1415215658-10054-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed,  5 Nov 2014 20:27:38 +0100

> It has been reported that generating an MLD listener report on
> devices with large MTUs (e.g. 9000) and a high number of IPv6
> addresses can trigger a skb_over_panic():
 ...
> mld_newpack() skb allocations are usually requested with dev->mtu
> in size, since commit 72e09ad107e7 ("ipv6: avoid high order allocations")
> we have changed the limit in order to be less likely to fail.
> 
> However, in MLD/IGMP code, we have some rather ugly AVAILABLE(skb)
> macros, which determine if we may end up doing an skb_put() for
> adding another record. To avoid possible fragmentation, we check
> the skb's tailroom as skb->dev->mtu - skb->len, which is a wrong
> assumption as the actual max allocation size can be much smaller.
> 
> The IGMP case doesn't have this issue as commit 57e1ab6eaddc
> ("igmp: refine skb allocations") stores the allocation size in
> the cb[].
> 
> Set a reserved_tailroom to make it fit into the MTU and use
> skb_availroom() helper instead. This also allows to get rid of
> igmp_skb_size().
> 
> Reported-by: Wei Liu <lw1a2.jing@gmail.com>
> Fixes: 72e09ad107e7 ("ipv6: avoid high order allocations")
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

This has always been a tricky area, applied and queued up for
-stable, thanks everyone.
