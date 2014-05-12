From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/9] Mellanox driver update 2014-05-12
Date: Mon, 12 May 2014 10:43:16 +0300
Message-ID: <1399880605-28772-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37748 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752384AbaELHnt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 May 2014 03:43:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset introduce some small bug fixes:
Eyal fixed some compilation and syntactic checkers warnings. Ido fixed a
coruption in user priority mapping when changing number of channels. Noa fixed
a bug in flow steering table when using a bond device. Shani fixed some other
problems when modifying MAC address. Yuval fixed a problem when changing IRQ
affinity during high traffic - IRQ changes got effective only after the first
pause in traffic.

This patchset was tested and applied over commit 93dccc5: "mdio_bus: fix
devm_mdiobus_alloc_size export"

Thanks,
Amir

Eyal Perry (4):
  net/mlx4_core: Fix smatch error - possible access to a null variable
  net/mlx4_core: Removed unnecessary bit operation condition
  net/mlx4_en: Using positive error value for unsigned
  net/mlx4_core: Fix inaccurate return value of mlx4_flow_attach()

Ido Shamay (1):
  net/mlx4_en: User prio mapping gets corrupted when changing number of
    channels

Noa Osherovich (1):
  net/mlx4_en: Fix mac_hash database inconsistency

Shani Michaelli (2):
  net/mlx4_en: Fix errors in MAC address changing when port is down
  net/mlx4_en: Protect MAC address modification with the state_lock
    mutex

Yuval Atias (1):
  net/mlx4_core: Enforce irq affinity changes immediatly

 drivers/net/ethernet/mellanox/mlx4/cmd.c        | 14 ++++++
 drivers/net/ethernet/mellanox/mlx4/cq.c         |  3 ++
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 29 +++++++-----
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 11 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  6 +++
 drivers/net/ethernet/mellanox/mlx4/eq.c         | 62 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c       |  9 ++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c        |  2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 include/linux/mlx4/device.h                     |  2 +
 11 files changed, 121 insertions(+), 22 deletions(-)

-- 
1.8.3.4
