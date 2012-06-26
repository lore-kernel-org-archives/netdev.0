From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4: Remove unnecessary code from rt_check_expire().
Date: Tue, 26 Jun 2012 01:37:30 -0700 (PDT)
Message-ID: <20120626.013730.902797211256084220.davem@davemloft.net>
References: <1340696398.10893.209.camel@edumazet-glaptop>
	<20120626.004658.2123525722448546355.davem@davemloft.net>
	<1340698984.10893.248.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59570 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758434Ab2FZIhd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 04:37:33 -0400
In-Reply-To: <1340698984.10893.248.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 26 Jun 2012 10:23:04 +0200

> Thats because gc_interval (60) is big compared to ip_rt_gc_timeout
> (300)
> 
> So each time rt_check_expire() triggers, we handle a big part of the
> cache. On big servers I had to lower gc_interval to smooth things.

I know it's stupid, that's why I want to eventually kill this off
completely.

> Garbage collect is needed to not waste kernel memory, even on legitimate
> traffic on a typical web server.
> 
> Taken from my 8GB machine : 
> 
> # cat /proc/sys/net/ipv4/route/gc_thresh
> 262144
> 
> 320 bytes per dst : 262144*320 = 83886080 bytes to store one dst per hash chain.

83MB on a machine with 8GB of ram that does enough networking to fill
the routing cache.  This sounds absolutely reasonable to me.

> Also, why keeping a dst in cache if no traffic uses it in a 5 minutes period ?

Traffic is bursty and periodic.

And think, we don't do any stupidity like this for the inetpeer cache
and no small cute animals have died as a result.
