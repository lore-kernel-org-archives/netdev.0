From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V1 0/7] Mellanox 100G mlx5 driver fixes
Date: Mon, 29 Feb 2016 21:17:08 +0200
Message-ID: <1456773435-16607-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:53223 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751841AbcB2TTR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 14:19:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series has few bug fixes for the mlx5 Ethernet driver.

Eran fixed a locking issue with time-stamping that could cause a soft-lockup when time-stamping is enabled.

Gal fixed the rx/tx packets/bytes counters returned by the driver to actually went through the network stack.

Tariq removed a poll CQ optimization which could lead the driver to stop getting interrupts for some of the rings, and a did also fix to HW LRO which is currently broken.

He also provided RSS and RX hash fixes for the case of changing the number of rx rings the RX hash/RSS configuration will be out of sync.

The time stamping fix from Eran is not for -stable as the feature was only introduced in 4.5 but all of the others are.

Changes fro V0:
	- Eran addressed the irqsave/restore comments from "Dave" and fixed them.

This series is generated against net commit 4c0b6eaf373a 'net: thunderx: Fix for Qset error due to CQ full'

Saeed.

Eran Ben Elisha (1):
  net/mlx5e: Fix soft lockup when HW Timestamping is enabled

Gal Pressman (2):
  net/mlx5e: Add rx/tx bytes software counters
  net/mlx5e: Provide correct packet/bytes statistics

Tariq Toukan (4):
  net/mlx5e: Remove wrong poll CQ optimization
  net/mlx5e: Fix LRO modify
  net/mlx5e: Fix ethtool RX hash func configuration change
  net/mlx5e: Correctly handle RSS indirection table when changing
    number of channels

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   18 +++--
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   25 ++++---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   36 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   82 +++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    8 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   19 ++---
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |    1 -
 include/linux/mlx5/mlx5_ifc.h                      |    4 +-
 8 files changed, 109 insertions(+), 84 deletions(-)
