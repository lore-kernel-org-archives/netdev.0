From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] vlan: Fix lockdep warning when vlan dev handle
 notification
Date: Fri, 18 Apr 2014 17:49:55 -0400 (EDT)
Message-ID: <20140418.174955.2251431485153794486.davem@davemloft.net>
References: <534FAFA4.9050503@huawei.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, john.r.fastabend@intel.com, kaber@trash.net,
	netdev@vger.kernel.org, f.fainelli@gmail.com
To: dingtianhong@huawei.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbaDRVrt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Apr 2014 17:47:49 -0400
In-Reply-To: <534FAFA4.9050503@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ding Tianhong <dingtianhong@huawei.com>
Date: Thu, 17 Apr 2014 18:40:36 +0800

> When I open the LOCKDEP config and run these steps:
> 
> modprobe 8021q
> vconfig add eth2 20
> vconfig add eth2.20 30
> ifconfig eth2 xx.xx.xx.xx
> 
> then the Call Trace happened:
...
> The reason is that all of the addr_lock_key for vlan dev have the same class,
> so if we change the status for vlan dev, the vlan dev and its real dev will
> hold the same class of addr_lock_key together, so the warning happened.
> 
> we should distinguish the lock depth for vlan dev and its real dev.
...
> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>

Looks good, applied and queued up for -stable, thanks!
