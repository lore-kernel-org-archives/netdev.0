From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 00/10] Mellanox, mlx5 IPoIB updates 2017-06-20
Date: Tue, 20 Jun 2017 17:13:04 +0300
Message-ID: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42035 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751946AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series mainly from Erez and Feras includes some updates and ethtool/ndos
extension to the mlx5 IPoIB netdevice.

for more detalis please see tag log below.

Please pull and let me know if there's any problem.

Thanks,
Saeed.

---

The following changes since commit 910603818c6c0558fe9b5e056a3bd5195aaae1a5:

  cxgb4: notify uP to route ctrlq compl to rdma rspq (2017-06-19 10:51:45 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-updates-2017-06-20

for you to fetch changes up to 1170fbd8ff43ff7808ae4a698054762b8bfae340:

  net/mlx5e: IPoIB, Add ioctl support to IPoIB device driver (2017-06-19 18:40:20 +0300)

----------------------------------------------------------------
mlx5-updates-2017-06-20 (mlx5 IPoIB updates)

This series includes updates to mlx5 IPoIB netdevice driver (mlx5i),

1. We move ipoib files into separate directory, to allow it to grow
   separately in its own space
2. Remove HW update carrier logic from IPoIB and VF representors profiles.
3. Add basic ethtool support. (Rings options/statistics and driver info).
4. Change MTU support.
5. Xmit path statistics reporting.
6. add PTP support.

For the new ethtool ops, PTP (ioctl) and change_mtu ndos in IPoIB, we didn't add new
implementation or new logic, we only reused those callbacks from the already existing
mlx5e (ethernet netdevice profile) and exposed them in IPoIB netdevice/ethtool ops.

Thanks,
Saeed.

----------------------------------------------------------------
Erez Shitrit (6):
      net/mlx5e: IPoIB, Add ethtool support
      net/mlx5e: Add new profile function update_carrier
      net/mlx5e: IPoIB, Change parameters default values
      net/mlx5e: Use hard_mtu as part of the mlx5e_priv struct
      net/mlx5e: IPoIB, Handle change_mtu
      net/mlx5e: IPoIB, Get more TX statistics

Feras Daoud (3):
      net/mlx5e: Prevent PFC call for non ethernet ports
      net/mlx5e: IPoIB, Add PTP support to IPoIB device driver
      net/mlx5e: IPoIB, Add ioctl support to IPoIB device driver

Saeed Mahameed (1):
      net/mlx5e: IPoIB, Move to a separate directory

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  35 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  10 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 159 ++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  30 ++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |   4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   7 +-
 .../ethernet/mellanox/mlx5/core/ipoib/ethtool.c    | 136 ++++++++++++++++++
 .../mellanox/mlx5/core/{ => ipoib}/ipoib.c         |  78 +++++++++-
 .../mellanox/mlx5/core/{ => ipoib}/ipoib.h         |   7 +
 11 files changed, 406 insertions(+), 74 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
 rename drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.c (88%)
 rename drivers/net/ethernet/mellanox/mlx5/core/{ => ipoib}/ipoib.h (89%)
