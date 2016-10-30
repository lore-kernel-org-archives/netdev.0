From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next V2 00/15][PULL request] Mellanox mlx5 core driver updates 2016-10-25
Date: Sun, 30 Oct 2016 23:21:53 +0200
Message-ID: <1477862528-4328-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Dave and Doug,

This series contains some updates and fixes of mlx5 core and
IB drivers with the addition of two features that demand
new low level commands and infrastructure updates.
 - SRIOV VF max rate limit support
 - mlx5e tc support for FWD rules with counter.

Needed for both net and rdma subsystems.

Updates and Fixes:
>From Saeed Mahameed (2):
  - mlx5 IB: Skip handling unknown mlx5 events
  - Add ConnectX-5 PCIe 4.0 VF device ID

>From Artemy Kovalyov (2):
  - Update struct mlx5_ifc_xrqc_bits
  - Ensure SRQ physical address structure endianness

>From Eugenia Emantayev (1):
  - Fix length of async_event_mask

New Features:
>From Mohamad Haj Yahia (3): mlx5 SRIOV VF max rate limit support
  - Introduce TSAR manipulation firmware commands
  - Introduce E-switch QoS management
  - Add SRIOV VF max rate configuration support

>From Mark Bloch (7): mlx5e Tc support for FWD rule with counter
  - Don't unlock fte while still using it
  - Use fte status to decide on firmware command
  - Refactor find_flow_rule
  - Group similar rules under the same fte
  - Add multi dest support
  - Add option to add fwd rule with counter
  - mlx5e tc support for FWD rule with counter
  Mark here fixed two trivial issues with the flow steering core, and did
  some refactoring in the flow steering API to support adding mulit destination
  rules to the same hardware flow table entry at once.  In the last two patches
  added the ability to populate a flow rule with a flow counter to the same flow entry.

V2: Dropped some patches that added new structures without adding any usage of them.
    Added SRIOV VF max rate configuration support patch that introduces
    the usage of the TSAR infrastructure.
    Added flow steering fixes and refactoring in addition to mlx5 tc
    support for forward rule with counter.

The following changes since commit a909d3e636995ba7c349e2ca5dbb528154d4ac30
    Linux 4.9-rc3

are available in the git repository at:
    git://git.kernel.org/pub/scm/linux/kernel/git/leon/linux-rdma.git tags/shared-for-4.10-1

for you to fetch changes up to e37a79e5d4cac3831fac3d4afbf2461f56b4b7bd
    net/mlx5e: Add tc support for FWD rule with counter

Thanks,
Saeed & Leon.

Artemy Kovalyov (2):
  net/mlx5: Update struct mlx5_ifc_xrqc_bits
  net/mlx5: Ensure SRQ physical address structure endianness

Eugenia Emantayev (1):
  net/mlx5: Fix length of async_event_mask

Mark Bloch (7):
  net/mlx5: Don't unlock fte while still using it
  net/mlx5: Use fte status to decide on firmware command
  net/mlx5: Refactor find_flow_rule
  net/mlx5: Group similer rules under the same fte
  net/mlx5: Add multi dest support
  net/mlx5: Add option to add fwd rule with counter
  net/mlx5e: Add tc support for FWD rule with counter

Mohamad Haj Yahia (3):
  net/mlx5: Introduce TSAR manipulation firmware commands
  net/mlx5: Introduce E-switch QoS management
  net/mlx5: Add SRIOV VF max rate configuration support

Saeed Mahameed (2):
  IB/mlx5: Skip handling unknown events
  net/mlx5: Add ConnectX-5 PCIe 4.0 VF device ID

 drivers/infiniband/hw/mlx5/main.c                  |  16 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h               |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  13 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  |  38 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  49 +--
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  15 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   6 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  35 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 244 ++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |  36 ++-
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  60 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  | 358 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   5 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   1 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/rl.c       |  65 ++++
 include/linux/mlx5/fs.h                            |  28 +-
 include/linux/mlx5/mlx5_ifc.h                      | 201 +++++++++++-
 include/linux/mlx5/srq.h                           |   2 +-
 22 files changed, 927 insertions(+), 289 deletions(-)

-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
