From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/17] Mellanox, mlx5 updates 2017-09-03
Date: Sun,  3 Sep 2017 07:21:00 +0300
Message-ID: <20170903042117.28923-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, kernel-team@fb.com,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59966 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750795AbdICEWL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 00:22:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Tariq includes micro data path optimization for mlx5e
netdevice driver.

Sorry about the late submission but most of the patches are really
small and trivial.

For more details please see tag log message below.
Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 32d9b70a053a835b4dfb33158fc03795ea103e44:

  Merge branch 'hv_netvsc-channel-settings-cleanups-and-fixes' (2017-09-01 20:39:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-09-03

for you to fetch changes up to d4b6c48800dda97f5a0824305d7c8175a127d414:

  net/mlx5e: Distribute RSS table among all RX rings (2017-09-03 06:34:09 +0300)

----------------------------------------------------------------
mlx5-updates-2017-09-03

This series from Tariq includes micro data path optimization for mlx5e
netdevice driver.

Mainly Tariq introduces the following changes to NAPI and RX handling
path of the driver:
 - RX ring structure reorganizing
 - Trivial code refactoring and optimization
 - NAPI busy-poll for when fast UMR is in progress
 - Non-atomic state operations in NAPI context
 - Remove unnecessary fields from fast path structures
 - page-cache micro optimization
 - Rely on NAPI to avoid missing an IRQ for RX/TX shared NAPI contexts
 - Stop NAPI when irq changes affinity
 - Distribute RSS table among all RX rings

Thanks,
Saeed.

----------------------------------------------------------------
Tariq Toukan (17):
      net/mlx5e: Reorganize struct mlx5e_rq
      net/mlx5e: Replace multiplication by stride size with a shift
      net/mlx5e: Remove unnecessary wqe_sz field from RQ buffer
      net/mlx5e: Use memset to init skbs_frags array to zeros
      net/mlx5e: Small enhancements for RX MPWQE allocation and free
      net/mlx5e: NAPI busy-poll when UMR post is in progress
      net/mlx5e: Early-return on empty completion queues
      net/mlx5e: Refactor data-path lro header function
      net/mlx5e: Non-atomic indicator for ring enabled state
      net/mlx5e: Non-atomic RQ state indicator for UMR WQE in progress
      net/mlx5e: Type-specific optimizations for RX post WQEs function
      net/mlx5e: Remove unnecessary fields in ICO SQ
      net/mlx5e: Don't recycle page if moved to far NUMA
      net/mlx5e: Slightly increase RX page-cache size
      net/mlx5e: Use kernel's mechanism to avoid missing NAPIs
      net/mlx5e: Stop NAPI when irq balancer changes affinity
      net/mlx5e: Distribute RSS table among all RX rings

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  49 ++---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  55 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 225 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  18 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  88 ++------
 include/linux/mlx5/device.h                        |   2 +-
 8 files changed, 216 insertions(+), 228 deletions(-)
