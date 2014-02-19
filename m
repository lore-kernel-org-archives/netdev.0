From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 0/3] net/mlx4: Mellanox driver update 01-01-2014
Date: Wed, 19 Feb 2014 14:58:01 +0200
Message-ID: <1392814684-2129-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:32815 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753151AbaBSM62 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Feb 2014 07:58:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

V0 of this patch was sent before previous net-next got closed, and now we would
like to resume it.

Yuval has reworked the affinity hint patch, according to Ben's comments. The
patch was actually rewritten.
After a discussion with Yuval Mintz, use of netif_get_num_default_rss_queues()
is not reverted, but done in the right place. Instead of limiting the number of
IRQ's for the driver it will limit the number of queues in RSS.

Patchset was applied and tested against commit: cb6e926 "ipv6:fix checkpatch
errors with assignment in if condition"

Thanks,
Amir

Ido Shamay (2):
  net/mlx4: Set number of RX rings in a utility function
  net/mlx4: Fix limiting number of IRQ's instead of RSS queues

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  5 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c   | 15 +----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 88 ++++++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 32 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 14 +++-
 drivers/net/ethernet/mellanox/mlx4/main.c      |  3 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  5 +-
 include/linux/mlx4/device.h                    |  2 +-
 9 files changed, 138 insertions(+), 28 deletions(-)

-- 
1.8.3.4
