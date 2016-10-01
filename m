From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 1/2] net/mlx5e: shut up maybe-uninitialized warning
Date: Sat, 1 Oct 2016 18:08:02 +0300
Message-ID: <CAJ3xEMgoPh0teRZYvp42CkbU62K=1sZvdbY1zeRbHYz-AzPm3g@mail.gmail.com>
References: <20160930161734.70928-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Amir Vadai <amirva@mellanox.com>,
        Maor Gottlieb <maorg@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f65.google.com ([209.85.218.65]:33085 "EHLO
        mail-oi0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750946AbcJAPID (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Oct 2016 11:08:03 -0400
In-Reply-To: <20160930161734.70928-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 7:17 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> Build-testing this driver with -Wmaybe-uninitialized gives a new false-positive
> warning that I can't really explain:
>
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c: In function 'mlx5e_configure_flower':
> drivers/net/ethernet/mellanox/mlx5/core/en_tc.c:509:3: error: 'old_attr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
>
> It's obvious from the code that 'old_attr' is initialized whenever 'old'
> is non-NULL here. The warning appears with all versions I tested from gcc-4.7
> through gcc-6.1, and I could not come up with a way to rewrite the function
> in a more readable way that avoids the warning, so I'm adding another
> initialization to shut it up.
>
> Fixes: 8b32580df1cb ("net/mlx5e: Add TC vlan action for SRIOV offloads")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Yeah, this is clearly false positive and I was sure that newish GCCs
don't show that, but you are the master here.. so FWIW

Acked-by: Or Gerlitz <ogerlitz@mellanox.com>
