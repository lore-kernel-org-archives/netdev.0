From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 00/13] Mellanox ethernet driver update Oct-27-2014
Date: Mon, 27 Oct 2014 11:37:34 +0200
Message-ID: <1414402667-8841-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32826 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751149AbaJ0JiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Oct 2014 05:38:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduces some small bug fixes, support in get/set of
vlan offload and get/set/capabilities of the link.

First 7 patches by Saeed, add support in setting/getting link speed and getting
cable capabilities.
Next 2 patches also by Saeed, enable the user to turn rx/tx vlan offloading on
and off.
Jenni fixed a bug in error flow during device initalization.
Ido and Jack fixed some code duplication and errors discovered by static checker.
last patch by me is a fix to make ethtool report the actual rings used by
indirection QP.

Patches were applied and tested against commit 61ed53d ("Merge tag 'ntb-3.18'
of git://github.com/jonmason/ntb")

Thanks,
Amir

Amir Vadai (1):
  net/mlx4_en: Report actual number of rings in indirection table

Eugenia Emantayev (1):
  net/mlx4_en: Move spinlocks and work initalizations to beginning of
    init_netdev

Ido Shamay (1):
  net/mlx4_en: Call napi_synchronize on stop_port

Jack Morgenstein (1):
  net/mlx4_en: Cleanups suggested by clang static checker

Saeed Mahameed (9):
  net/mlx4_core: Introduce mlx4_get_module_info for cable module info
    reading
  ethtool,net/mlx4_en: Cable info, get_module_info/eeprom ethtool
    support
  net/mlx4_core: Introduce ACCESS_REG CMD and eth_prot_ctrl dev cap
  net/mlx4_core: Add ethernet backplane autoneg device capability
  ethtool,net/mlx4_en: Add 100M, 20G, 56G speeds ethtool reporting
    support
  net/mlx4_en: Use PTYS register to query ethtool settings
  net/mlx4_en: Use PTYS register to set ethtool settings (Speed)
  net/mlx4_en: Add support for setting rxvlan offload OFF/ON
  net/mlx4_en: Add ethtool support for [rx|tx]vlan offload set to OFF/ON

 drivers/net/ethernet/mellanox/mlx4/cmd.c         |   9 +
 drivers/net/ethernet/mellanox/mlx4/en_clock.c    |  46 ---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c  | 503 ++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_main.c     |  12 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   | 127 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_port.c     |  24 +-
 drivers/net/ethernet/mellanox/mlx4/en_port.h     |  35 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c       |   1 -
 drivers/net/ethernet/mellanox/mlx4/en_selftest.c |  12 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c          | 123 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h     |  18 +-
 drivers/net/ethernet/mellanox/mlx4/port.c        | 156 +++++++
 include/linux/mlx4/cmd.h                         |   2 +
 include/linux/mlx4/device.h                      |  71 +++-
 include/uapi/linux/ethtool.h                     |  18 +-
 15 files changed, 1044 insertions(+), 113 deletions(-)

-- 
1.8.3.4
