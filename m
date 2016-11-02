From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next V3 0/3] mlx4 XDP TX refactor
Date: Wed,  2 Nov 2016 17:12:22 +0200
Message-ID: <1478099545-24181-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:44274 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754743AbcKBPMk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:12:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset refactors the XDP forwarding case, so that
its dedicated transmit queues are managed in a complete
separation from the other regular ones.

It also adds ethtool counters for XDP cases.

Series generated against net-next commit:
22ca904ad70a genetlink: fix error return code in genl_register_family()

Thanks,
Tariq.

v3:
* Exposed per ring counters.

v2:
* Added ethtool counters.
* Rebased, now patch 2 reverts Brenden's fix, as the bug no longer exists:
  958b3d396d7f ("net/mlx4_en: fixup xdp tx irq to match rx")
* Updated commit message of patch 2.

Tariq Toukan (3):
  net/mlx4_en: Add TX_XDP for CQ types
  net/mlx4_en: Refactor the XDP forwarding rings scheme
  net/mlx4_en: Add ethtool statistics for XDP cases

 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |  28 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 101 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 382 +++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |  10 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  20 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  17 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  25 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_stats.h |  10 +-
 9 files changed, 366 insertions(+), 229 deletions(-)

-- 
1.8.3.1
