From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/8] net/mlx4: Add support to SRIOV VF management ndo calls
Date: Thu, 25 Apr 2013 18:22:22 +0300
Message-ID: <1366903350-9096-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:42305 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755921Ab3DYPWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 11:22:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series adds support for the SRIOV ndo_set_vf callbacks to the mlx4 driver.

Series done against the net-next tree as of commit 37fe0660981d7a "net: 
fix address check in rtnl_fdb_del"

We have successfully tested the series on net-next, except for getting
the VF link info issue I have reported earlier today on netdev, we 
see the problem for both ixgbe and mlx4 VFs. Just to make sure get 
VF config is working OK with patch #6 - we have run it over 3.8.8 too.

We added to the V1 series two patches that disable HW timestamping
when running over a VF, as this isn't supported yet.

Or.

changes from V0:
 - rebased to net-next commit 37fe0660981d7a "net: fix address check in rtnl_fdb_del"
 - fixed git am warning on empty line
 - added patches to disable HW timestamping on VFs

Amir Vadai (2):
  net/mlx4_core: Disable HW timestamping for VFs
  net/mlx4_en: Disable HW clock overflow check when no HW support

Rony Efraim (6):
  net/mlx4: Add reference counting to MAC registeration
  net/mlx4: Add structures to keep VF Ethernet ports information
  net/mlx4: Add set VF mac address support
  net/mlx4: Add set VF default vlan ID and priority support
  net/mlx4: Add VF MAC spoof checking support
  net/mlx4: Add support to get VF config

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  200 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   78 +++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   16 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   28 +++
 drivers/net/ethernet/mellanox/mlx4/port.c          |   19 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   44 +++++
 include/linux/mlx4/cmd.h                           |    6 +
 include/linux/mlx4/device.h                        |    4 +-
 8 files changed, 383 insertions(+), 12 deletions(-)
