From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next V1 0/4] Mellanox driver update, Oct 14 2015
Date: Wed, 14 Oct 2015 17:43:44 +0300
Message-ID: <1444833828-8240-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37078 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754018AbbJNOoJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 10:44:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains two more patches from Eli, patch from Majd
to support PCI error handlers and a fix from Jack to mlx4 VFs
when probed without a provisioned mac address.

The patch set applied on top of net-next commit bbb300e "Merge branch 'bridge-vlan'"

changes from V0:
  - made the health flag int --> bool to address comment from Dave on patch #1
  - fixed sparse warning noted by the 0-day build tests in patch #2

Or.

Eli Cohen (2):
  net/mlx5_core: Fix internal error detection conditions
  net/mlx5_core: Wait for FW readiness on startup

Jack Morgenstein (1):
  net/mlx4_core: Replace VF zero mac with random mac in mlx4_core

Majd Dibbiny (1):
  net/mlx5_core: Add pci error handlers to mlx5_core driver

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  23 ++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  16 ++
 drivers/net/ethernet/mellanox/mlx4/main.c          |   2 +
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/cmd.c      | 170 +++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/health.c   | 123 +++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 209 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   4 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    |  13 +-
 include/linux/mlx4/device.h                        |   1 +
 include/linux/mlx5/device.h                        |   3 +-
 include/linux/mlx5/driver.h                        |  28 +++
 12 files changed, 562 insertions(+), 32 deletions(-)

-- 
2.3.7
