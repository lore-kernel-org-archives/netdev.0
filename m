From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/12] QoS and VxLAN offloads support for Mellanox 100G mlx5 driver
Date: Tue, 16 Feb 2016 22:09:49 +0200
Message-ID: <1455653401-9808-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Matthew Finlay <matt@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59211 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756052AbcBPUK7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2016 15:10:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces QoS IEEE dcbnl support for
PFC, ETS and max rate.

In addition we added VxLAN support and introduced a patch
that modifies the driver to report checksum complete in RX path 
for all IP (tunneled and non-tunneled) traffic which is non HW LRO.

This series is applied on top of the latest mlx5_ifc and NDO fixes 
we sent to the net tree:
	net/mlx5e: Use static constant netdevice ndos
	net/mlx5e: Remove select queue ndo initialization
	net/mlx5: Use offset based reserved field names in the IFC header file

The QoS patches depend on the IFC change since they expose new fields in 
the driver/firmware API. Both QoS and VxLAN patches depend on the NDO changes,
since they add new ndo entries.

Saeed.

Achiad Shochat (3):
  net/mlx5: Introduce a new header file for physical port functions
  net/mlx5: Introduce physical port PFC access functions
  net/mlx5e: Support DCBNL IEEE PFC

Matthew Finlay (5):
  net/mlx5e: Move to checksum complete
  net/mlx5e: Protect en header file from redefinitions
  net/mlx5e: Add netdev support for VXLAN tunneling
  net/mlx5e: Add TX stateless offloads for tunneling
  net/mlx5e: Add tx inner packet counters

Saeed Mahameed (2):
  net/mlx5: Introduce physical port TC/prio access functions
  net/mlx5e: Support DCBNL IEEE ETS

Tariq Toukan (2):
  net/mlx5e: Implement DCBNL IEEE max rate
  net/mlx5e: Wake On LAN support

 drivers/infiniband/hw/mlx5/main.c                  |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   12 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    5 +-
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      |   14 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   44 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |  296 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  125 ++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  205 +++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   40 ++-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  216 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c    |  170 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h    |   48 ++++
 include/linux/mlx5/device.h                        |   17 ++
 include/linux/mlx5/driver.h                        |   33 +--
 include/linux/mlx5/mlx5_ifc.h                      |  109 +++++++-
 include/linux/mlx5/port.h                          |   87 ++++++
 17 files changed, 1365 insertions(+), 66 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vxlan.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/vxlan.h
 create mode 100644 include/linux/mlx5/port.h
