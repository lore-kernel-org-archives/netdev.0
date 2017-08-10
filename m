From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH net-next 1/6] rtnetlink: use rcu_dereference_raw to
 silence rcu splat
Date: Thu, 10 Aug 2017 18:38:15 +0300
Message-ID: <20170810153815.GA22889@splinter>
References: <20170810145302.30391-1-fw@strlen.de>
 <20170810145302.30391-2-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:34035 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752059AbdHJPvT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 11:51:19 -0400
Content-Disposition: inline
In-Reply-To: <20170810145302.30391-2-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 10, 2017 at 04:52:57PM +0200, Florian Westphal wrote:
> Ido reports a rcu splat in __rtnl_register.
> The splat is correct; as rtnl_register doesn't grab any logs
> and doesn't use rcu locks either.  It has always been like this.
> handler families are not registered in parallel so there are no
> races wrt. the kmalloc ordering.
> 
> The only reason to use rcu_dereference in the first place was to
> avoid sparse from complaining about this.
> 
> Thus this switches to _raw() to not have rcu checks here.
> 
> The alternative is to add rtnl locking to register/unregister,
> however, I don't see a compelling reason to do so as this has been
> lockless for the past twenty years or so.
> 
> Fixes: 6853dd4881 ("rtnetlink: protect handler table with rcu")
> Reported-by: Ido Schimmel <idosch@idosch.org>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Tested-by: Ido Schimmel <idosch@mellanox.com>

Thanks!
