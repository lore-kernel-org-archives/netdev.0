From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 0/4] net/mlx4_en: Hardware accelerated 802.1ad
Date: Mon, 27 Jul 2015 14:46:30 +0300
Message-ID: <1437997594-8506-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Hadar Har-Zion <hadarh@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:56749 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751601AbbG0LrJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2015 07:47:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This patchset by Hadar introduces support in Hardware accelerated 802.1ad, for
ConnectX-3pro NIC's.  In order to support existing deployment, and due to some
hardware limitations, the feature is disabled by default, and needed to be
enabled using a private flag in ethtool. Ofcourse user can enable the private
flag only if hardware has support.
After being enabled, the standard ethtool -k/-K can be used.

Patchset was applied and tested over commit 71790a2 ("hv_netvsc: Add structs
and handlers for VF messages")

Amir

Hadar Hen Zion (4):
  net/mlx4_core: Preparations for 802.1ad VLAN support
  net/mlx4_en: Prepare ethtool private flags to support more flags
  net/mlx4: Prepare VLAN macros for 802.1ad Hardware accelerated support
  net/mlx4_en: Add support for hardware accelerated 802.1ad vlan

 drivers/infiniband/hw/mlx4/cq.c                 |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 51 +++++++++------
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 46 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      | 22 +++++--
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 13 ++--
 drivers/net/ethernet/mellanox/mlx4/fw.c         | 82 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw.h         |  1 +
 drivers/net/ethernet/mellanox/mlx4/main.c       | 15 +++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h       |  3 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 +
 include/linux/mlx4/cq.h                         |  3 +-
 include/linux/mlx4/device.h                     |  5 ++
 include/linux/mlx4/qp.h                         |  3 +-
 13 files changed, 218 insertions(+), 29 deletions(-)

-- 
2.4.3.413.ga5fe668
