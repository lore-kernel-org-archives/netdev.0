From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/15] Mellanox, mlx5 updates 2017-06-23
Date: Fri, 23 Jun 2017 17:26:07 +0300
Message-ID: <20170623142622.16565-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:54006 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751488AbdFWO1q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 10:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series mainly from Tariq and Or includes updates to mlx5 core and
netdevice dirvers.

>From Tariq, RX path improvments.
>From Or, header re-write updates and FW flash support.
For more detalis please see tag log below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 3d09198243b89457649241fb63f809a96a22a8ce:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net (2017-06-21 17:35:22 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-06-23

for you to fetch changes up to 137ffd15f71ec29ff1a57728081569698591225a:

  net/mlx5: Fix offset of hca cap reserved field (2017-06-22 14:30:14 +0300)

----------------------------------------------------------------
mlx5-updates-2017-06-23

This series provides some updates to the mlx5 core and netdevice drivers.

Three patches from Tariq, Introduces page reuse mechanism in non-Striding
RQ RX datapath, we allow the the RX descriptor to reuse its allocated page
as much as it could, until the page is fully consumed. RX page reuse
reduces the stress on page allocator and improves RX performance especially
with high speeds (100Gb/s).

Next four patches of the series from Or allows to offload tc flower matching
on ttl/hoplimit and header re-write of hoplimit.

The rest of  the series from Yotam and Or enhances mlx5 to support FW flashing
through the mlxfw module, in a similar manner done by the mlxsw driver.
Currently, only ethtool based flashing is implemented, where both Eth and IB ports
are supported.

Thanks,
Saeed.

----------------------------------------------------------------
Or Gerlitz (12):
      net/mlx5e: Relocate the TC match on ip tos offload code section
      net/mlx5e: Offload TC matching on ip ttl
      net/mlx5e: Use macro for TC header re-write offload field mapping
      net/mlx5e: Add header re-write offloading of IPv6 hop-limit
      mlxfw: Make the module selectable
      net/mlx5: Add MCC (Management Component Control) register definitions
      net/mlx5: Enhance MCAM reg to allow query on access reg support
      net/mlx5: Add helper functions to set/query MCC/MCDA/MCQI registers
      net/mlx5: Add mlxfw callbacks
      net/mlx5e: Support the flash device ethtool callback
      net/mlx5e: IPoIB, Support the flash device ethtool callback
      net/mlx5: Fix offset of hca cap reserved field

Tariq Toukan (3):
      net/mlx5e: Build SKB with exact frag_size
      net/mlx5e: Enhance RX SKB headroom logic
      net/mlx5e: Introduce RX Page-Reuse

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  17 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  35 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  46 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 121 +++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 106 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       | 268 +++++++++++++++++++++
 .../ethernet/mellanox/mlx5/core/ipoib/ethtool.c    |   9 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   3 +
 drivers/net/ethernet/mellanox/mlxfw/Kconfig        |   8 +-
 drivers/net/ethernet/mellanox/mlxfw/mlxfw.h        |   9 +
 include/linux/mlx5/device.h                        |   3 +
 include/linux/mlx5/driver.h                        |   3 +
 include/linux/mlx5/mlx5_ifc.h                      | 103 +++++++-
 14 files changed, 634 insertions(+), 101 deletions(-)
