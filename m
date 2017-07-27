From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net V2 00/14] Mellanox, mlx5 fixes 2017-07-27
Date: Thu, 27 Jul 2017 16:56:03 +0300
Message-ID: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40223 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751160AbdG0N5R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some misc fixes to the mlx5 driver.

Please pull and let me know if there's any problem.

V1->V2:
 - removed redundant braces

for -stable:
4.7
net/mlx5: Fix command bad flow on command entry allocation failure

4.9
net/mlx5: Consider tx_enabled in all modes on remap
net/mlx5e: Fix outer_header_zero() check size

4.10
net/mlx5: Fix mlx5_add_flow_rules call with correct num of dests

4.11
net/mlx5: Fix mlx5_ifc_mtpps_reg_bits structure size
net/mlx5e: Add field select to MTPPS register
net/mlx5e: Fix broken disable 1PPS flow
net/mlx5e: Change 1PPS out scheme
net/mlx5e: Add missing support for PTP_CLK_REQ_PPS request
net/mlx5e: Fix wrong delay calculation for overflow check scheduling
net/mlx5e: Schedule overflow check work to mlx5e workqueue

4.12
net/mlx5: Fix command completion after timeout access invalid structure
net/mlx5e: IPoIB, Modify add/remove underlay QPN flows

I hope this is not too much, but most of the patches do apply cleanly on -stable.

Thanks,
Saeed.

---

The following changes since commit 6b84202c946cd3da3a8daa92c682510e9ed80321:

  sctp: fix the check for _sctp_walk_params and _sctp_walk_errors (2017-07-27 00:03:12 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-07-27-V2

for you to fetch changes up to bcec601f30fb41e9233674942fa4040a6e63657a:

  net/mlx5: Fix mlx5_add_flow_rules call with correct num of dests (2017-07-27 16:40:17 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-07-27-V2

----------------------------------------------------------------
Alex Vesker (1):
      net/mlx5e: IPoIB, Modify add/remove underlay QPN flows

Aviv Heller (1):
      net/mlx5: Consider tx_enabled in all modes on remap

Eran Ben Elisha (1):
      net/mlx5: Clean SRIOV eswitch resources upon VF creation failure

Eugenia Emantayev (7):
      net/mlx5: Fix mlx5_ifc_mtpps_reg_bits structure size
      net/mlx5e: Add field select to MTPPS register
      net/mlx5e: Fix broken disable 1PPS flow
      net/mlx5e: Change 1PPS out scheme
      net/mlx5e: Add missing support for PTP_CLK_REQ_PPS request
      net/mlx5e: Fix wrong delay calculation for overflow check scheduling
      net/mlx5e: Schedule overflow check work to mlx5e workqueue

Ilan Tayari (1):
      net/mlx5e: Fix outer_header_zero() check size

Moshe Shemesh (2):
      net/mlx5: Fix command completion after timeout access invalid structure
      net/mlx5: Fix command bad flow on command entry allocation failure

Paul Blakey (1):
      net/mlx5: Fix mlx5_add_flow_rules call with correct num of dests

 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |  25 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  10 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 222 +++++++++++++++------
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   1 -
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |   3 +-
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  |  16 +-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c      |  25 +--
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   5 +
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    |   5 +
 include/linux/mlx5/mlx5_ifc.h                      |  10 +-
 12 files changed, 232 insertions(+), 96 deletions(-)
