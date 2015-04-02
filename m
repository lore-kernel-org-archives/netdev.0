From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 00/18] Mellanox mlx4 driver updates
Date: Thu,  2 Apr 2015 16:31:05 +0300
Message-ID: <1427981483-19317-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Ido Shamay <idos@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:45636 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752057AbbDBNbt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2015 09:31:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The main feature added by this series are Ido's changes to support 
Granular QoS for VFs, where for the time being only max rate is supported.

Muhammad added support for setting rx-fcs and rx-all through ethtool, 
and Ido did the interface identify work.

Last, add Ido as a maintainer for the mlx4 Ethernet driver!

Some of next week is the Passover holiday here and I will be 
mostly OOO. If needed (...) Ido or Amir will send V1 and such.

Rebased against net-next commit 033f46b "crypto: algif - 
explicitly mark end of data".

Or.

Ido Shamay (15):
  net/mlx4: Add RSS support for fragmented IP datagrams
  net/mlx4_en: Change loopback only upon feature change
  net/mlx4: Make mlx4_is_eth visible inline funcion
  net/mlx4: Aesthetic code changes in multi_func_init
  net/mlx4: New file for QoS related firmware commands
  net/mlx4: Add mlx4_ALLOCATE_VPP implementation
  net/mlx4: Add mlx4_SET_VPORT_QOS implementation
  net/mlx4: Query device for QoS per VF support
  net/mlx4: Allocate VPPs for each port on PF init
  net/mlx4: Added qos_vport QP configuration in VST mode
  net/mlx4_en: Enable TX rate limit per VF
  net/mlx4: Warn users of depracated QoS Firmware
  net/mlx4: Set enhanced QoS support by default when ETS supported
  net/mlx4: Add SET_PORT opcode modifiers enumeration
  net/mlx4_en: Add interface identify support

Muhammad Mahajna (2):
  net/mlx4_en: Add RX-FCS support
  net/mlx4_en: Add RX-ALL support

Or Gerlitz (1):
  MAINTAINERS: Update mlx4_en entry

 MAINTAINERS                                        |    1 +
 drivers/infiniband/hw/mlx4/main.c                  |   11 +-
 drivers/net/ethernet/mellanox/mlx4/Makefile        |    5 +-
 drivers/net/ethernet/mellanox/mlx4/cmd.c           |  292 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/en_dcb_nl.c     |    1 +
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |   27 ++
 drivers/net/ethernet/mellanox/mlx4/en_main.c       |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   70 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    5 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |   53 ++++-
 drivers/net/ethernet/mellanox/mlx4/fw.h            |    1 +
 drivers/net/ethernet/mellanox/mlx4/fw_qos.c        |  289 +++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/fw_qos.h        |  145 ++++++++++
 drivers/net/ethernet/mellanox/mlx4/main.c          |   31 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   30 +--
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    1 +
 drivers/net/ethernet/mellanox/mlx4/port.c          |  133 +++++-----
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    5 +
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   11 +-
 include/linux/mlx4/cmd.h                           |   13 +-
 include/linux/mlx4/device.h                        |   20 +-
 include/linux/mlx4/qp.h                            |    8 +-
 22 files changed, 1023 insertions(+), 134 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/fw_qos.c
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/fw_qos.h
