From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 00/11] net/mlx4: Mellanox driver update 08-12-2013
Date: Tue, 17 Dec 2013 09:01:49 +0200
Message-ID: <1387263720-31222-1-git-send-email-amirv@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40383 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752609Ab3LQHCM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Dec 2013 02:02:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patchset contains:
1. Support in ndo_get_phys_port_id added by Hadar.
2. Change the driver to use by default CQE/EQE size of 64 bytes done by Eyal.
   This doubles the packet-rate  of the NIC.
3. Configure the XPS queue mapping on driver load - added by Ido.
4. Fixes for some small bugs done by Jenny, Matan and Rana

Patchset was applied and tested against commit: "89e47d3 fddi: cleanup unsigned
to unsigned int/short"

Changes from V0:
- Found some issues in "Reuse memory in RX flow" patch from V0.
  Removing this patch from the patchset till analyzed and fixed.
- Fix some coding style issues in patch 6 "Configure the XPS queue mapping on
  driver load"
- Changed patch 9 "Add NAPI support for transmit side" to use NAPI_POLL_WEIGHT
  instead of MLX4_EN_TX_BUDGET   

Thanks,
Amir

Eugenia Emantayev (2):
  net/mlx4_en: Ignore irrelevant hypervisor events
  net/mlx4_en: Add NAPI support for transmit side

Eyal Perry (1):
  net/mlx4_core: Set CQE/EQE size to 64B by default

Hadar Hen Zion (5):
  net/mlx4_core: Remove zeroed out of explicit QUERY_FUNC_CAP fields
  net/mlx4_core: Rename QUERY_FUNC_CAP fields
  net/mlx4_core: Introduce nic_info new flag in QUERY_FUNC_CAP
  net/mlx4_core: Expose physical port id as PF/VF capability
  net/mlx4_en: Implement ndo_get_phys_port_id

Ido Shamay (1):
  net/mlx4_en: Configure the XPS queue mapping on driver load

Matan Barak (1):
  net/mlx4_core: Check port number for validity before accessing data

Rana Shahout (1):
  net/mlx4_en: Fix Supported/Advertised link mode reported by ethtool

 drivers/net/ethernet/mellanox/mlx4/en_cq.c      | 12 ++--
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 24 +++++++-
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |  3 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  | 29 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      | 48 +++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/fw.c         | 74 ++++++++++++++++++++-----
 drivers/net/ethernet/mellanox/mlx4/fw.h         |  2 +
 drivers/net/ethernet/mellanox/mlx4/main.c       |  9 ++-
 drivers/net/ethernet/mellanox/mlx4/mcg.c        | 28 +++++++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  6 +-
 include/linux/mlx4/device.h                     |  2 +
 11 files changed, 202 insertions(+), 35 deletions(-)

-- 
1.8.3.4
