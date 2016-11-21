From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/7] Mellanox 100G mlx5 SRIOV switchdev update
Date: Mon, 21 Nov 2016 15:05:54 +0200
Message-ID: <1479733561-26601-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46913 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932308AbcKUNHT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 08:07:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Roi and Or further enhances the new SRIOV switchdev mode.

Roi's patches deal with allowing users to configure though devlink
the level of inline headers that the VF should be setting in order for
the eswitch HW to do proper matching. We also enforce that the matching
required for offloaded TC rules is aligned with that level on the PF driver.

Or's patches deals with allowing the user to control on the VF operational
link state through admin directives on the mlx5 VF rep link. Also in this series
is implementation of HW and SW counters for the mlx5 VF rep which is aligned
with the design set by commit a5ea31f57309 'Merge branch net-offloaded-stats'.

This series was generated against commit
f81a8a02bb3b ("Merge branch 'mV88e6xxx-interrupt-fixes'")

Thanks,
Saeed.

Or Gerlitz (3):
  net: Add net-device param to the get offloaded stats ndo
  net/mlx5e: Support HW (offloaded) and SW counters for SRIOV switchdev
    mode
  net/mlx5e: Support VF vport link state control for SRIOV switchdev
    mode

Roi Dayan (4):
  devlink: Add E-Switch inline mode control
  net/mlx5: Enable to query min inline for a specific vport
  net/mlx5: E-Switch, Add control for inline mode
  net/mlx5e: Enforce min inline mode when offloading flows

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  15 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  42 +++---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   | 144 +++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  46 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   4 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 141 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |  14 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +-
 include/linux/mlx5/vport.h                         |  10 +-
 include/linux/netdevice.h                          |   4 +-
 include/net/devlink.h                              |   2 +
 include/uapi/linux/devlink.h                       |   8 ++
 net/core/devlink.c                                 |  70 +++++++---
 net/core/rtnetlink.c                               |   4 +-
 17 files changed, 438 insertions(+), 72 deletions(-)

-- 
2.7.4
