From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dummy: fix rcu_sched self-detected stalls
Date: Sun, 10 Jun 2012 22:48:00 -0700 (PDT)
Message-ID: <20120610.224800.602807319671005890.davem@davemloft.net>
References: <1339239546.6001.177.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39978 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751287Ab2FKFsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 01:48:03 -0400
In-Reply-To: <1339239546.6001.177.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 09 Jun 2012 12:59:06 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Trying to "modprobe dummy numdummies=30000" triggers :
> 
> INFO: rcu_sched self-detected stall on CPU { 8} (t=60000 jiffies)
> 
> After this splat, RTNL is locked and reboot is needed.
> 
> We must call cond_resched() to avoid this, even holding RTNL.
> 
> Also remove the ~32767 limit on number of dummies (PAGE_SIZE*8)
> 
> Tested with "modprobe dummy numdummies=128000"
> (it took ~12 minutes, because of sysfs)
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

I'm all for the cond_resched() change, but the name optimization
belongs generically in net/core/dev.c not in specific drivers.

So, please submit this cond_resched() fix first then we can work
on the naming performance issue.

Thanks.
