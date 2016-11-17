From: Tariq Toukan <tariqt@mellanox.com>
Subject: [PATCH net 0/3] mlx4 fix for shutdown flow
Date: Thu, 17 Nov 2016 17:40:48 +0200
Message-ID: <1479397251-6932-1-git-send-email-tariqt@mellanox.com>
Cc: netdev@vger.kernel.org, Eran Ben Elisha <eranbe@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Eugenia Emantayev <eugenia@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:53546 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754263AbcKQRKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:10:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset fixes an invalid reference to mdev in mlx4 shutdown flow.

In patch 1, we make sure netif_device_detach() is called from shutdown flow only,
since we want to keep it present during a simple configuration change.

In patches 2 and 3, we add checks that were missing in:
* dev_get_phys_port_id
* dev_get_phys_port_name
We check the presence of the network device before calling the driver's
callbacks. This already exists for all other ndo's.

Series generated against net commit:
e5f6f564fd19 bnxt: add a missing rcu synchronization

Thanks,
Tariq.

Eugenia Emantayev (3):
  net/mlx4_en: Remove netif_device_detach from stop port flow
  net: Check netdevice presence on dev_get_phys_port_id
  net: Check netdevice presence on dev_get_phys_port_name

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |  8 ++++----
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 22 ++++++++--------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  2 +-
 net/core/dev.c                                  |  4 ++++
 net/core/rtnetlink.c                            |  4 ++--
 5 files changed, 19 insertions(+), 21 deletions(-)

-- 
1.8.3.1
