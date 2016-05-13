From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next 0/8] sched,mlx5: Offloaded TC flower filter statistics
Date: Fri, 13 May 2016 12:55:34 +0000
Message-ID: <1463144142-13810-1-git-send-email-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:41773 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751407AbcEMM5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 08:57:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduces counters support for offloaded cls_flower filters.
When the user calls 'tc show -s ..', fl_dump is called.
Before fl_dump() returns the statistics, it calls the NIC driver (using a new
ndo_setup_tc() command - TC_CLSFLOWER_STATS) to read the hardware counters and
update the statistics accordingly. A new TC action op was added (stats_update())
to be used by the NIC driver to update the statistics.

Patchset was applied and tested over commit ed7cbbc ("udp: Resolve NULL pointer
dereference over flow-based vxlan device")

Thanks,
Amir

Amir Vadai (8):
  net/sched: Enable netdev drivers to update statistics of offloaded
    actions
  net/sched: act_gact: Update statistics when offloaded to hardware
  net/sched: cls_flower: Hardware offloaded filters statistics support
  net/mlx5_core: Use a macro in mlx5_command_str()
  net/mlx5_core: Firmware commands to support flow counters
  net/mlx5_core: Introduce flow steering destination of type counter
  net/mlx5_core: Flow counters infrastructure
  net/mlx5e: Hardware offloaded flower filter statistics support

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 309 +++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  71 ++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.h    |   3 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   | 102 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  59 +++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |  26 ++
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 226 +++++++++++++++
 include/linux/mlx5/driver.h                        |  14 +
 include/linux/mlx5/fs.h                            |   7 +
 include/linux/mlx5/mlx5_ifc.h                      | 101 ++++++-
 include/net/act_api.h                              |  12 +
 include/net/pkt_cls.h                              |   1 +
 include/net/sch_generic.h                          |  20 +-
 net/sched/act_gact.c                               |  15 +
 net/sched/cls_flower.c                             |  21 ++
 18 files changed, 802 insertions(+), 195 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/fs_counters.c

-- 
2.8.0
