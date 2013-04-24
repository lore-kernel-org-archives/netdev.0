From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/6] net/mlx4: Add support to SRIOV VF management ndo calls
Date: Wed, 24 Apr 2013 19:41:08 +0300
Message-ID: <1366821674-17902-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:54899 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755732Ab3DXQlW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 12:41:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series adds support for the SRIOV ndo_set_vf callbacks to the mlx4 driver.

Series done against the net-next tree as of commit 0c501345c "batman-adv: fix 
global protection fault during soft_iface destruction".

We have successfully tested the series on net-next, except for getting
the VF link info issue I have reported earlier today on netdev, we 
see the problem for both ixgbe and mlx4 VFs. Just to make sure get 
VF config is working OK with patch #6 - we have run it over 3.8.8 too.

Or.


Rony Efraim (6):
  net/mlx4: Add reference counting to MAC registeration
  net/mlx4: Add structures to keep VF Ethernet ports information
  net/mlx4: Add set VF mac address support
  net/mlx4: Add set VF default vlan ID and priority support
  net/mlx4: Add VF MAC spoof checking support
  net/mlx4: Add support to get VF config

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  201 ++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   68 +++++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   15 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   28 +++
 drivers/net/ethernet/mellanox/mlx4/port.c          |   19 ++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   44 +++++
 include/linux/mlx4/cmd.h                           |    6 +
 include/linux/mlx4/device.h                        |    4 +-
 8 files changed, 375 insertions(+), 10 deletions(-)
