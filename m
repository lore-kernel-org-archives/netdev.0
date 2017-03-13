From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bridge: drop netfilter fake rtable unconditionally
Date: Mon, 13 Mar 2017 13:01:40 -0700 (PDT)
Message-ID: <20170313.130140.895153026799583570.davem@davemloft.net>
References: <20170313163817.24447-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55390 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753330AbdCMUB5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 16:01:57 -0400
In-Reply-To: <20170313163817.24447-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 13 Mar 2017 17:38:17 +0100

> Andreas reports kernel oops during rmmod of the br_netfilter module.
> Hannes debugged the oops down to a NULL rt6info->rt6i_indev.
> 
> Problem is that br_netfilter has the nasty concept of adding a fake
> rtable to skb->dst; this happens in a br_netfilter prerouting hook.
> 
> A second hook (in bridge LOCAL_IN) is supposed to remove these again
> before the skb is handed up the stack.
> 
> However, on module unload hooks get unregistered which means an
> skb could traverse the prerouting hook that attaches the fake_rtable,
> while the 'fake rtable remove' hook gets removed from the hooklist
> immediately after.
> 
> Fixes: 34666d467cbf1e2e3c7 ("netfilter: bridge: move br_netfilter out of the core")
> Reported-by: Andreas Karis <akaris@redhat.com>
> Debugged-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---
>  David, I know you *love* the fake_rtable turd, but I think
>  this patch should go directly via net and not nf tree.
>  After all, this adds to bridge and removes from the netfilter part.

Ok, applied and queued up for -stable.
