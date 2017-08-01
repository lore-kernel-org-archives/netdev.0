From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fib: Fix NULL pointer deref during
 fib_sync_down_dev()
Date: Mon, 31 Jul 2017 17:51:41 -0700 (PDT)
Message-ID: <20170731.175141.2110537819573316012.davem@davemloft.net>
References: <20170728202744.2729-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, mirq-linux@rere.qmqm.pl,
        xiyou.wangcong@gmail.com
To: idosch@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48588 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdHAAvl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:51:41 -0400
In-Reply-To: <20170728202744.2729-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>
Date: Fri, 28 Jul 2017 23:27:44 +0300

> Micha©© reported a NULL pointer deref during fib_sync_down_dev() when
> unregistering a netdevice. The problem is that we don't check for
> 'in_dev' being NULL, which can happen in very specific cases.
> 
> Usually routes are flushed upon NETDEV_DOWN sent in either the netdev or
> the inetaddr notification chains. However, if an interface isn't
> configured with any IP address, then it's possible for host routes to be
> flushed following NETDEV_UNREGISTER, after NULLing dev->ip_ptr in
> inetdev_destroy().
> 
> To reproduce:
> $ ip link add type dummy
> $ ip route add local 1.1.1.0/24 dev dummy0
> $ ip link del dev dummy0
> 
> Fix this by checking for the presence of 'in_dev' before referencing it.
> 
> Fixes: 982acb97560c ("ipv4: fib: Notify about nexthop status changes")
> Signed-off-by: Ido Schimmel <idosch@mellanox.com>
> Reported-by: Micha©© Miros©©aw <mirq-linux@rere.qmqm.pl>
> ---
> Please consider this for -stable.

Applied and queued up for -stable, thanks!
