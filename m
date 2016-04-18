From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 0/7] net: network drivers should not depend on geneve/vxlan
Date: Mon, 18 Apr 2016 21:19:41 +0200
Message-ID: <1461007188-1603-1-git-send-email-hannes@stressinduktion.org>
Cc: jesse@kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:42279 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751525AbcDRTT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 15:19:57 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 30C5C20C5C
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 15:19:56 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset removes the dependency of network drivers on vxlan or
geneve, so those don't get autoloaded when the nic driver is loaded.

Also audited the code such that vxlan_get_rx_port and geneve_get_rx_port
are not called without rtnl lock.

Hannes Frederic Sowa (7):
  benet: be_resume needs to protect be_open with rtnl_lock
  fm10k: protect fm10k_open in fm10k_io_resume with rtnl_lock
  mlx4: protect mlx4_en_start_port in mlx4_en_restart with rtnl_lock
  ixgbe: protect vxlan_get_rx_port in ixgbe_service_task with rtnl_lock
  qlcnic: protect qlicnic_attach_func with rtnl_lock
  vxlan: break dependency with netdev drivers
  geneve: break dependency with netdev drivers

 drivers/net/ethernet/emulex/benet/be_main.c      | 10 +++++---
 drivers/net/ethernet/intel/fm10k/fm10k_pci.c     |  2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |  2 ++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c   |  2 ++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 10 ++++++--
 drivers/net/geneve.c                             | 31 +++++++++++++++++++++---
 drivers/net/vxlan.c                              | 14 +++++++----
 include/linux/netdevice.h                        |  2 ++
 include/net/geneve.h                             |  6 ++---
 include/net/vxlan.h                              |  6 ++---
 10 files changed, 63 insertions(+), 22 deletions(-)

-- 
2.5.5
