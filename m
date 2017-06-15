From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net-next 00/10] mlx4 XDP performance improvements
Date: Thu, 15 Jun 2017 14:35:30 +0300
Message-ID: <1497526540-30028-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>, kernel-team@fb.com,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:36013 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752064AbdFOLgT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 07:36:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains data-path improvements, mainly for XDP_DROP
and XDP_TX cases.

Main patches:
* Patch 2 by Saeed allows enabling optimized A0 RX steering (in HW) when
  setting a single RX ring.
  With this configuration, HW packet-rate dramatically improves,
  reaching 28.1 Mpps in XDP_DROP case for both IPv4 (37% gain)
  and IPv6 (53% gain).
* Patch 6 enhances the XDP xmit function. Among other changes, now we
  ring one doorbell per NAPI. Patch gives 17% gain in XDP_TX case.
* Patch 7 obsoletes the NAPI of XDP_TX completion queue and integrates its
  poll into the respective RX NAPI. Patch gives 15% gain in XDP_TX case.

Series generated against net-next commit:
f7aec129a356 rxrpc: Cache the congestion window setting

Thanks,
Tariq.


Saeed Mahameed (1):
  net/mlx4_en: Optimized single ring steering

Tariq Toukan (9):
  net/mlx4_en: Remove unused argument in TX datapath function
  net/mlx4_en: Improve receive data-path
  net/mlx4_en: Improve transmit CQ polling
  net/mlx4_en: Improve stack xmit function
  net/mlx4_en: Improve XDP xmit function
  net/mlx4_en: Poll XDP TX completion queue in RX NAPI
  net/mlx4_en: Increase default TX ring size
  net/mlx4_en: Replace TXBB_SIZE multiplications with shift operations
  net/mlx4_en: Refactor mlx4_en_free_tx_desc

 drivers/net/ethernet/mellanox/mlx4/en_cq.c     |  25 +-
 drivers/net/ethernet/mellanox/mlx4/en_main.c   |   6 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  20 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c     | 145 ++++++++----
 drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 305 ++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/main.c      |   4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  23 +-
 7 files changed, 293 insertions(+), 235 deletions(-)

-- 
1.8.3.1
