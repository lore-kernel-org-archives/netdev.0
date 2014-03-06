From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] vlan: Fix lockdep warning when vlan dev
 handle notification
Date: Thu, 06 Mar 2014 14:51:26 -0500 (EST)
Message-ID: <20140306.145126.497070034648321818.davem@davemloft.net>
References: <5318828D.3090308@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60486 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752921AbaCFTv3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 14:51:29 -0500
In-Reply-To: <5318828D.3090308@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 6 Mar 2014 22:13:33 +0800

> When I open the LOCKDEP config and run these steps:
> 
> modprobe 8021q
> vconfig add eth2 20
> vconfig add eth2.20 30
> ifconfig eth2 xx.xx.xx.xx
> 
> then the Call Trace happened:
 ...
> The reason is that all of the vlan dev have the same class key for dev_lock_list,
> if we up or down the real dev, the notification will change the state for every
> vlan dev in the vlan group, then the vlan dev will hold netif_addr_lock and the
> real dev also hold its own netif_addr_lock together, so the warning happened.
> 
> The best way to fix the problem is add a new class key for the vlan dev if its
> real dev is a vlan dev too.
> 
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

So what happens when one does:

vconfig add eth2 20
vconfig add eth2.20 30
vconfig add eth2.30 40
ifconfig eth2 xx.xx.xx.xx
