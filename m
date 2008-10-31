From: David Miller <davem@davemloft.net>
Subject: Re: question: emulate_large_send_offload
Date: Fri, 31 Oct 2008 00:01:00 -0700 (PDT)
Message-ID: <20081031.000100.212963588.davem@davemloft.net>
References: <4909F4E1.3070304@gmail.com>
	<20081030.143747.163113057.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev@vger.kernel.org
To: hummerbliss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48263
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751701AbYJaHBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 03:01:25 -0400
In-Reply-To: <20081030.143747.163113057.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 30 Oct 2008 14:37:47 -0700 (PDT)

> netdev added to CC:
> 
> > Any particular reason emulate_large_send_offload call is still present in the
> > loopback_xmit (drivers/net/loopback.c)? It looks like the function has been
> > removed recently (git commit 7447ef63cf2dfdc444f4c72ae13f604350b2e25f).

Thanks for pointing this out, I've commited the following to
correct it.

commit 3a8af722495469e9c550386b910c5b93c91cf107
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Oct 31 00:00:33 2008 -0700

    net: Really remove all of LOOPBACK_TSO code.
    
    As noticed by Saikiran Madugula, commit 7447ef63cf2dfdc444f4c72ae13f604350b2e25f
    ("loopback: Remove rest of LOOPBACK_TSO code.") got rid of
    emulate_large_send_offload() but didn't get rid of the call
    site as well.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index 3b43bfd..b1ac63a 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -76,15 +76,6 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	skb->protocol = eth_type_trans(skb,dev);
 
-#ifdef LOOPBACK_TSO
-	if (skb_is_gso(skb)) {
-		BUG_ON(skb->protocol != htons(ETH_P_IP));
-		BUG_ON(ip_hdr(skb)->protocol != IPPROTO_TCP);
-
-		emulate_large_send_offload(skb);
-		return 0;
-	}
-#endif
 	dev->last_rx = jiffies;
 
 	/* it's OK to use per_cpu_ptr() because BHs are off */
