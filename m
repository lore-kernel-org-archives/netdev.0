From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 0/9] mlx5 driver updates and fixes
Date: Tue, 19 Apr 2016 15:33:33 +0300
Message-ID: <1461069222-27076-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:48471 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754077AbcDSMfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2016 08:35:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series has few bug fixes for mlx5 core and ethernet driver.

Eli fixed a wrong static local variable declaration in flow steering API.
Majd added the support of ConnectX-5 PF and VF and added the support
for kernel shutdown pci callback for more robust reboot procedures.
Maor fixed a soft lockup in flow steering.
Rana fixed a wrog speed define in mlx5 EN driver.
I also had the chance to introduce some bug fixes in mlx5 EN mtu 
reporting and handling, and added the ability to reset link speed 
to device's default.

For -stable:
	net/mlx5_core: Fix soft lockup in steering error flow
	net/mlx5e: Device's mtu field is u16 and not int
	net/mlx5e: Fix minimum MTU
	net/mlx5e: Use vport MTU rather than physical port MTU

Thanks,
Saeed

Eli Cohen (1):
  net/mlx5_core: Remove static from local variable

Majd Dibbiny (2):
  net/mlx5_core: Add ConnectX-5 to list of supported devices
  net/mlx5: Add pci shutdown callback

Maor Gottlieb (1):
  net/mlx5_core: Fix soft lockup in steering error flow

Rana Shahout (1):
  net/mlx5e: Fix MLX5E_100BASE_T define

Saeed Mahameed (4):
  net/mlx5e: Device's mtu field is u16 and not int
  net/mlx5e: Fix minimum MTU
  net/mlx5e: Use vport MTU rather than physical port MTU
  net/mlx5e: Reset link modes upon setting speed to zero

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |    2 +-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   26 ++++---
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   72 +++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c  |   48 +++++--------
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   25 ++++++-
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |   10 ++--
 drivers/net/ethernet/mellanox/mlx5/core/vport.c    |   40 +++++++++++
 include/linux/mlx5/driver.h                        |    7 +-
 include/linux/mlx5/port.h                          |    6 +-
 include/linux/mlx5/vport.h                         |    2 +
 10 files changed, 166 insertions(+), 72 deletions(-)
