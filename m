From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 00/13] Mellanox 100G mlx5 fixes for 4.7-rc
Date: Fri, 10 Jun 2016 00:07:27 +0300
Message-ID: <1465506460-1854-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:34406 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752111AbcFIVI3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 17:08:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The following series provides some small fixes for mlx5 driver.

Two small fixes for the mlx5e netdev, the 1st is for the blue flame 
quota accounting and the 2nd is a small refactoring in shutdown flow.

Five trivial fixes for mlx5 E-Switch.
	- Allmulti mc_promisc flag was not set in a specific flow.
	- Modify VF node guid when admin mac is changed.
	- Race in vport enable flow.
	- Misc code fixes (kvfree when needed and error pointers checking).
	
Three in mlx5 steering area.  Correct capabilities checking and root flow table update.

Three misc fixes in mlx5 commands enum and layouts.

Thanks,
Saeed.

Eli Cohen (1):
  net/mlx5e: Fix blue flame quota logic

Eran Ben Elisha (1):
  net/mlx5e: Use ndo_stop explicitly at shutdown flow

Majd Dibbiny (2):
  net/mlx5: Fix the size of modify QP mailbox
  net/mlx5: Fix masking of reserved bits in XRCD number

Maor Gottlieb (3):
  net/mlx5: Fix root flow table update
  net/mlx5: Fix flow steering NIC capabilities check
  net/mlx5: Fix E-Switch flow steering capabilities check

Mohamad Haj Yahia (2):
  net/mlx5: E-Switch, Fix vport enable flow
  net/mlx5: E-Switch, always set mc_promisc for allmulti vports

Noa Osherovich (1):
  net/mlx5: E-Switch, Modify node guid on vf set MAC

Or Gerlitz (2):
  net/mlx5: E-Switch, Use the correct free() function
  net/mlx5: E-Switch, Use the correct error check on returned pointers

Shahar Klein (1):
  net/mlx5: Fix MLX5_CMD_OP_MAX to be defined correctly

 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |  5 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |  3 +-
 drivers/net/ethernet/mellanox/mlx5/core/eswitch.c | 69 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx5/core/fs_core.c | 40 ++++++++-----
 drivers/net/ethernet/mellanox/mlx5/core/qp.c      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/vport.c   | 38 +++++++++++++
 include/linux/mlx5/device.h                       |  8 ++-
 include/linux/mlx5/mlx5_ifc.h                     | 12 +++-
 include/linux/mlx5/qp.h                           |  1 +
 include/linux/mlx5/vport.h                        |  2 +
 10 files changed, 128 insertions(+), 52 deletions(-)

-- 
2.8.0
