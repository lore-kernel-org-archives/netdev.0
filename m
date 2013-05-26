From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix kernel panic with icmp_dest_unreach
Date: Sat, 25 May 2013 23:27:08 -0700 (PDT)
Message-ID: <20130525.232708.324081198009097189.davem@davemloft.net>
References: <1369324409.3301.382.camel@edumazet-glaptop>
	<1369329033.3301.389.camel@edumazet-glaptop>
	<1369410598.3301.415.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel.petre@rcs-rds.ro, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44625 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755334Ab3EZG1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:27:09 -0400
In-Reply-To: <1369410598.3301.415.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 24 May 2013 08:49:58 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Daniel Petre reported crashes in icmp_dst_unreach() with following call
> graph:
 ...
> Daniel found a similar problem mentioned in 
>  http://lkml.indiana.edu/hypermail/linux/kernel/1007.0/00961.html
> 
> And indeed this is the root cause : skb->cb[] contains data fooling IP
> stack.
> 
> We must clear IPCB in ip_tunnel_xmit() sooner in case dst_link_failure()
> is called. Or else skb->cb[] might contain garbage from GSO segmentation
> layer.
> 
> A similar fix was tested on linux-3.9, but gre code was refactored in
> linux-3.10. I'll send patches for stable kernels as well.
> 
> Many thanks to Daniel for providing reports, patches and testing !
> 
> Reported-by: Daniel Petre <daniel.petre@rcs-rds.ro>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks a lot everyone.
