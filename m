From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/2] mlx4 XDP TX refactor
Date: Thu, 27 Oct 2016 17:52:02 +0300
Message-ID: <1477579924-32737-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38543 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S935220AbcJ0OwP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2016 10:52:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset refactors the XDP forwarding case, so that
its dedicated transmit queues are managed in a complete
separation from the other regular ones.

Series generated against net-next commit:
6edf10173a1f "devlink: Prevent port_type_set() callback when it's not needed"

Thanks,
Tariq.

Tariq Toukan (2):
  net/mlx4_en: Add TX_XDP for CQ types
  net/mlx4_en: Refactor the XDP forwarding rings scheme

 drivers/net/ethernet/mellanox/mlx4/en_cq.c      |  18 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  76 +++--
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |   2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 378 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |   4 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |   8 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |   9 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  18 +-
 8 files changed, 305 insertions(+), 208 deletions(-)

-- 
1.8.3.1
