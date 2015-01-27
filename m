From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 00/11]  Mellanox ethernet driver updates Jan-27-2015
Date: Tue, 27 Jan 2015 15:57:58 +0200
Message-ID: <1422367089-13419-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:46306 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753757AbbA0N65 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jan 2015 08:58:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces some bug fixes, code cleanups and support in a new
firmware event called recoverable error events.

Patches were applied and tested against commit b8665c6 ("net: dsa/mv88e6352:
make mv88e6352_wait generic")

Changes from V0:
- Patch 6/11 ("net/mlx4_core: Fix struct mlx4_vhcr_cmd to make implicit padding
  explicit"):
  - Removed __packed
  - Rephrased commit message

- Added a new patch by Majd ("net/mlx4_core: Update the HCA core clock frequency
  after INIT_PORT")

Thanks,
Amir

Jack Morgenstein (7):
  net/mlx4_core: Add bad-cable event support
  net/mlx4_core: Add reserved lkey for VFs to QUERY_FUNC_CAP
  net/mlx4_core: Fix mem leak in SRIOV mlx4_init_one error flow
  net/mlx4_core: Adjust command timeouts to conform to the firmware spec
  net/mlx4_core: Fix HW2SW_EQ to conform to the firmware spec
  net/mlx4_core: Fix struct mlx4_vhcr_cmd to make implicit padding
    explicit
  net/mlx4_core: Remove duplicate code line from procedure mlx4_bf_alloc

Majd Dibbiny (1):
  net/mlx4_core: Update the HCA core clock frequency after INIT_PORT

Matan Barak (1):
  net/mlx4: Fix memory corruption in mlx4_MAD_IFC_wrapper

Or Gerlitz (1):
  net/mlx4_core: Fix device capabilities dumping

Saeed Mahameed (1):
  net/mlx4_en: Use ethtool cmd->autoneg as a hint for ethtool set
    settings

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  6 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    | 18 ++---
 drivers/net/ethernet/mellanox/mlx4/eq.c            | 48 ++++++------
 drivers/net/ethernet/mellanox/mlx4/fw.c            | 88 +++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/fw.h            |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          |  5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |  1 +
 drivers/net/ethernet/mellanox/mlx4/mr.c            |  4 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |  1 -
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 16 +---
 include/linux/mlx4/cmd.h                           |  6 +-
 include/linux/mlx4/device.h                        | 14 +++-
 12 files changed, 136 insertions(+), 72 deletions(-)

-- 
1.9.3
