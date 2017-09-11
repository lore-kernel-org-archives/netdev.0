From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 1/2] hv_netvsc: fix deadlock on hotplug
Date: Mon, 11 Sep 2017 14:21:49 -0700 (PDT)
Message-ID: <20170911.142149.387728437634566641.davem@davemloft.net>
References: <20170906205306.10541-1-sthemmin@microsoft.com>
        <20170906205306.10541-2-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        devel@linuxdriverproject.org, netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56086 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750993AbdIKVVw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 17:21:52 -0400
In-Reply-To: <20170906205306.10541-2-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen@networkplumber.org>
Date: Wed,  6 Sep 2017 13:53:05 -0700

> When a virtual device is added dynamically (via host console), then
> the vmbus sends an offer message for the primary channel. The processing
> of this message for networking causes the network device to then
> initialize the sub channels.
> 
> The problem is that setting up the sub channels needs to wait until
> the subsequent subchannel offers have been processed. These offers
> come in on the same ring buffer and work queue as where the primary
> offer is being processed; leading to a deadlock.
> 
> This did not happen in older kernels, because the sub channel waiting
> logic was broken (it wasn't really waiting).
> 
> The solution is to do the sub channel setup in its own work queue
> context that is scheduled by the primary channel setup; and then
> happens later.
> 
> Fixes: 732e49850c5e ("netvsc: fix race on sub channel creation")
> Reported-by: Dexuan Cui <decui@microsoft.com>
> Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
> ---
> v2 - fix module removal race with new work queue

Applied.
