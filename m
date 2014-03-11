From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V5 0/2] irq,net: Affinity hint helper function
Date: Tue, 11 Mar 2014 09:33:25 +0200
Message-ID: <1394523207-7338-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

This patchset will set affinity hint to influence IRQs to be allocated on the
same NUMA node as the one where the card resides. As discussed in
http://www.spinics.net/lists/netdev/msg271497.html

If number of IRQs allocated is greater than the number of local NUMA cores, all
local cores will be used first, and the rest of the IRQs will be on a remote
NUMA node.
If no NUMA support - IRQ's and cores will be mapped 1:1

This patchset was tested and applied on top of net-next since the first
consumer is a network device (mlx4_en) - commit be14cc9: "vlan: use use
ether_addr_equal_64bits to instead of ether_addr_equal"

Amir

Changes from V4:
- Patch 1/2: irq: Utility function to get affinity_hint by policy
  Thank you Ben for the great review:
  - Moved the function it kernel/irq/manage.c since it could be useful for
    block mq devices
  - Fixed Typo's
  - Use cpumask_t * instead of cpumask_var_t in function header  
  - Restructured the function to remove NULL assignment in a cpumask_var_t
  - Fix for offline local CPU's

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
  irq: Utility function to get affinity_hint by policy

Yuval Atias (1):
  net/mlx4_en: Use affinity hint

 drivers/infiniband/hw/mlx4/main.c              |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  6 ++-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 30 +++++++++++++
 drivers/net/ethernet/mellanox/mlx4/eq.c        | 14 ++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 +
 include/linux/interrupt.h                      |  9 ++++
 include/linux/mlx4/device.h                    |  2 +-
 kernel/irq/manage.c                            | 58 ++++++++++++++++++++++++++
 8 files changed, 118 insertions(+), 4 deletions(-)

-- 
1.8.3.4
