From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/3] mlx4: CQE/EQE stride support
Date: Thu, 18 Sep 2014 11:50:58 +0300
Message-ID: <1411030261-12145-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45082 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751509AbaIRIvH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Sep 2014 04:51:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series from Ido Shamay is intended for archs having 
cache line larger then 64 bytes.

Since our CQE/EQEs are generally 64B in those systems, HW will write
twice to the same cache line consecutively, causing pipe locks due to
he hazard prevention mechanism. For elements in a cyclic buffer, writes
are consecutive, so entries smaller than a cache line should be
avoided, especially if they are written at a high rate.

Reduce consecutive writes to same cache line in CQs/EQs, by allowing the
driver to increase the distance between entries so that each will reside
in a different cache line.

Or.

Ido Shamay (3):
  net/mlx4_core: Enable CQE/EQE stride support
  net/mlx4_core: Cache line EQE size support
  net/mlx4_en: Add mlx4_en_get_cqe helper

 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |    4 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     |    4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c        |   30 +++++++----
 drivers/net/ethernet/mellanox/mlx4/fw.c        |   38 ++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h        |    2 +
 drivers/net/ethernet/mellanox/mlx4/main.c      |   61 +++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h      |    3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |    6 ++
 include/linux/mlx4/device.h                    |   11 +++-
 10 files changed, 138 insertions(+), 22 deletions(-)
