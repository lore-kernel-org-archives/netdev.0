From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V4 0/2] net: Affinity hint helper function
Date: Sun,  9 Mar 2014 09:39:07 +0200
Message-ID: <1394350749-30522-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:47767 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752279AbaCIHjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Mar 2014 03:39:23 -0400
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

The patch was tested and applied on top of commit 67ddc87: "Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net"

Amir

Changes from V3:
- Patch 2/2: net/mlx4_en: Use affinity hint
  - somehow patch file was corrupted

Changes from V2:
- Patch 1/2: net: Utility function to get affinity_hint by policy
  - Fixed style issues

Changes from V1:
- Patch 1/2: net: Utility function to get affinity_hint by policy
  - Fixed error flow to return -EINVAL on error (thanks govind)
- Patch 2/2: net/mlx4_en: Use affinity hint
  - Set ring->affinity_hint to NULL on error

Changes from V0:
- Fixed small style issues

Amir Vadai (1):
  net: Utility function to get affinity_hint by policy

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 30 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 14 ++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/mlx4/device.h                    |  2 +-
 include/linux/netdevice.h                      |  3 ++
 net/core/dev.c                                 | 57 ++++++++++++++++++++++++++
 8 files changed, 111 insertions(+), 4 deletions(-)

-- 
1.8.3.1
