From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/9] Mellanox 100G mlx5e Ethernet extensions
Date: Wed, 22 Jun 2016 19:33:08 +0300
Message-ID: <1466613197-28726-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39074 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751647AbcFVQeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 12:34:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series includes multiple features extensions for mlx5 Ethernet netdevice driver.
Namely, TX Rate limiting, RX interrupt moderation, ethtool settings.

TX Rate limiting:
	- ConnectX-4 rate limiting infrastructure
	- Set max rate NDO support

RX interrupt moderation:
	- CQE based coalescing option (controlled via priv flags)
	- Adaptive RX coalescing

ethtool settings:
	- priv flags callbacks
	- Support new ksettings API
	- Add 50G missing link mode
	- Support auto negotiation on/off

Applied on top: 0e9390ebf1fe ("Merge branch 'mlxsw-next'")

Thanks,
Saeed.

Gal Pressman (5):
  net/mlx5e: Introduce net device priv flags infrastructure
  net/mlx5e: Toggle link only after modifying port parameters
  net/mlx5e: Add 50G missing link mode to ethtool and mlx5 driver
  net/mlx5e: Use new ethtool get/set link ksettings API
  net/mlx5e: Report correct auto negotiation and allow toggling

Gil Rockah (1):
  net/mlx5e: Support adaptive RX coalescing

Tariq Toukan (1):
  net/mlx5e: CQE based moderation

Yevgeny Petrilin (2):
  net/mlx5: Rate limit tables support
  net/mlx5e: Add TXQ set max rate support

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  73 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c |   9 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 476 +++++++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 181 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c | 335 +++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |   5 +
 drivers/net/ethernet/mellanox/mlx5/core/fw.c       |   6 +
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |  10 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  48 ++-
 drivers/net/ethernet/mellanox/mlx5/core/rl.c       | 209 +++++++++
 include/linux/mlx5/device.h                        |   4 +
 include/linux/mlx5/driver.h                        |  27 ++
 include/linux/mlx5/port.h                          |  16 +-
 include/uapi/linux/ethtool.h                       |   3 +-
 15 files changed, 1179 insertions(+), 231 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_rx_am.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/rl.c

-- 
2.8.0
