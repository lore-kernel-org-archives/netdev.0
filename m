From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 0/6] Mellanox 100G mlx5 DCBX CEE and firmware support
Date: Tue, 30 Aug 2016 14:29:49 +0300
Message-ID: <1472556595-9286-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56721 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1758292AbcH3Laf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 07:30:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This series from Huy provides mlx5 DCBX updates to support DCBX CEE
API and DCBX firmware/host modes support.

1st patch adds the support for CEE interfaces into mlx5 dcbnl_rtnl_ops.

2nd patch refactors ETS query to read ETS configuration directly from 
firmware rather than having a software shadow to it.

3rd patch adds the support for MLX5_REG_DCBX_PARAM and MLX5_REG_DCBX_APP
firmware commands to manipulate mlx5 DCBX mode.

4th patch adds driver support for moving mlx5 DCBX mode between firmware
and host.

5th patch adds a private flag for setting special hybrid DCBX firmware/host
mode "qos_with_dcbx_by_fw".

6th patch adds support for module events log.

Thanks,
Saeed.

Huy Nguyen (6):
  net/mlx5e: Support DCBX CEE API
  net/mlx5e: Read ETS settings directly from firmware
  net/mlx5: Add DCBX firmware commands support
  net/mlx5e: ConnectX-4 firmware support for DCBX
  net/mlx5e: Add DCBX control interface
  net/mlx5: Add handling for port module event

 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  38 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_dcbnl.c | 505 ++++++++++++++++++++-
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  25 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  24 +-
 drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  12 +
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |   1 +
 drivers/net/ethernet/mellanox/mlx5/core/port.c     | 150 ++++++
 include/linux/mlx5/device.h                        |  11 +
 include/linux/mlx5/driver.h                        |   7 +
 include/linux/mlx5/mlx5_ifc.h                      |   3 +-
 include/linux/mlx5/port.h                          |   6 +
 11 files changed, 747 insertions(+), 35 deletions(-)

-- 
2.7.4
