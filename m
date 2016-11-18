From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] mlx4 fix for shutdown flow
Date: Fri, 18 Nov 2016 13:47:09 -0500 (EST)
Message-ID: <20161118.134709.2264667169397661712.davem@davemloft.net>
References: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eranbe@mellanox.com, saeedm@mellanox.com,
        eugenia@mellanox.com
To: tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752280AbcKRSrL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2016 13:47:11 -0500
In-Reply-To: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>
Date: Thu, 17 Nov 2016 17:40:48 +0200

> This patchset fixes an invalid reference to mdev in mlx4 shutdown flow.
> 
> In patch 1, we make sure netif_device_detach() is called from shutdown flow only,
> since we want to keep it present during a simple configuration change.
> 
> In patches 2 and 3, we add checks that were missing in:
> * dev_get_phys_port_id
> * dev_get_phys_port_name
> We check the presence of the network device before calling the driver's
> callbacks. This already exists for all other ndo's.
> 
> Series generated against net commit:
> e5f6f564fd19 bnxt: add a missing rcu synchronization

I don't like where this is going nor the precedence it is setting.

If you are taking the device into a state where it cannot be safely
accessed by ndo operations, then you _MUST_ do whatever is necessary
to make sure the device is unregistered and cannot be found in the
various global lists and tables of network devices.

This is mandatory.

And this is how we must fix these kinds of problems instead of
peppering device presence test all over the place.  That will be
error prone and in the long term a huge maintainence burdon.

I'm not applying this series, sorry.  You have to fix this properly.
