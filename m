From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Fw: 2.6.18-rc4-mm3: BUG: warning at include/net/dst.h:154/dst_release()
Date: Tue, 29 Aug 2006 20:24:33 +0200
Message-ID: <20060829182433.GB3470@postel.suug.ch>
References: <20060829091656.d4158404.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:61648 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S965244AbWH2SYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 14:24:12 -0400
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060829091656.d4158404.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Andrew Morton <akpm@osdl.org> 2006-08-29 09:16
> 
> 
> Begin forwarded message:
> 
> Date: Tue, 29 Aug 2006 10:25:07 -0400
> From: Valdis.Kletnieks@vt.edu
> To: Andrew Morton <akpm@osdl.org>
> Cc: linux-kernel@vger.kernel.org
> Subject: 2.6.18-rc4-mm3: BUG: warning at include/net/dst.h:154/dst_release()
> 
> 
> Seeing this a lot on 2.6.18-rc4-mm3 with 2 different stack tracebacks
> (one for received packets, other for sending).  I already picked up the
> fix for the ^ / confusion in fib_rules.c and that didn't help matters.

Should be fixed by this patch:

commit 4305fabb7e4c63ddc3a4fd38aab9ec3f6575b111
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Aug 28 13:19:30 2006 -0700

    [IPV6] ROUTE: Fix dst reference counting in ip6_pol_route_lookup().

    In ip6_pol_route_lookup(), when we finish backtracking at the
    top-level root entry, we need to hold it.

    Bug noticed by Mitsuru Chinen <CHINEN@jp.ibm.com>.

    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ad3e3fb..4a46a85 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -510,8 +510,8 @@ restart:
        rt = fn->leaf;
        rt = rt6_device_match(rt, fl->oif, flags);
        BACKTRACK(&fl->fl6_src);
-       dst_hold(&rt->u.dst);
 out:
+       dst_hold(&rt->u.dst);
        read_unlock_bh(&table->tb6_lock);

        rt->u.dst.lastuse = jiffies;

