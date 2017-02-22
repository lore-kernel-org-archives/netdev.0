From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/6] Mellanox mlx5e fixes for 4.11-rc1
Date: Wed, 22 Feb 2017 17:20:10 +0200
Message-ID: <20170222152016.31263-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:57750 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S933001AbdBVPVr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 10:21:47 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series includes some important bug fixes for mlx5e driver.

Three misc fixes:
>From Mohamad, compilation fix on s390 system
>From Me, A fix for driver unload when switchdev mode is on. 
>From Tariq, HW LRO frag size optimization for when build_skb is not used
(striding RQ mode).

Three CQE compression related fixes:
Two fixes from Tariq and I, to correctly setup CQE compression
parameters on driver load and on arbitrary user modifications.
Last patch, fixes a very critical issue that was originally reported
by Tom, where the driver reported csum errors or even page ref issues
for when cqe compression is enabled and rapidly active.

For your convenience this series was generated on top of net-next branch:
005c3490e9db ('Revert "ath10k: Search SMBIOS for OEM board file extension"')

for -stable:
net/mlx5e: Register/unregister vport representors on interface (for kernel >= 4.9)
net/mlx5e: Do not reduce LRO WQE size when not using build_skb (for kernel >= 4.9)
net/mlx5e: Fix broken CQE compression initialization (for kernel >= 4.9)
net/mlx5e: Update MPWQE stride size when modifying CQE compress state (for kernel >= 4.7)
net/mlx5e: Fix wrong CQE decompression (for kernel >= 4.7)

Thanks,
Saeed.

Mohamad Haj Yahia (1):
  net/mlx5e: s390 system compilation fix

Saeed Mahameed (2):
  net/mlx5e: Register/unregister vport representors on interface
    attach/detach
  net/mlx5e: Update MPWQE stride size when modifying CQE compress state

Tariq Toukan (3):
  net/mlx5e: Do not reduce LRO WQE size when not using build_skb
  net/mlx5e: Fix broken CQE compression initialization
  net/mlx5e: Fix wrong CQE decompression

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 40 +++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    | 15 ++++----
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  |  1 +
 5 files changed, 35 insertions(+), 23 deletions(-)

-- 
2.11.0
