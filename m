From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/3] mlx5e Order-0 pages for Striding RQ
Date: Thu, 15 Sep 2016 16:08:35 +0300
Message-ID: <1473944918-31290-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:50089 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750878AbcIONI7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 09:08:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

In this series, we refactor our Striding RQ receive-flow to always use
fragmented WQEs (Work Queue Elements) using order-0 pages, omitting the
flow that allocates and splits high-order pages which would fragment
and deplete high-order pages in the system.

The first patch gives a slight degradation, but opens the opportunity
to using a simple page-cache mechanism of a fair size.
The page-cache, implemented in patch 3, not only closes the performance
gap but even gives a gain.
In patch 2 we re-organize the code to better manage the calls for
alloc/de-alloc pages in the RX flow.

Series generated against net-next commit:
bed806cb266e "Merge branch 'mlxsw-ethtool'"

Thanks,
Tariq

Tariq Toukan (3):
  net/mlx5e: Single flow order-0 pages for Striding RQ
  net/mlx5e: Introduce API for RX mapped pages
  net/mlx5e: Implement RX mapped page cache for page recycle

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  70 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 149 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 359 +++++++--------------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  20 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   2 +-
 5 files changed, 291 insertions(+), 309 deletions(-)

-- 
1.8.3.1
