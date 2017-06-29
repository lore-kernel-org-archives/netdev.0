From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mlxsw: spectrum_router: Fix NULL pointer
 dereference
Date: Thu, 29 Jun 2017 13:00:18 -0400 (EDT)
Message-ID: <20170629.130018.1205616246799157439.davem@davemloft.net>
References: <20170628060312.15768-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, petrm@mellanox.com,
        mlxsw@mellanox.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753367AbdF2RAU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 13:00:20 -0400
In-Reply-To: <20170628060312.15768-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Wed, 28 Jun 2017 09:03:12 +0300

> In case a VLAN device is enslaved to a bridge we shouldn't create a
> router interface (RIF) for it when it's configured with an IP address.
> This is already handled by the driver for other types of netdevs, such
> as physical ports and LAG devices.
> 
> If this IP address is then removed and the interface is subsequently
> unlinked from the bridge, a NULL pointer dereference can happen, as the
> original 802.1d FID was replaced with an rFID which was then deleted.
> 
> To reproduce:
> $ ip link set dev enp3s0np9 up
> $ ip link add name enp3s0np9.111 link enp3s0np9 type vlan id 111
> $ ip link set dev enp3s0np9.111 up
> $ ip link add name br0 type bridge
> $ ip link set dev br0 up
> $ ip link set enp3s0np9.111 master br0
> $ ip address add dev enp3s0np9.111 192.168.0.1/24
> $ ip address del dev enp3s0np9.111 192.168.0.1/24
> $ ip link set dev enp3s0np9.111 nomaster
> 
> Fixes: 99724c18fc66 ("mlxsw: spectrum: Introduce support for router interfaces")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Petr Machata <petrm@mellanox.com>
> Tested-by: Petr Machata <petrm@mellanox.com>
> Reviewed-by: Petr Machata <petrm@mellanox.com>

Applied and queued up for -stable, thanks.
