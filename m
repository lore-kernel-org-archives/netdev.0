From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/10] xfrm: remove flow cache
Date: Tue, 18 Jul 2017 11:15:35 -0700 (PDT)
Message-ID: <20170718.111535.1186267705268802212.davem@davemloft.net>
References: <20170717115727.26042-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com,
        ilant@mellanox.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53884 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751379AbdGRSPg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 14:15:36 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Mon, 17 Jul 2017 13:57:17 +0200

> After RCU-ification of ipsec packet path there are no major scalability
> issues anymore without flow cache.
> 
> We still incur a performance hit, which comes mostly from the extra xfrm
> dst allocation/freeing.
> The last patch in the series adds a simple percpu cache to avoid the
> extra allocation if a packet matched the same policies as last one.
> 
> The main concern with this is that we will see performance drops,
> especially with large numbers of policies/SAs.
> 
> However, during hallway discussions at nfws 2017 it seemed the issues
> with flow caching outweight the removal downsides, and that it
> might be best to just 'remove it' and see where the practical issues
> (if any) will appear.
> 
> It should now be possible to also remove the genid member in the policies
> as we don't hold bundles for prolonged time anymore, but I think
> this change is controversial (and intrusive) enough as-is, so defer
> that to a later point in time.
> 
> Changes since last rfc:
> 
> - fix build failures due to implicit interrupt.h includes
> - rework last patch (pcpu cache):
>  * avoid xchg()
>  * check policies for walk.dead = 1 instead of more costly bundle_ok().
>  * flush pcpu bundles when sa/policies get removed, to allow module
>    references to go away (suggested by Ilan Tayari)

Steffen, I know you have some level of trepidation about this because
there is obviously some performance cost immediately for removing this
DoS problem.

Like the routing cache removal, most of the low hanging fruit will be
fixed shortly, and over time the bulk of the loss will be reparied one
way or another.

And, to me more importantly, killing it now gives a real incentive to
do the work for fixing that stuff now rather than later.

Therefore I have applied this series to net-next, thanks everyone.
