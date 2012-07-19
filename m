From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 0/4] net/mlx4_en: Add accelerated RFS support
Date: Thu, 19 Jul 2012 11:33:48 +0300
Message-ID: <1342686832-21406-1-git-send-email-ogerlitz@mellanox.com>
Cc: roland@kernel.org, netdev@vger.kernel.org, oren@mellanox.com,
	yevgenyp@mellanox.com, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:50388 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753338Ab2GSIeJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 04:34:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series from Amir Vadai adds support for Accelerated RFS 
to the mlx4_en Ethernet driver.

The code uses the Accelerated RFS infrastructure and HW flow steering 
to keep CPU affinity of rx interrupts and applications per TCP stream.

To do so, we had to add little protection to cpu_rmap.h against double 
inclusion. Also, added linking between CPU to IRQ using rmap in the 
mlx4_core driver.

changes from V0:
 - always use CONFIG_RFS_ACCEL instead of using twice CONFIG_CPU_RMAP directly

Or.


Amir Vadai (4):
  net/mlx4: Move MAC_MASK to a common place
  net/rps: Protect cpu_rmap.h from double inclusion
  {NET,IB}/mlx4: Add rmap support to mlx4_assign_eq
  net/mlx4_en: Add accelerated RFS support

 drivers/infiniband/hw/mlx4/main.c                  |    3 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c         |    9 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  316 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    3 +
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   12 +-
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    1 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |   16 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |    1 -
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +-
 include/linux/cpu_rmap.h                           |    4 +
 include/linux/mlx4/device.h                        |    4 +-
 include/linux/mlx4/driver.h                        |    2 +
 13 files changed, 369 insertions(+), 11 deletions(-)

CC: Amir Vadai <amirv@mellanox.com>
