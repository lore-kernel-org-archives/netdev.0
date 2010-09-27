From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] net: fix rcu use in ip_route_output_slow
Date: Sun, 26 Sep 2010 19:05:31 -0700 (PDT)
Message-ID: <20100926.190531.233710747.davem@davemloft.net>
References: <1285196665.2380.54.camel@edumazet-laptop>
	<20100922231221.GS2435@linux.vnet.ibm.com>
	<1285314363.2503.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758701Ab0I0CFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Sep 2010 22:05:11 -0400
In-Reply-To: <1285314363.2503.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 Sep 2010 09:46:03 +0200

> [PATCH net-next-2.6] net: fix rcu use in ip_route_output_slow
> 
> __in_dev_get_rtnl(dev_out) is called while RTNL is not held, thus
> triggers a lockdep fault.
> 
> At this point, we only perform a raw test of dev_out->ip_ptr being NULL,
> we dont need to make sure ip_ptr cant changed right after.
> 
> We can use rcu_dereference_raw() for this.
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks everyone!
