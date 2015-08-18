From: David Miller <davem@davemloft.net>
Subject: Re: [net-next:master 904/905]
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44: sparse: incorrect
 type in argument 1 (different base types)
Date: Mon, 17 Aug 2015 21:23:03 -0700 (PDT)
Message-ID: <20150817.212303.155757005721528680.davem@davemloft.net>
References: <201508180905.SEDw6zal%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: achiad@mellanox.com, kbuild-all@01.org, netdev@vger.kernel.org
To: fengguang.wu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750734AbbHREXF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Aug 2015 00:23:05 -0400
In-Reply-To: <201508180905.SEDw6zal%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: kbuild test robot <fengguang.wu@intel.com>
Date: Tue, 18 Aug 2015 09:16:07 +0800

> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
> head:   9cd3778cd7e8f165675705511cfcd4ea6eb88d27
> commit: bbceefce9adfc9cf7b4110727c96c841ba8c7964 [904/905] net/mlx5e: Support RX CHECKSUM_COMPLETE
> reproduce:
>   # apt-get install sparse
>   git checkout bbceefce9adfc9cf7b4110727c96c841ba8c7964
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
>>> drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44: sparse: incorrect type in argument 1 (different base types)
>    drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    expected restricted __sum16 [usertype] n
>    drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    got restricted __be16 [usertype] check_sum

Thanks, I've committed the following:

====================
[PATCH] mlx5e: Fix sparse warnings in mlx5e_handle_csum().

>> drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44: sparse: incorrect type in argument 1 (different base types)
   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    expected restricted __sum16 [usertype] n
   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    got restricted __be16 [usertype] check_sum

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index caea062..cf00985 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -170,7 +170,7 @@ static inline void mlx5e_handle_csum(struct net_device *netdev,
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	} else if (is_first_ethertype_ip(skb)) {
 		skb->ip_summed = CHECKSUM_COMPLETE;
-		skb->csum = csum_unfold(cqe->check_sum);
+		skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
 		rq->stats.csum_sw++;
 	} else {
 		goto csum_none;
-- 
2.1.0
