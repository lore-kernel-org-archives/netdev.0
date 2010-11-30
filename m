From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] sched: use xps information for qdisc NUMA
 affinity
Date: Tue, 30 Nov 2010 11:21:06 -0800 (PST)
Message-ID: <20101130.112106.183035811.davem@davemloft.net>
References: <AANLkTimU+7aY0DZrnBtL=BsP_qGpCsBw0d4TCKOJSzRL@mail.gmail.com>
	<20101130.104834.112604433.davem@davemloft.net>
	<1291144047.2904.224.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, jesse.brandeburg@intel.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59270
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752388Ab0K3TUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 14:20:39 -0500
In-Reply-To: <1291144047.2904.224.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 30 Nov 2010 20:07:27 +0100

[ Jesse CC:'d ]

> netdev struct itself is shared by all cpus, so there is no real choice,
> unless you know one netdev will be used by a restricted set of
> cpus/nodes... Probably very unlikely in practice.

Unfortunately Jesse has found non-trivial gains by NUMA localizing the
netdev struct during routing tests in soome configurations.

> We could change (only on NUMA setups maybe)
> 
> struct netdev_queue *_tx;
> 
> to a
> 
> struct netdev_queue **_tx;
> 
> and allocate each "struct netdev_queue" on appropriate node, but adding
> one indirection level might be overkill...
> 
> For very hot small structures, (one or two cache lines), I am not sure
> its worth the pain.

Jesse, do you think this would help the case you were testing?
