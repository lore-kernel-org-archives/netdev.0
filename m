From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net/mlx5e: Fix a -Wmaybe-uninitialized warning
Date: Mon, 16 Jan 2017 14:48:45 -0500 (EST)
Message-ID: <20170116.144845.60137914620939911.davem@davemloft.net>
References: <1484502646-29692-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadarh@mellanox.com, netdev@vger.kernel.org, arnd@arndb.de
To: ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47544 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750865AbdAPTtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:49:23 -0500
In-Reply-To: <1484502646-29692-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>
Date: Sun, 15 Jan 2017 19:50:46 +0200

> From: Arnd Bergmann <arnd@arndb.de>
> 
> As found by Olof's build bot, we gain a harmless warning about a
> potential uninitialized variable reference in mlx5:
> 
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'parse_tc_fdb_actions':
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:769:13: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:811:21: note: 'out_dev' was declared here
> 
> This was introduced through the addition of an 'IS_ERR/PTR_ERR' pair
> that gcc is unfortunately unable to completely figure out.
> 
> The problem being gcc cannot tell that if(IS_ERR()) in
> mlx5e_route_lookup_ipv4() is equivalent to checking if(err) later,
> so it assumes that 'out_dev' is used after the 'return PTR_ERR(rt)'.
> 
> The PTR_ERR_OR_ZERO() case by comparison is fairly easy to detect
> by gcc, so it can't get that wrong, so it no longer warns.
> 
> Hadar Hen Zion already attempted to fix the warning earlier by adding fake
> initializations, but that ended up not fully addressing all warnings, so
> I'm reverting it now that it is no longer needed.
> 
> Link: http://arm-soc.lixom.net/buildlogs/mainline/v4.10-rc3-98-gcff3b2c/
> Fixes: a42485eb0ee4 ("net/mlx5e: TC ipv4 tunnel encap offload error flow fixes")
> Fixes: a757d108dc1a ("net/mlx5e: Fix kbuild warnings for uninitialized parameters")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
> ---
> changes from V1:
>  - kept calling ip_route_output_key() only when CONFIG_INET is defined

Applied.
