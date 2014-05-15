From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/2] mlx4: Fix VF MAC address change under RoCE usage
Date: Thu, 15 May 2014 15:29:26 +0300
Message-ID: <1400156968-29633-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, matanb@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:34977 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753836AbaEOM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 08:29:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Roland

This short series provides proper handling for the case where a 
VF netdevice change their MAC address under a RoCE use case. The code
it deals with was introduced in 3.15-rc1

Prior to this series the source MAC used for the VM RoCE CM
packets remains as before the MAC modification. Hence RoCE CM 
packets sent by the VF will not carry the same source MAC 
address as the non-CM packets.

Earlier 3.15-rc commit f24f790 "net/mlx4_core: Load the Eth driver 
first" handled just one instance of the problem, but this one 
provides a more generic and proper solution which covers all 
cases of VF mac change.

Matan and Or.

Matan Barak (2):
  net/mlx4_core: Add UPDATE_QP SRIOV wrapper support
  IB/mlx4: Invoke UPDATE_QP for proxy QP1 on MAC changes

 drivers/infiniband/hw/mlx4/main.c                  |   67 +++++++++++++++++++-
 drivers/infiniband/hw/mlx4/mlx4_ib.h               |    3 +
 drivers/infiniband/hw/mlx4/qp.c                    |    8 +++
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    4 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    6 ++
 drivers/net/ethernet/mellanox/mlx4/qp.c            |   35 ++++++++++
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   54 ++++++++++++++++
 include/linux/mlx4/qp.h                            |   11 +++
 8 files changed, 183 insertions(+), 5 deletions(-)
