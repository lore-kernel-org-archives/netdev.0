From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/6] Add HA and LAG support for mlx4 SRIOV VFs
Date: Sun,  6 Dec 2015 18:07:37 +0200
Message-ID: <1449418063-8111-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Moni Shoua <monis@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:51564 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753530AbbLFQIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Dec 2015 11:08:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series is built upon the code added in commit ce388ff "Merge branch
'mlx4-next'" which added HA and LAG support to mlx4 RoCE and SRIOV services.

We add HA and Link Aggregation support to single ported mlx4 Ethernet VFs. 

In this case, the PF Ethernet interfaces are bonded, the VFs see single
port HW devices (already supported) -- however, now this port is highly
available. This means that all VF HW QPs (both VF Ethernet driver and VF
RoCE / RAW QPs) are subject to the V2P (Virtual-To-Physical) mapping which
is managed by the PF driver, and hence resilient across link failures and
such events.

When bonding operates in Dynamic link aggregation (802.3ad) mode, traffic
from each VF will go over the VF "base port" (the port this VF is assigned
to by the admin) as long as this port is up. When the port fails, traffic
from all VFs that are defined on this port will move to the other port, and
be back to their base-port when it recovers.

Moni and Or.

Moni Shoua (4):
  net/mlx4_core: Use both physical ports to dispatch link state events to VF
  net/mlx4_core: Support mirroring VF DMFS rules on both ports
  net/mlx4_core: Keep VLAN/MAC tables mirrored in multifunc HA mode
  net/mlx4_core: Support the HA mode for SRIOV VFs too

Or Gerlitz (2):
  net/mlx4_core: Use both physical ports to set the VF link state
  IB/mlx4: Use the VF base-port when demuxing mad from wire

 drivers/infiniband/hw/mlx4/mad.c                   |  17 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |  24 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  12 +-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |   1 +
 drivers/net/ethernet/mellanox/mlx4/main.c          | 107 +++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   8 +
 drivers/net/ethernet/mellanox/mlx4/port.c          | 598 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 193 ++++++-
 include/linux/mlx4/driver.h                        |   5 +
 9 files changed, 915 insertions(+), 50 deletions(-)

-- 
2.3.7
