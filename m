From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net] bridge: drop netfilter fake rtable unconditionally
Date: Mon, 13 Mar 2017 17:51:24 +0100
Message-ID: <20170313165124.GA32021@salvia>
References: <20170313163817.24447-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35460 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752270AbdCMQvi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 13 Mar 2017 12:51:38 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C03FC1AAAF2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:51:30 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A6413DA7FA
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:51:30 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 6E4BBDA816
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 17:51:28 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <20170313163817.24447-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 13, 2017 at 05:38:17PM +0100, Florian Westphal wrote:
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

If this helps speed up this.

Acked-by: Pablo Neira Ayuso <pablo@netfilter.org>

I also love this bridge netfilter Frankenstein a lot. Looking forward
you kill this via native bridge conntrack support for nf_tables.

Thanks.
