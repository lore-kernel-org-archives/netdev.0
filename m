From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH 2/2] mlxsw: spectrum_router: avoid potential
 uninitialized data usage
Date: Fri, 30 Sep 2016 20:57:00 +0300
Message-ID: <20160930175700.GA641@splinter>
References: <20160930161734.70928-1-arnd@arndb.de>
 <20160930161734.70928-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Yotam Gigi <yotamg@mellanox.com>,
        Nogah Frankel <nogahf@mellanox.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:53489 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933150AbcI3SDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 14:03:16 -0400
Content-Disposition: inline
In-Reply-To: <20160930161734.70928-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 06:17:10PM +0200, Arnd Bergmann wrote:
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

For net-next:
Acked-by: Ido Schimmel <idosch@mellanox.com>

BTW, which flags did you pass to generate this error? I can only
reproduce this with EXTRA_CFLAGS="-Wmaybe-uninitialized -Werror", but
for some reason EXTRA_CFLAGS="-Wall -Werror" is silent. Any idea why? I
would like to add this to my git hooks and avoid these errors in the
future :)

Thanks!
