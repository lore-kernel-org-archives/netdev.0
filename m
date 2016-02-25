From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/10] mlx5 driver updates
Date: Thu, 25 Feb 2016 18:33:10 +0200
Message-ID: <1456418000-18898-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:57234 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1760641AbcBYQeS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Feb 2016 11:34:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series includes some bug fixes and updates for the mlx5 core
and ethernet driver.

>From Gal, two fixes that protects the update CQ moderation flows
when it is not allowed.

>From Moshe, two fixes for the core and ethernet driver in 
non-cached(NC) and write combining(WC) buffers mappings, 
which prevents the driver from double memory mappings.

>From Or, reduce the firmware command completion timeout.

>From Tariq, several small trivial fixes.

This series is generated against net-next commit 555d5b70f159 'ppp: clarify parsing of user supplied data in ppp_set_compress()'

Thanks,
Saeed

Gal Pressman (2):
  net/mlx5e: Don't try to modify CQ moderation if it is not supported
  net/mlx5e: Don't modify CQ before it was created

Moshe Lazer (2):
  net/mlx5: Fix global UAR mapping
  net/mlx5: Avoid double mapping of io mapped memory

Or Gerlitz (1):
  net/mlx5: Make command timeout way shorter

Tariq Toukan (5):
  net/mlx5e: Replace async events spinlock with synchronize_irq()
  net/mlx5e: Placement changed for carrier state updates
  net/mlx5e: Changed naming convention of tx queues in ethtool stats
  net/mlx5e: Move common case counters within sq_stats struct
  net/mlx5e: Set drop RQ's necessary parameters only

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   27 ++++-----
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   27 ++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   64 ++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |    5 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   28 +--------
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      |   31 ++++++----
 include/linux/mlx5/driver.h                        |    7 +-
 9 files changed, 97 insertions(+), 95 deletions(-)
