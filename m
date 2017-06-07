From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH RFC net-next 0/4] Mellanox, MLX5 E-Switch break down
Date: Thu,  8 Jun 2017 02:42:10 +0300
Message-ID: <20170607234214.24723-1-saeedm@mellanox.com>
Cc: kernel-team@fb.com, Or Gerlitz <ogerlitz@mellanox.com>,
        Tzahi Oved <tzahio@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: netdev@vger.kernel.org, Jes Sorensen <jsorensen@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35118 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752401AbdFGXt1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2017 19:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on Jes Sorensen work to make eswitch_offloads optional at
compilation time, here is an initial RFC series that provides similar
behavior, but here we do more accurate zoom in into eswitch and we break
it into two HW components (MPFS & ESWITCH) to not break any functionality,
and provide more modular separation.

In this series we provide the following modular separation
and give the option of compiling out:

MLX5_MPFS: Multi-Physical Function Switch (MPFs) needed only for Multi-PF configurations
MLX5_ESWITCH: SRIOV Ethernet Switch

With this separation, E-Switch becomes responsible only for ethernet SRIOV and needed only
when SRIOV in enabled, otherwise it is not required.

The two patches at the beginning are for preparation and cleanup only.

Thanks,
Saeed.

Saeed Mahameed (4):
  net/mlx5e: Rearrange netdevice ops structures
  net/mlx5e: NIC netdev init flow cleanup
  net/mlx5: Separate between eswitch and MPFS l2 table logic
  net/mlx5: Add CONFIG_MLX5_ESWITCH Kconfig

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig   |  15 ++
 drivers/net/ethernet/mellanox/mlx5/core/Makefile  |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c   |  14 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  69 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c  |  13 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h  |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c   |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h   |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 189 ++++----------------
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h |  78 ++------
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  34 ++--
 drivers/net/ethernet/mellanox/mlx5/core/mpfs.c    | 205 ++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/mpfs.h    |  98 +++++++++++
 include/linux/mlx5/driver.h                       |   2 +
 14 files changed, 473 insertions(+), 270 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mpfs.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/mpfs.h

-- 
2.11.0
