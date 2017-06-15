From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net 0/6] Mellanox mlx5 fixes 2017-06-14
Date: Thu, 15 Jun 2017 23:55:24 +0300
Message-ID: <20170615205530.26674-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:52483 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750814AbdFOU4d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 16:56:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some fixes for the mlx5 core and netdev driver.

Please pull and let me know if there's any problem.

For -stable:
("net/mlx5: Wait for FW readiness before initializing command interface") kernels >= 4.4
("net/mlx5e: Fix timestamping capabilities reporting") kernels >= 4.5
("net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it") kernels >= 4.9
("net/mlx5e: Fix min inline value for VF rep SQs") kernels >= 4.11

The "net/mlx5e: Fix min inline .." (a oneliner patch) doesn't cleanly apply
to 4.11, it hits a contextual conflict and can be easily resolved by:
+       mlx5_query_min_inline(mdev, &priv->params.tx_min_inline_mode);
to the end of mlx5e_build_rep_netdev_priv. Note the 2nd parameter of
mlx5_query_min_inline is slightly different from the original one.

Thanks,
Saeed.

---

The following changes since commit 3b1bbafbfd14474fee61487552c9916ec1b25c58:

  Doc: net: dsa: b53: update location of referenced dsa.txt (2017-06-15 15:02:40 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-fixes-2017-06-14

for you to fetch changes up to 31ac93386d135a6c96de9c8bab406f5ccabf5a4d:

  net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it (2017-06-15 23:27:46 +0300)

----------------------------------------------------------------
mlx5-fixes-2017-06-14

----------------------------------------------------------------
Chris Mi (1):
      net/mlx5e: Fix min inline value for VF rep SQs

Eli Cohen (1):
      net/mlx5: Wait for FW readiness before initializing command interface

Maor Dickman (1):
      net/mlx5e: Fix timestamping capabilities reporting

Or Gerlitz (3):
      net/mlx5: Properly check applicability of devlink eswitch commands
      net/mlx5e: Remove TC header re-write offloading of ip tos
      net/mlx5e: Avoid doing a cleanup call if the profile doesn't have it

 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  8 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  1 -
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c | 77 +++++++++++-----------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 14 +++-
 6 files changed, 60 insertions(+), 45 deletions(-)
