From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] mlxsw: spectrum_router: avoid potential
 uninitialized data usage
Date: Mon, 03 Oct 2016 01:56:08 -0400 (EDT)
Message-ID: <20161003.015608.1875283508445426057.davem@davemloft.net>
References: <20160930161734.70928-1-arnd@arndb.de>
        <20160930161734.70928-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, yotamg@mellanox.com,
        nogahf@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38610 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752232AbcJCF4L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 01:56:11 -0400
In-Reply-To: <20160930161734.70928-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 30 Sep 2016 18:17:10 +0200

> If fi->fib_nhs is zero, the router interface pointer is uninitialized, as shown by
> this warning:
> 
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c: In function 'mlxsw_sp_router_fib_event':
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1674:21: error: 'r' may be used uninitialized in this function [-Werror=maybe-uninitialized]
> drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c:1643:23: note: 'r' was declared here
> 
> This changes the loop so we handle the case the same way as finding no router
> interface pointer attached to one of the nexthops to ensure we always
> trap here instead of using uninitialized data.
> 
> Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
