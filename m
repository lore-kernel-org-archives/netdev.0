From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/9] Mellanox 100G mlx5 fixes 2016-08-29
Date: Mon, 29 Aug 2016 01:13:41 +0300
Message-ID: <1472422430-21583-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53025 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756028AbcH1WOa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 18:14:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some bug fixes for the mlx5 core and mlx5
ethernet driver.

>From Saeed, Fix UMR to consider hardware translation table field
size limitation when calculating the maximum number of MTTs required
by the driver.  Three patches to speed-up netdevice close time by
serializing channel (SQs & RQs) destruction rather than issuing and
waiting for hardware interrupts to free them.

>From Eran, Fix ethtool ring parameter reporting for striding RQ layout.
Add error prints on ETS validation failure.

>From Kamal, Fix memory leak on error flow.

>From Maor, Fix ethtool steering priorities number.

For -stable of 4.7.y:
  net/mlx5e: Limit UMR length to the device's limitation
  net/mlx5e: Don't wait for RQ completions on close 
  net/mlx5e: Don't post fragmented MPWQE when RQ is disabled
  net/mlx5e: Don't wait for SQ completions on close
  net/mlx5e: Add ethtool counter for TX xmit_more

Thanks,
Saeed.

Eran Ben Elisha (2):
  net/mlx5e: Fix ethtool -g/G rx ring parameter report with striding RQ
  net/mlx5: Add error prints when validate ETS failed

Kamal Heib (1):
  net/mlx5e: Fix memory leak if refreshing TIRs fails

Maor Gottlieb (1):
  net/mlx5: Increase number of ethtool steering priorities

Saeed Mahameed (4):
  net/mlx5e: Limit UMR length to the device's limitation
  net/mlx5e: Don't wait for RQ completions on close
  net/mlx5e: Don't post fragmented MPWQE when RQ is disabled
  net/mlx5e: Don't wait for SQ completions on close

Tariq Toukan (1):
  net/mlx5e: Add ethtool counter for TX xmit_more

 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 21 +++--
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 21 +++--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 93 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 91 +++++++++------------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 41 ++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  4 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 68 ++++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  6 +-
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  2 +-
 10 files changed, 209 insertions(+), 145 deletions(-)

-- 
2.7.4
