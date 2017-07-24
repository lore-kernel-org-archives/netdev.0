From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] mlxsw: spectrum_router: Don't offload routes next
 in list
Date: Mon, 24 Jul 2017 14:15:03 -0700 (PDT)
Message-ID: <20170724.141503.940004981053393636.davem@davemloft.net>
References: <20170721160428.23149-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43194 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932744AbdGXVPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:15:04 -0400
In-Reply-To: <20170721160428.23149-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 21 Jul 2017 18:04:28 +0200

> From: Ido Schimmel <idosch@mellanox.com>
> 
> Each FIB node holds a linked list of routes sharing the same prefix and
> length. In the case of IPv4 it's ordered according to table ID, metric
> and TOS and only the first route in the list is actually programmed to
> the device.
> 
> In case a gatewayed route is added somewhere in the list, then after its
> nexthop group will be refreshed and become valid (due to the resolution
> of its gateway), it'll mistakenly overwrite the existing entry.
> 
> Example:
> 192.168.200.0/24 dev enp3s0np3 scope link metric 1000 offload
> 192.168.200.0/24 via 192.168.100.1 dev enp3s0np3 metric 1000 offload
> 
> Both routes are marked as offloaded despite the fact only the first one
> should actually be present in the device's table.
> 
> When refreshing the nexthop group, don't write the route to the device's
> table unless it's the first in its node.
> 
> Fixes: 9aecce1c7d97 ("mlxsw: spectrum_router: Correctly handle identical routes")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Applied.
