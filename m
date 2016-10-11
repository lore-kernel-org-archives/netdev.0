From: Saeed Mahameed <saeedm@mellanox.com>
Subject: Re: [PATCH net-next] mlx5: Add MLX5_SET64_VCHK to fix BUILD_BUG_ON
Date: Tue, 11 Oct 2016 16:44:46 +0900
Message-ID: <80c54091-5d0f-89a7-83ee-cbc521246117@mellanox.com>
References: <20161011042222.2366145-1-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 8bit
Cc: <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0085.outbound.protection.outlook.com ([104.47.2.85]:62034
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752842AbcJKUYg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Oct 2016 16:24:36 -0400
In-Reply-To: <20161011042222.2366145-1-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/11/2016 01:22 PM, Tom Herbert wrote:
> I am hitting this in mlx5:
>
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function
> ‘reclaim_pages_cmd.clone.0’:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:346: error: call
> to ‘__compiletime_assert_346’ declared with attribute error:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_out, pas[i]) % 64
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c: In function ‘give_pages’:
> drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c:291: error: call
> to ‘__compiletime_assert_291’ declared with attribute error:
> BUILD_BUG_ON failed: __mlx5_bit_off(manage_pages_in, pas[i]) % 64
>
> Problem is that this is doing a BUILD_BUG_ON on a non-constant
> expression because of trying to take offset of pas[i] in the
> structure.
>
> Fix is to create MLX5_SET64_VCHK that takes an additional argument
> that is a constant. There are two callers of MLX5_SET64 that are
> trying to get a variable offset, change those to call MLX5_SET64_VCHK
> passing pas[0] as the argument to use in the offset check.
>
> Fixes: a533ed5e179cd ("net/mlx5: Pages management commands via mlx5 ifc")
> Signed-off-by: Tom Herbert <tom@herbertland.com>

Acked-by: Saeed Mahameed <saeedm@mellanox.com>
