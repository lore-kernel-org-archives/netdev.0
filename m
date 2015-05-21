From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/6] mlx4: Enable single ported VFs over IB ports
Date: Thu, 21 May 2015 15:14:04 +0300
Message-ID: <1432210450-23408-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:56564 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753794AbbEUMOj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 May 2015 08:14:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series further enhances the support for mlx4 single ported VFs 
introduced in 3.15 to work over IB ports too. 

Just as quick reminder, the ConnectX3 device family exposes one PCI device 
which serves both ports. 

This can be non-optimal under virtualization schemes where the admin
would like the VF to expose one interface to the VM, etc.

Since all the VF interaction with the firmware passes through the PF
driver, we can emulate to the VF they have one port, and further create
a set of the VFs which act on port1 of the device and another set which
acts on port2.

Or.

Or Gerlitz (6):
  net/mlx4_core: Enhance the MAD_IFC wrapper to convert VF port to physical
  IB/mlx4: Convert slave port before building address-handle
  net/mlx4_core: Modify port values when generting EQEs for VFs
  net/mlx4_core: Adjust the schedule queue port for single ported IB VFs
  net/mlx4_core: Adjust the schedule queue port in reset-to-init too
  net/mlx4_core: Enable single ported IB VFs

 drivers/infiniband/hw/mlx4/alias_GUID.c            |    7 +++++-
 drivers/infiniband/hw/mlx4/mad.c                   |   11 +++++---
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |   21 ++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   24 ++++++++++++++++---
 drivers/net/ethernet/mellanox/mlx4/main.c          |   12 ----------
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   12 ++++++++-
 6 files changed, 60 insertions(+), 27 deletions(-)
