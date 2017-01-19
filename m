From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/15] Mellanox mlx5 updates 2017-01-19
Date: Fri, 20 Jan 2017 00:38:53 +0200
Message-ID: <20170119223908.15924-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59320 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751137AbdASWki (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 17:40:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This pull request includes some small mlx5 updates and two new features,
The 1st exposes new HW counters to "ethtool -S" and the other introduces
mlx5 ptp 1pps support. Details are down bleow.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 4a7c972644c1151f6dd34ff4b5f7eacb239e22ee:

  net: Remove usage of net_device last_rx member (2017-01-18 17:22:49 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-01-19

for you to fetch changes up to 3dd69e3dd21969a34406862ae299538e2e6387e7:

  net/mlx5e: Reorder update stats (2017-01-19 23:20:04 +0200)

----------------------------------------------------------------
mlx5 and mlx5e updates 2017-01-19

This series includes some updates for mlx5 core and mlx5e netdevice driver.

>From Leon, a small fix that remove an unnecessary print.

>From Eli Cohen, a fix to the FW version printout in case of internal error.

>From Eugenia Emantayev, two patches, the 1st adds mlx5 1pps (pulse per
second) mlx5 infrastructure support and the 2nd adds the necessary bits
for mlx5e ptp logic and structures.

>From Mohamad, add support for s-tagged packet receive when in promiscuous
mode.

Form Gal Pressman, MCAM (Management capabilities mask register) and PCAM
(Ports capabilities mask register) registers infrastructure, those
registers are needed in order to query the different statistics registers
support in FW, in order for the driver to enable/disable query and
reporting them back to user.  On top of this infrastructure we've exposed
new set of statistics groups:
   - MPCNT: Physical layer statistical counters (For symbol errors)
   - PPCNT: PCIe performance counters

In addition to the statistics capabilities series we've moved the mlx5 HCA
capabilities fields to a dedicated struct under the driver private data.

At the end a small patch to update & query statistics in the most desired
order.

Thanks,
Saeed.

----------------------------------------------------------------
Eli Cohen (1):
      net/mlx5: Fix version printout in case of health issue

Eugenia Emantayev (2):
      net/mlx5: Add MTPPS and MTPPSE registers infrastructure
      net/mlx5e: Implement 1PPS support

Gal Pressman (8):
      net/mlx5: Expose PCAM, MCAM registers infrastructure
      net/mlx5: Implement PCAM, MCAM access register commands
      net/mlx5: Query and cache PCAM, MCAM registers on initialization
      net/mlx5: Add PPCNT physical layer statistical group infrastructure
      net/mlx5e: Expose physical layer statistical counters to ethtool
      net/mlx5: Add MPCNT register infrastructure
      net/mlx5e: Expose PCIe statistics to ethtool
      net/mlx5: Move cached hca caps to designated caps struct

Leon Romanovsky (1):
      net/mlx5: Remove information print after attempt to load mlx5_ib module

Mohamad Haj Yahia (2):
      net/mlx5: Add support to s-tag in mlx5 firmware interface
      net/mlx5e: Receive s-tagged packets in promiscuous mode

Saeed Mahameed (1):
      net/mlx5e: Reorder update stats

 drivers/infiniband/hw/mlx5/main.c                  |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c | 218 +++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    |  91 ++++++---
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  45 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  40 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |  20 ++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   |  20 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  10 +-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  72 +++++++
 include/linux/mlx5/device.h                        |  79 ++++++--
 include/linux/mlx5/driver.h                        |  14 +-
 include/linux/mlx5/mlx5_ifc.h                      | 211 +++++++++++++++++++-
 20 files changed, 800 insertions(+), 92 deletions(-)
