From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net V1 0/3] Mellanox EN driver fixes 2014-06-23
Date: Sun, 29 Jun 2014 11:54:54 +0300
Message-ID: <1404032097-5132-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:43605 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751385AbaF2IzN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 29 Jun 2014 04:55:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Below are some fixes to patches submitted to 3.16.

First patch is according to discussions with Ben [1] and Thomas [2] - to do not
use affinity notifier, since it breaks RFS. Instead detect changes in IRQ
affinity map, by checking if current CPU is set in affinity map on NAPI poll.
The two other patches fix some bugs introduced in commit [3].

Patches were applied and tested over commit dba6311: ('powerpc: bpf: Fix the
broken LD_VLAN_TAG_PRESENT test')

Thanks,
Amir

[1] - http://www.spinics.net/lists/netdev/msg283096.html
[2] - https://lkml.org/lkml/2014/5/25/31
[3] - 554e101: ('lib/cpumask: cpumask_set_cpu_local_first to use all cores when
      numa node is not defined')

Changes from V0:
- Patch 1/3: net/mlx4_en: Don't use irq_affinity_notifier to track changes...
  - Added missing include to fix build issue on s390x arch

Amir Vadai (3):
  net/mlx4_en: Don't use irq_affinity_notifier to track changes in IRQ
    affinity map
  lib/cpumask: cpumask_set_cpu_local_first to use all cores when numa
    node is not defined
  net/mlx4_en: IRQ affinity hint is not cleared on port down

 drivers/net/ethernet/mellanox/mlx4/cq.c      |  2 -
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   |  7 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 16 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  6 ---
 drivers/net/ethernet/mellanox/mlx4/eq.c      | 69 ++++------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 +
 include/linux/mlx4/device.h                  |  4 +-
 lib/cpumask.c                                |  2 +-
 8 files changed, 30 insertions(+), 77 deletions(-)

-- 
1.8.3.4
