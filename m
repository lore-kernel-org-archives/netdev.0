From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 00/10] Mellanox 100G mlx5 DCBX and ethtool updates
Date: Sun, 27 Nov 2016 17:02:02 +0200
Message-ID: <1480258932-10302-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43717 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752124AbcK0PC3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 10:02:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series provides the following mlx5 updates:

>From Huy:
DCBX CEE API and DCBX firmware/host modes support.
    - 1st patch ensures the dcbnl_rtnl_ops is published only when the qos
      capability bits is on. 
    - 2nd patch adds the support for CEE interfaces into mlx5 dcbnl_rtnl_ops
    - 3rd patch refactors ETS query to read ETS configuration directly from
      firmware rather than having a software shadow to it. The existing IEEE
      interfaces stays the same.
    - 4th patch adds the support for MLX5_REG_DCBX_PARAM and MLX5_REG_DCBX_APP
      firmware commands to manipulate mlx5 DCBX mode. 
    - 5th patch adds the driver support for the new DCBX firmware.  This ensures
      the backward compatibility versus the old and new firmware. With the new DCBX
      firmware, qos settings can be controlled by either firmware or software
      depending on the DCBX mode. 

>From Kamal and Saeed:
    - mlx5 self-test support.

>From Shaker:
    - Private flag to give the user the ability to enable/disable mlx5 CQE
      compression.

V1->V2:
    - Check ETS capability where needed in:
	("net/mlx5e: Read ETS settings directly from firmware")
    - Fix return value of mlx5e_dcbnl_switch_to_host_mode in:
	("net/mlx5e: ConnectX-4 firmware support for DCBX")
    - Update commit message of:
	("net/mlx5e: ConnectX-4 firmware support for DCBX")
    - Fix two sparse static check warnings in en_selftest.c

This series was generated against commit:
e5f12b3f5ebb ("Merge branch 'mlxsw-trap-groups-and-policers'")

Huy Nguyen (6):
  net/mlx5e: Add qos capability check
  net/mlx5e: Support DCBX CEE API
  net/mlx5e: Read ETS settings directly from firmware
  net/mlx5: Add DCBX firmware commands support
  net/mlx5e: ConnectX-4 firmware support for DCBX
  net/mlx5e: Add DCBX control interface

Kamal Heib (1):
  net/mlx5e: Add support for ethtool self diagnostics test

Saeed Mahameed (1):
  net/mlx5e: Add support for loopback selftest

Shaker Daibes (2):
  net/mlx5e: Moves pflags to priv->params
  net/mlx5e: Add CQE compression user control

 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  61 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |   3 +-
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |   7 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 457 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  53 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  46 +--
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   4 +-
 .../net/ethernet/mellanox/mlx5/core/en_selftest.c  | 344 ++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/port.c     |  63 +++
 include/linux/mlx5/driver.h                        |   7 +
 include/linux/mlx5/port.h                          |   6 +
 12 files changed, 985 insertions(+), 68 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_selftest.c

-- 
2.7.4
