From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/5] mlx4: Add support for single port VFs
Date: Wed, 19 Mar 2014 18:11:48 +0200
Message-ID: <1395245513-8139-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, roland@kernel.org,
	jackm@dev.mellanox.co.il, amirv@mellanox.com, matanb@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40582 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932602AbaCSQMS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Mar 2014 12:12:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, Roland

The mlx4 Firmware && driver expose both ports of the device through one PCI function.

This can be non-optimal under virtualization schemes where the admin 
would like the VF to expose one interface to the VM, etc.

This series from Matan Barak adds support for single ported VFs. 

Since all the VF interaction with the firmware passes through the PF
 driver, we can emulate to the VF they have one port, and further create 
a set of the VFs which act on port1 of the device and another set which 
acts on port2.

Series done against net-next commit 3ab428a "netfilter: Add missing 
vmalloc.h include to nft_hash.c"

Roland, we send this through netdev, but if you have comments, will love
to hear them.

Or.

Matan Barak (5):
  IB/mlx4_ib: Adapt code to use caps.num_ports instead of a constant
  net/mlx4: Add data structures to support N-Ports per VF
  net/mlx4: Add utils for N-Port VFs
  net/mlx4: Adapt code for N-Port VF
  net/mlx4: Adapt num_vfs/probed_vf params for single port VF

 drivers/infiniband/hw/mlx4/mad.c                   |   29 ++--
 drivers/infiniband/hw/mlx4/main.c                  |   23 ++-
 drivers/infiniband/hw/mlx4/sysfs.c                 |    5 +
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  129 ++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   48 +++++--
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   62 +++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  148 ++++++++++++++----
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |    5 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    5 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |  158 +++++++++++++++++---
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |  143 ++++++++++++++++---
 include/linux/mlx4/device.h                        |   35 +++++
 12 files changed, 676 insertions(+), 114 deletions(-)
