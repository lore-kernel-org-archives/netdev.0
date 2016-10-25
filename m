From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/12] Mellanox 100G mlx5 fixes 2016-10-25
Date: Tue, 25 Oct 2016 18:36:23 +0300
Message-ID: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40905 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754884AbcJYPiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series contains some bug fixes for the mlx5 core and mlx5e driver.

>From Daniel:
    - Cache line size determination at runtime, instead of using 
      L1_CACHE_BYTES hard coded value, use cache_line_size()
    - Always Query HCA caps after setting them even on reset flow

>From Mohamad:
    - Reorder netdev cleanup to uregister netdev before detaching it
      for the kernel to not complain about open resources such as vlans
    - Change the acl enable prototype to return status, for better error
      resiliency
    - Clear health sick bit when starting health poll after reset flow
    - Fix race between PCI error handlers and health work
    - PCI error recovery health care simulation, in case when the kernel 
      PCI error handlers are not triggered for some internal firmware errors

>From Noa:
    - Avoid passing dma address 0 to firmware when mapping system pages
      to the firmware

>From Paul: Some straight forward flow steering fixes
    - Keep autogroups list ordered
    - Fix autogroups groups num not decreasing
    - Correctly initialize last use of flow counters

>From Saeed:
    - Choose the nearest LRO timeout to the wanted one
      instead of blindly choosing "dev_cap.lro_timeout[2]"

This series has no conflict with the for-next pull request posted
earlier today ("Mellanox mlx5 core driver updates 2016-10-25").

Thanks,
Saeed.

Daniel Jurgens (2):
  {net, ib}/mlx5: Make cache line size determination at runtime.
  net/mlx5: Always Query HCA caps after setting them

Mohamad Haj Yahia (5):
  net/mlx5e: Unregister netdev before detaching it
  net/mlx5: Change the acl enable prototype to return status
  net/mlx5: Clear health sick bit when starting health poll
  net/mlx5: Fix race between PCI error handlers and health work
  net/mlx5: PCI error recovery health care simulation

Noa Osherovich (1):
  net/mlx5: Avoid passing dma address 0 to firmware

Paul Blakey (3):
  net/mlx5: Keep autogroups list ordered
  net/mlx5: Fix autogroups groups num not decreasing
  net/mlx5: Correctly initialize last use of flow counters

Saeed Mahameed (1):
  net/mlx5e: Choose best nearest LRO timeout

 drivers/infiniband/hw/mlx5/main.c                  |  2 +-
 drivers/infiniband/hw/mlx5/qp.c                    |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    | 31 +++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  5 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 21 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c  | 50 +++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  9 ++-
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/health.c   | 76 ++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c     | 39 +++++++----
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |  1 +
 .../net/ethernet/mellanox/mlx5/core/pagealloc.c    | 26 +++++---
 include/linux/mlx5/driver.h                        | 16 ++---
 14 files changed, 210 insertions(+), 69 deletions(-)

-- 
2.7.4
