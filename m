From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net 0/3] Mellanox EN driver fixes 2014-06-23
Date: Mon, 23 Jun 2014 17:41:55 +0300
Message-ID: <1403534518-20898-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:59826 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754029AbaFWOmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Jun 2014 10:42:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Below are some fixes to patches submitted to 3.16.

First patch is according to discussions with Ben [1] and Thomas [2] - to do not
use affinity notifier, since it breaks RFS. Instead detect changes in IRQ
affinity map, by checking if current CPU is set in affinity map on NAPI poll.
The two other patches fix some bugs introduced by commit [3].

Patches were applied and tested on commit b58537a ('net: sctp: fix
permissions for rto_alpha and rto_beta knobs')

Thanks,
Amir

[1] - http://www.spinics.net/lists/netdev/msg283096.html
[2] - https://lkml.org/lkml/2014/5/25/31
[3] - 554e101: ('lib/cpumask: cpumask_set_cpu_local_first to use all cores when
      numa node is not defined')

Amir Vadai (3):
  net/mlx4_en: Don't use irq_affinity_notifier to track changes in IRQ
    affinity map
  lib/cpumask: cpumask_set_cpu_local_first to use all cores when numa
    node is not defined
  net/mlx4_en: IRQ affinity hint is not cleared on port down

 drivers/net/ethernet/mellanox/mlx4/cq.c      |  2 -
 drivers/net/ethernet/mellanox/mlx4/en_cq.c   |  7 ++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c   | 15 ++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c   |  6 ---
 drivers/net/ethernet/mellanox/mlx4/eq.c      | 69 ++++------------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |  1 +
 include/linux/mlx4/device.h                  |  4 +-
 lib/cpumask.c                                |  2 +-
 8 files changed, 29 insertions(+), 77 deletions(-)

-- 
1.8.3.4
