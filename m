From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH] [net-next] net/mlx5e: fix another maybe-uninitialized false-positive
Date: Sun, 5 Feb 2017 12:42:19 +0200
Message-ID: <CAJ3xEMgsXpVeL56WqimCiiZVaAA4=NJc4nCaoiewdhvQcFi6SQ@mail.gmail.com>
References: <20170203163716.3501713-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f193.google.com ([74.125.82.193]:34712 "EHLO
        mail-ot0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751169AbdBEKmU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 05:42:20 -0500
In-Reply-To: <20170203163716.3501713-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 3, 2017 at 6:37 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> In commit abeffce ("net/mlx5e: Fix a -Wmaybe-uninitialized warning"), I fixed a
> gcc warning for the ipv4 offload handling. Now we get the same warning for the
> added ipv6 support:
>
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:815:40: warning: 'out_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
>
> We can apply the same workaround here as well.
>
> Fixes: ce99f6b97fcd ("net/mlx5e: Support SRIOV TC encapsulation offloads for IPv6 tunnels")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

frustrating... I don't see the warning with gcc 5.3.1 [1], but still,
the patch is OKay

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>

[1] I used #make KCFLAGS='-Wmaybe-uninitialized'
M=drivers/net/ethernet/mellanox/mlx5/core   -j something
