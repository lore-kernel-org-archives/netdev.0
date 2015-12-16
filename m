From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/2] Introduce mlx5 ethernet timestamping
Date: Wed, 16 Dec 2015 18:46:32 +0200
Message-ID: <1450284394-32386-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51490 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S933012AbbLPQrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2015 11:47:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces the support for ConnectX-4 timestamping
and the PTP kernel interface.

First patch fixes a bug in SKB data pointer in device xmit function.
Second patch adds the needed low level helpers for:
	- Fetching the hardware clock (hardware internal timer)
	- Parsing CQEs timestamps
	- Device frequency capability

Added new en_clock.c file that handles all needed timestamping
operations:
	- Internal clock structure initialization.
	- PTP registration and cleanup.
	- PTP callbacks implementation.

Added the needed ioctl for setting/getting the current timestamping
configuration, and used this configuration in RX/TX data path to 
fill the SKB with the timestamp.

Eran Ben Elisha (2):
  net/mlx5_en: Restore the skb data pointer after xmit is finished
  net/mlx5_en: Add HW timestamping (TS) support

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   25 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  226 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   32 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  103 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   16 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   31 +++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 include/linux/mlx5/device.h                        |   20 ++-
 include/linux/mlx5/mlx5_ifc.h                      |    5 +-
 12 files changed, 464 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
