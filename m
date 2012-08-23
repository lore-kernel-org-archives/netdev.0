From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next v3] net: remove delay at device dismantle
Date: Thu, 23 Aug 2012 19:21:18 +0100
Message-ID: <1345746078.2579.10.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345691986.5904.40.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <gaofeng@cn.fujitsu.com>,
	<netdev@vger.kernel.org>, <maheshb@google.com>,
	<therbert@google.com>, <ebiederm@xmission.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:61685 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1759177Ab2HWSVW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:21:22 -0400
In-Reply-To: <1345691986.5904.40.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-23 at 05:19 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> I noticed extra one second delay in device dismantle, tracked down to
> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
> 
> These call_rcu() were posted by rt_free(struct rtable *rt) calls.
> 
> We then wait a little (but one second) in netdev_wait_allrefs() before
> kicking again NETDEV_UNREGISTER.
> 
> As the call_rcu() are now completed, dst_dev_event() can do the needed
> device swap on busy dst.
> 
> To solve this problem, add a new NETDEV_UNREGISTER_FINAL, called
> after a rcu_barrier(), but outside of RTNL lock.
[...]

So what happens when this races with register_netdevice_notifier()?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
