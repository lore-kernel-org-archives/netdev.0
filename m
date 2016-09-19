From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 0/8] mlx5e XDP support
Date: Mon, 19 Sep 2016 16:58:51 +0300
Message-ID: <1474293539-2595-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Rana Shahout <ranas@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:47351 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S938751AbcISN7b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 09:59:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds XDP support in mlx5e driver.
This includes the use cases: XDP_DROP, XDP_PASS, and XDP_TX.

Single stream performance tests show 16.5 Mpps for XDP_DROP,
and 12.4 Mpps for XDP_TX, with nice scalability for multiple streams/rings.

This rate of XDP_DROP is lower than the 32 Mpps we got in previous
implementation, when Striding RQ was used.

We moved to non-Striding RQ, as some XDP_TX requirements (like headroom,
packet-per-page) cannot be satisfied with the current Striding RQ HW,
and we decided to fully support both DROP/TX.

Few directions are considered in order to enable the faster rate for XDP_DROP,
e.g a possibility for users to enable Striding RQ so they choose optimized
XDP_DROP on the price of partial XDP_TX functionality, or some HW changes.

Series generated against net-next commit:
22da73492541 'net: r6040: add in missing white space in error message text'

Thanks,
Tariq

Rana Shahout (1):
  net/mlx5e: XDP fast RX drop bpf programs support

Saeed Mahameed (7):
  net/mlx5e: Build RX SKB on demand
  net/mlx5e: Union RQ RX info per RQ type
  net/mlx5e: Slightly reduce hardware LRO size
  net/mlx5e: Dynamic RQ type infrastructure
  net/mlx5e: Have a clear separation between different SQ types
  net/mlx5e: XDP TX forwarding support
  net/mlx5e: XDP TX xmit more

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  77 +++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 462 ++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 381 +++++++++++------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.h |  12 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |  63 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_txrx.c  |  65 ++-
 6 files changed, 784 insertions(+), 276 deletions(-)

-- 
1.8.3.1
