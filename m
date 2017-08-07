From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH ipsec-next] xfrm: check that cached bundle is still
 valid
Date: Mon, 07 Aug 2017 14:26:28 -0700 (PDT)
Message-ID: <20170807.142628.1235964040083698243.davem@davemloft.net>
References: <20170806081907.5267-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36504 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751662AbdHGV03 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Aug 2017 17:26:29 -0400
In-Reply-To: <20170806081907.5267-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Sun,  6 Aug 2017 10:19:07 +0200

> Quoting Ilan Tayari:
>   1. Set up a host-to-host IPSec tunnel (or transport, doesn't matter)
>   2. Ping over IPSec, or do something to populate the pcpu cache
>   3. Join a MC group, then leave MC group
>   4. Try to ping again using same CPU as before -> traffic
>      doesn't egress the machine at all
> 
> Ilan debugged the problem down to the fact that one of the path dsts
> devices point to lo due to earlier dst_dev_put().
> In this case, dst is marked as DEAD and we cannot reuse the bundle.
> 
> The cache only asserted that the requested policy and that of the cached
> bundle match, but its not enough - also verify the path is still valid.
> 
> Fixes: ec30d78c14a813 ("xfrm: add xdst pcpu cache")
> Reported-by: Ayham Masood <ayhamm@mellanox.com>
> Tested-by: Ilan Tayari <ilant@mellanox.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Since this regression is from the flow cache removal that went directly
into my tree, I'll apply this directly to net-next as well.

Thanks Florian.
