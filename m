From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next2.6] ipv4: ip_ptr cleanups
Date: Wed, 15 Sep 2010 22:05:22 -0700 (PDT)
Message-ID: <20100915.220522.25138138.davem@davemloft.net>
References: <1284559471.2495.147.camel@edumazet-laptop>
	<20100915.214335.135526473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linville@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751549Ab0IPFFD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 01:05:03 -0400
In-Reply-To: <20100915.214335.135526473.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 15 Sep 2010 21:43:35 -0700 (PDT)

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Wed, 15 Sep 2010 16:04:31 +0200
> 
>> dev->ip_ptr is protected by rtnl and rcu.
>> 
>> Yet some places dont use appropriate primitives and/or locking rules.
>> 
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> 
> Applied, thanks a lot Eric.

Eric this introduces a build failure when lockdep or RCU checking
is enabled.

The problem is that inetdevice.h now references lockdep_rtnl_is_held()
but does not include rtnetlink.h

I'll simply ammend your commit with that header include added.

Just FYI...
