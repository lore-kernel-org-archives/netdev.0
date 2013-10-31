From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/10] Mellanox driver updates Oct 31 2013
Date: Thu, 31 Oct 2013 14:29:19 +0200
Message-ID: <1383222569-10930-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com, roland@kernel.org,
	jackm@dev.mellanox.co.il, Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:41729 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753875Ab3JaM3v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 08:29:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This patch set from Jack Morgenstein does the following:

1. Fix MAC/VLAN SRIOV implementation, and add wrapper functions for VLAN allocation
   and de-allocation (patches 1-6).

2. Implements resource quotas when running under SRIOV (patches 7-10).
   Patch 7 is a small bug fix, and patches 8-10 implement the quotas.

Quotas are implemented per resource type for VFs and the PF, to prevent
any entity from simply grabbing all the resources for itself and leaving
the other entities unable to obtain such resources.

The series is against net-next commit ba48650 "ipv6: remove the unnecessary statement in find_match()"

Patch #1 is bug fix which needs to go into -stable of kernels >= 3.10 

Or.

Jack Morgenstein (10):
  net/mlx4_core: Fix call to __mlx4_unregister_mac
  net/mlx4_core: Fix register/unreg vlan flow
  net/mlx4_core: Fix reg/unreg vlan/mac to conform to the firmware spec
  net/mlx4_en: Use vlan id instead of vlan index for unregistration
  net/mlx4_core: Resource tracker for reg/unreg vlans
  net/mlx4_core: Don't fail reg/unreg vlan for older guests
  net/mlx4_core: Fix checking order in MR table init
  mlx4: Structures and init/teardown for VF resource quotas
  net/mlx4_core: Fix quota handling in the QUERY_FUNC_CAP wrapper
  net/mlx4_core: Implement resource quota enforcement

 drivers/infiniband/hw/mlx4/main.c                  |    8 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    5 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    6 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   99 +++--
 drivers/net/ethernet/mellanox/mlx4/main.c          |   32 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   21 +-
 drivers/net/ethernet/mellanox/mlx4/mr.c            |    6 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |   87 ++--
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    3 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  510 ++++++++++++++++++--
 include/linux/mlx4/device.h                        |   20 +-
 11 files changed, 676 insertions(+), 121 deletions(-)
