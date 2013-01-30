From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 00/11] Mellanox Ethernet driver updates 2013-01-30
Date: Wed, 30 Jan 2013 12:34:16 +0200
Message-ID: <1359542067-10760-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog119.obsmtp.com ([207.126.144.147]:36681 "HELO
	eu1sys200aog119.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753805Ab3A3Ket (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 05:34:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains updates to mlx4 driver.
Majority of the patches are small bug fixes. Another patch is to expose through
debugfs some HW resources to be used by external tools.

Patches done against net-next commit d2ed273: "net: disallow drivers with buggy
VLAN accel to register_netdevice()"

Thanks,
Amir

Amir Vadai (1):
  net/mlx4_en: Fix transmit timeout when driver restarts port

Hadar Hen Zion (8):
  net/mlx4_core: Directly expose fields of HW flow steering rule
    control segment
  net/mlx4_core: Set correctly allow_loopback flag
  net/mlx4_en: Fix ip/udp steering rules multicast mac when attached
    via ethtool
  net/mlx4_en: Validate VLAN IDs provided in ethtool flow steering
    rules
  net/mlx4_en: Fix vlan mask for ethtool steering rules
  net/mlx4_en: Block insertion of ethtool steering rules while the
    interface is down
  net/mlx4_en: Fix ethtool rules leftovers after module unloaded
  net/mlx4_core: Use firmware driven flow steering hash mode

Matan Barak (1):
  net/mlx4_en: Don't reassign port mac address on firmware that
    supports it

Shani Michaelli (1):
  net/mlx4_en: Add debugfs support

 drivers/net/ethernet/mellanox/mlx4/Makefile        |    3 +
 drivers/net/ethernet/mellanox/mlx4/cq.c            |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_debugfs.c    |  133 ++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |  147 ++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_main.c       |    7 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   38 +++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    7 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   11 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 -
 drivers/net/ethernet/mellanox/mlx4/main.c          |   16 --
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   12 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   14 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    2 +-
 include/linux/mlx4/device.h                        |    5 +-
 15 files changed, 319 insertions(+), 84 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_debugfs.c

-- 
1.7.8.2
