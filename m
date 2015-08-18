From: kbuild test robot <fengguang.wu@intel.com>
Subject: [net-next:master 904/905]
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44: sparse: incorrect
 type in argument 1 (different base types)
Date: Tue, 18 Aug 2015 09:16:07 +0800
Message-ID: <201508180905.SEDw6zal%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: Achiad Shochat <achiad@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23991 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbbHRBNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Aug 2015 21:13:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   9cd3778cd7e8f165675705511cfcd4ea6eb88d27
commit: bbceefce9adfc9cf7b4110727c96c841ba8c7964 [904/905] net/mlx5e: Support RX CHECKSUM_COMPLETE
reproduce:
  # apt-get install sparse
  git checkout bbceefce9adfc9cf7b4110727c96c841ba8c7964
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44: sparse: incorrect type in argument 1 (different base types)
   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    expected restricted __sum16 [usertype] n
   drivers/net/ethernet/mellanox/mlx5/core/en_rx.c:173:44:    got restricted __be16 [usertype] check_sum

vim +173 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c

   157	
   158		return (ethertype == htons(ETH_P_IP) || ethertype == htons(ETH_P_IPV6));
   159	}
   160	
   161	static inline void mlx5e_handle_csum(struct net_device *netdev,
   162					     struct mlx5_cqe64 *cqe,
   163					     struct mlx5e_rq *rq,
   164					     struct sk_buff *skb)
   165	{
   166		if (unlikely(!(netdev->features & NETIF_F_RXCSUM)))
   167			goto csum_none;
   168	
   169		if (likely(cqe->hds_ip_ext & CQE_L4_OK)) {
   170			skb->ip_summed = CHECKSUM_UNNECESSARY;
   171		} else if (is_first_ethertype_ip(skb)) {
   172			skb->ip_summed = CHECKSUM_COMPLETE;
 > 173			skb->csum = csum_unfold(cqe->check_sum);
   174			rq->stats.csum_sw++;
   175		} else {
   176			goto csum_none;
   177		}
   178	
   179		return;
   180	
   181	csum_none:

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
