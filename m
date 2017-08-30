From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Thu, 31 Aug 2017 02:04:06 +0300
Message-ID: <20170830230409.15176-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34542 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750995AbdH3XEV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:04:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Tthe following changes provide GRE tunnel offloads for mlx5 ethernet netdevice driver.

For more details please see tag log message below.
Please pull and let me know if there's any problem.

Note: this series doesn't conflict with the ongoing net mlx5 submission.

Thanks,
Saeed.

---

The following changes since commit 90774a93ef075b39e55d31fe56fc286d71a046ac:

  bpf: test_maps: fix typos, "conenct" and "listeen" (2017-08-30 15:32:16 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/saeed/linux.git tags/mlx5-GRE-Offload

for you to fetch changes up to 7b3722fa9ef647eb1ae6a60a5d46f7c67ab09a33:

  net/mlx5e: Support RSS for GRE tunneled packets (2017-08-31 01:54:15 +0300)

----------------------------------------------------------------
mlx5-updates-2017-08-31 (GRE Offloads support)

This series provides the support for MPLS RSS and GRE TX offloads and
RSS support.

The first patch from Gal and Ariel provides the mlx5 driver support for
ConnectX capability to perform IP version identification and matching in
order to distinguish between IPv4 and IPv6 without the need to specify the
encapsulation type, thus perform RSS in MPLS automatically without
specifying MPLS ethertyoe. This patch will also serve for inner GRE IPv4/6
classification for inner GRE RSS.

2nd patch from Gal, Adds the TX offloads support for GRE tunneled packets,
by reporting the needed netdev features.

3rd patch from Gal, Adds GRE inner RSS support by creating the needed device
resources (Steering Tables/rules and traffic classifiers) to Match GRE traffic
and perform RSS hashing on the inner headers.

Improvement:
Testing 8 TCP streams bandwidth over GRE:
    System: Intel(R) Xeon(R) CPU E5-2680 v3 @ 2.50GHz
    NIC: Mellanox Technologies MT28800 Family [ConnectX-5 Ex]
    Before: 21.3 Gbps (Single RQ)
    Now   : 90.5 Gbps (RSS spread on 8 RQs)

Thanks,
Saeed.

----------------------------------------------------------------
Gal Pressman (3):
      net/mlx5e: Use IP version matching to classify IP traffic
      net/mlx5e: Support TSO and TX checksum offloads for GRE tunnels
      net/mlx5e: Support RSS for GRE tunneled packets

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  18 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  11 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c    | 281 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 108 ++++++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   4 +-
 include/linux/mlx5/mlx5_ifc.h                      |   2 +-
 6 files changed, 384 insertions(+), 40 deletions(-)
