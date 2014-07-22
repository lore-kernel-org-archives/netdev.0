From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/4] Mellanox driver update Jul-22-2014
Date: Tue, 22 Jul 2014 15:44:08 +0300
Message-ID: <1406033052-16550-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47437 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750898AbaGVMo7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Jul 2014 08:44:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset contains a fix by Eyal to fix a bug in mlx4_en with bonding
alb/tlb mode.
The second patch, by me, is an ethtool private flag that enable turning off the
BlueFlame hardware feature.
The last two patches, introduce a new low memory profile for mlx4_en and
mlx4_core. This mode is useful when running from a limited resources
environment, like kdump. This will reduce the memory consumed by both drivers
from more than 100M to ~30M.

This patchset was applied and tested on commit 575a193 ("net: mvpp2: Fix error
return code in mvpp2_probe")

Amir

Amir Vadai (3):
  net/mlx4_en: Disable blueflame using ethtool private flags
  net/mlx4_core: Use low memory profile on kdump kernel
  net/mlx4_en: Reduce memory consumption on kdump kernel

Eyal Perry (1):
  net/mlx4_en: current_mac isn't updated in port up

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 57 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |  2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  5 ++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 13 ++++--
 drivers/net/ethernet/mellanox/mlx4/main.c       | 28 ++++++++++--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  6 +++
 include/linux/mlx4/device.h                     |  7 +++
 8 files changed, 113 insertions(+), 11 deletions(-)

-- 
1.8.3.4
