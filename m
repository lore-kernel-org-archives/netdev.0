From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 00/10] mlx5 driver updates
Date: Sun, 28 Feb 2016 17:09:01 +0200
Message-ID: <1456672151-11749-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:59743 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757714AbcB1PJs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Feb 2016 10:09:48 -0500
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

Changes from v0:
	- "Fix global UAR mapping" commit messages updated to explain ARCH_HAS_IOREMAP_WC usage.
	- rebased to commit 8d3f2806f8fb 'Merge branch ethtool-ksettings'

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
