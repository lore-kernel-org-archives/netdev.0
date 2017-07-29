From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH net] ipv4: fib: Fix NULL pointer deref during
 fib_sync_down_dev()
Date: Sat, 29 Jul 2017 10:48:04 +0200
Message-ID: <20170729084804.sqm6gjz3u5r5xfk3@qmqm.qmqm.pl>
References: <20170728202744.2729-1-idosch@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        xiyou.wangcong@gmail.com
To: Ido Schimmel <idosch@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([91.227.64.183]:41942 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753175AbdG2IsI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 29 Jul 2017 04:48:08 -0400
Content-Disposition: inline
In-Reply-To: <20170728202744.2729-1-idosch@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 28, 2017 at 11:27:44PM +0300, Ido Schimmel wrote:
> Micha³ reported a NULL pointer deref during fib_sync_down_dev() when
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
> Reported-by: Micha³ Miros³aw <mirq-linux@rere.qmqm.pl>

Tested-by: Micha³ Miros³aw <mirq-linux@rere.qmqm.pl>

Thanks!
