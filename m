From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/15] Mellanox mlx5 updates and cleanups 2017-06-16
Date: Fri, 16 Jun 2017 00:42:37 +0300
Message-ID: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32869 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750803AbdFOVnA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series provides updates and cleanups to mlx5 driver.

For more details please see tag log below.

Please pull and let me know if there's any problem.
*This series doesn't introduce any conflict with the ongoing net
pull request.

Thanks,
Saeed.

---

The following changes since commit 3715c47bcda8bb56f7e2be27276282a2d0d48c09:

  Merge branch 'r8152-support-new-chips' (2017-06-15 14:31:56 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-06-16

for you to fetch changes up to 8812c24d28f4972c4f2b9998bf30b1f2a1b62adf:

  net/mlx5: Add fast unload support in shutdown flow (2017-06-16 00:19:44 +0300)

----------------------------------------------------------------
mlx5-updates-2017-06-16

This series provide some updates and cleanups for mlx5 core and netdevice
driver.

>From Eli Cohen, add a missing event string.
>From Or Gerlitz, some checkpatch cleanups.
>From Moni, Disalbe HW level LAG when SRIOV is enabled.
>From Tariq, A code reuse cleanup in aRFS flow.
>From Itay Aveksis, Typo fix.
>From Gal Pressman, ethtool statistics updates and "update stats" deferred work optimizations.
>From Majd Dibbiny, Fast unload support on kernel shutdown.

----------------------------------------------------------------
Eli Cohen (1):
      net/mlx5: Update eqe_type_str() event names

Gal Pressman (4):
      net/mlx5e: Rename physical symbol errors counter
      net/mlx5e: Reduce number of heap allocated buffers for update stats
      net/mlx5e: Move and optimize query out of buffer function
      net/mlx5e: Optimize update stats work

Itay Aveksis (1):
      net/mlx5e: Fix typo in warning if CQ moderation is not supported

Majd Dibbiny (2):
      net/mlx5: Expose command polling interface
      net/mlx5: Add fast unload support in shutdown flow

Moni Shoua (1):
      net/mlx5: Undo LAG upon request to create virtual functions

Or Gerlitz (5):
      net/mlx5: Fix some spelling mistakes
      net/mlx5: Avoid using multiple blank lines
      net/mlx5: Avoid blank lines before/after closing/opening braces
      net/mlx5: Align to match opening parenthesis
      net/mlx5: Avoid space after casting

Tariq Toukan (1):
      net/mlx5e: Use function to map aRFS into traffic type

 drivers/infiniband/hw/mlx5/main.c                  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 36 +++++++----
 drivers/net/ethernet/mellanox/mlx5/core/debugfs.c  |  3 -
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c  | 21 +++----
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  1 -
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 52 ++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  6 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  1 -
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       | 28 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  4 +-
 drivers/net/ethernet/mellanox/mlx5/core/lag.c      | 71 +++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 43 ++++++++++---
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  6 +-
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/qp.c       | 21 -------
 drivers/net/ethernet/mellanox/mlx5/core/sriov.c    | 15 +++--
 include/linux/mlx5/driver.h                        |  3 +
 include/linux/mlx5/mlx5_ifc.h                      | 18 ++++--
 include/linux/mlx5/qp.h                            |  2 -
 28 files changed, 227 insertions(+), 124 deletions(-)
