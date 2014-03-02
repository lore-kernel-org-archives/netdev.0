From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/2] net: Affinity hint helper function
Date: Sun,  2 Mar 2014 15:52:08 +0200
Message-ID: <1393768330-13334-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, prarit@redhat.com,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:45532 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752197AbaCBNwY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Mar 2014 08:52:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset will set affinity hint to influence IRQs to be allocated on the
same NUMA node as the one where the card resides. As discussed in
http://www.spinics.net/lists/netdev/msg271497.html

If number of IRQs allocated is greater than the number of local NUMA cores, all
local cores will be used first, and the rest of the IRQs will be on a remote
NUMA node.
If no NUMA support - IRQ's and cores will be mapped 1:1

The patch was tested and applied on top of commit 750f679 "Merge branch '6lowpan'"

Amir

Amir Vadai (1):
  net: Utility function to get affinity_hint by policy

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 31 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     |  1 -
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 14 ++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/mlx4/device.h                    |  2 +-
 include/linux/netdevice.h                      |  3 ++
 net/core/dev.c                                 | 56 ++++++++++++++++++++++++++
 9 files changed, 111 insertions(+), 5 deletions(-)

-- 
1.8.3.4
