From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/8] Mellanox 100G mlx5 ethtool ntuple steering
Date: Mon,  4 Jul 2016 17:23:04 +0300
Message-ID: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54664 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751414AbcGDOXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series adds Ethernet ethtool ntuple steering 'ethtool -N|U' and exposes two more
counter sets to Ethtool statistics, RDMA vport and global flow control statistics.

We start from three refactoring patches of the flow steering infrastructure
    - mlx5_add_flow_rule will now receive mlx5 flow spec to simplify and reduce 
      number of parameters
    - All low level steering objects are now wrapped in mlx5_flow_steering structure 
      for better encapsulation
    - Flow steering object will now be removed properly and generically rather than 
      traversing on a well-known steering tree objects

Patch#4 adds the infrastructure and the data structures needed for the ethtool ntuple 
steering, all implemented in a new file 'en_fs_ethtool.c'.  Add the support for set_rxnfc 
ethtool callback to add/remove/replace a flow spec of ethter type L2.

Patch#5 adds the support for L3/L4 flow specs and a higher priority in favor for L3/L4 
rules when interleaving with L2 rules.

Patch#6 adds the support for get_rxnfc ethtool callback.

Patch#7,8 adds RDMA vport and global flow control statistics.

Applied on top: 8186f6e382d8 ('net-next: mediatek: fix compile error inside mtk_poll_controller()')

Thanks,
Saeed.

Gal Pressman (2):
  net/mlx5e: Expose RDMA VPort counters to ethtool
  net/mlx5e: Expose flow control counters to ethtool

Maor Gottlieb (6):
  net/mlx5: Refactor mlx5_add_flow_rule
  net/mlx5: Introduce mlx5_flow_steering structure
  net/mlx5: Properly remove all steering objects
  net/mlx5e: Add ethtool flow steering support
  net/mlx5e: Support l3/l4 flow type specs in ethtool flow steering
  net/mlx5e: Add support to get ethtool flow rules

 drivers/infiniband/hw/mlx5/main.c                  |  21 +-
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  26 +
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  68 +--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  65 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  99 ++--
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    | 586 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  27 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  31 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 100 ++--
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  55 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 272 ++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   8 +
 include/linux/mlx5/driver.h                        |   6 +-
 include/linux/mlx5/fs.h                            |  11 +-
 15 files changed, 972 insertions(+), 405 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c

-- 
2.8.0
