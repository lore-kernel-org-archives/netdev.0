From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/7] Mellanox 100G mlx5 updates 2016-11-29
Date: Wed, 30 Nov 2016 00:19:25 +0200
Message-ID: <1480457972-31286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:45845 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752677AbcK2WT4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 17:19:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following series from Tariq and Roi, provides some critical fixes
and updates for the mlx5e driver.

>From Tariq: 
 - Fix driver coherent memory huge allocation issues by fragmenting
   completion queues, in a way that is transparent to the netdev driver by
   providing a new buffer type "mlx5_frag_buf" with the same access API.
 - Create UMR MKey per RQ to have better scalability.

>From Roi:
 - Some fixes for the encap-decap support and tc flower added lately to the
   mlx5e driver.

This series was generated against commit:
31ac1c19455f ("geneve: fix ip_hdr_len reserved for geneve6 tunnel.")

Thanks,
Saeed.

Roi Dayan (4):
  net/mlx5e: Remove redundant hashtable lookup in configure flower
  net/mlx5e: Correct cleanup order when deleting offloaded TC rules
  net/mlx5e: Refactor tc del flow to accept mlx5e_tc_flow instance
  net/mlx5e: Remove flow encap entry in the correct place

Tariq Toukan (3):
  net/mlx5e: Implement Fragmented Work Queue (WQ)
  net/mlx5e: Move function mlx5e_create_umr_mkey
  net/mlx5e: Create UMR MKey per RQ

 drivers/net/ethernet/mellanox/mlx5/core/alloc.c    |  66 +++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  14 +--
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  12 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 121 +++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    |  82 ++++++--------
 drivers/net/ethernet/mellanox/mlx5/core/wq.c       |  26 +++--
 drivers/net/ethernet/mellanox/mlx5/core/wq.h       |  18 ++-
 include/linux/mlx5/driver.h                        |  11 ++
 8 files changed, 215 insertions(+), 135 deletions(-)

-- 
2.7.4
