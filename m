From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 00/10] Mellanox 100G mlx5 Bulk flow statistics and SRIOV TC offloads
Date: Wed, 13 Jul 2016 00:28:56 +0300
Message-ID: <1468358946-28709-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Hen-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Amir Vadai <amir@vadai.me>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51193 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751285AbcGLVbQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jul 2016 17:31:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Amir and Or deals with two enhancements for the mlx5 TC offloads.

The 1st two patches add bulk reading of flow counters. Few bulk counter queries are
used instead of issuing thousands firmware commands per second to get statistics of all
flows set to HW.

The next patches add TC based SRIOV offloading to mlx5, as a follow up for the e-switch
offloads mode and the VF representors. When the e-switch is set to the (new) "offloads"
mode, we can now offload TC/flower drop and forward rules, the forward action we offload
is TC mirred/redirect.

The above is done by the VF representor netdevices exporting the setup_tc ndo where from
there we're re-using and enhancing the existing mlx5 TC offloads sub-module which now
works for both the NIC and the SRIOV cases.

The series is applied on top d3fc0353f7c7 ('ipv4: af_inet: make it explicitly non-modular')
and it has no merge issues with the on-going net submission ('mlx5 tx timeout watchdog fixes')

Thanks,
Saeed.

Amir Vadai (2):
  net/mlx5: Store counters in rbtree instead of list
  net/mlx5: Introduce bulk reading of flow counters

Or Gerlitz (8):
  net/mlx5e: Offload TC flow counters only when supported
  net/mlx5: E-Switch, Use two priorities for SRIOV offloads mode
  net/mlx5: E-Switch, Add API to configure rules for the offloaded mode
  net/mlx5e: Adjustments in the TC offload code towards reuse for SRIOV
  net/switchdev: Export the same parent ID service function
  net/mlx5e: Add TC drop and mirred/redirect action parsing for SRIOV
    offloads
  net/mlx5e: Add TC HW support for FDB (SRIOV e-switch) offloads
  net/mlx5e: Add TC offload support for the VF representors netdevice

 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c   |  40 +++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_tc.c    | 116 ++++++++++++++---
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.h  |   7 +
 .../ethernet/mellanox/mlx5/core/eswitch_offloads.c |  77 ++++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.c   |  67 ++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/fs_cmd.h   |  12 ++
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |  22 ++--
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.h  |   1 +
 .../net/ethernet/mellanox/mlx5/core/fs_counters.c  | 141 ++++++++++++++++-----
 include/linux/mlx5/driver.h                        |   2 +-
 include/linux/mlx5/mlx5_ifc.h                      |   8 +-
 include/net/switchdev.h                            |   8 ++
 net/switchdev/switchdev.c                          |   5 +-
 13 files changed, 436 insertions(+), 70 deletions(-)

-- 
2.8.0
