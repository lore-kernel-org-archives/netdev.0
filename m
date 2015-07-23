From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/6] ConnectX-4 driver update 2015-07-23
Date: Thu, 23 Jul 2015 23:35:55 +0300
Message-ID: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39651 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753814AbbGWUgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:36:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset introduce some performance enhancements to the ConnectX-4 driver.
1. Improving RSS distribution, and make RSS function controlable using ethtool.
2. Make memory that is written by NIC and read by host CPU allocate in the
   local NUMA to the processing CPU
3. Support tx copybreak
4. Using hardware feature called blueflame to save DMA reads when possible

Another patch by Achiad fix some cosmetic issues in the driver.

Patchset was applied and tested on top of commit 045a0fa ("ip_tunnel: Call
ip_tunnel_core_init() from inet_init()")

Thanks,
Amir

Achiad Shochat (4):
  net/mlx5e: Support TX packet copy into WQE
  net/mlx5e: TX latency optimization to save DMA reads
  net/mlx5e: Cosmetics: use BIT() instead of "1 <<", and others
  net/mlx5e: Input IPSEC.SPI into the RX RSS hash function

Saeed Mahameed (2):
  net/mlx5e: Support ETH_RSS_HASH_XOR
  net/mlx5e: Allocate DMA coherent memory on reader NUMA node

 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  48 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  47 ++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  92 ++++++++
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 258 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 134 ++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  34 ++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  32 ++-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |   3 +-
 include/linux/mlx5/driver.h                        |  12 +-
 include/linux/mlx5/mlx5_ifc.h                      |   6 +-
 12 files changed, 535 insertions(+), 149 deletions(-)

-- 
2.4.3.413.ga5fe668
