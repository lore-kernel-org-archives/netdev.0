From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V1 0/4] Introduce mlx5 ethernet timestamping
Date: Thu, 17 Dec 2015 14:35:31 +0200
Message-ID: <1450355735-30846-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60048 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751672AbbLQMgF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Dec 2015 07:36:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces the support for ConnectX-4 timestamping
and the PTP kernel interface.

This version addresses all the comments received on v0 and breaks 
the original series to four patches.

First patch fixes a bug in SKB data pointer in device xmit function.

Second patch adds the needed low level helpers for:
	- Fetching the hardware clock (hardware internal timer)
	- Parsing CQEs timestamps
	- Device frequency capability

3rd patch adds new en_clock.c file that handles all needed timestamping
operations:
	- Internal clock structure initialization and other helper functions.
	- Added the needed ioctl for setting/getting the current timestamping
	  configuration.
	- used this configuration in RX/TX data path to fill the SKB with 
	  the timestamp.

4th patch Introduces PTP (PHC) support.

Eran Ben Elisha (4):
  net/mlx5e: Restore the skb data pointer after xmit is finished
  net/mlx5_core: Add support for reading hardware timestamp
  net/mlx5e: Add HW timestamping (TS) support
  net/mlx5e: Add PTP Hardware Clock (PHC) support

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   25 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  226 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   32 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  103 +++++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |    9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   16 ++
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   31 +++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 include/linux/mlx5/device.h                        |   20 ++-
 include/linux/mlx5/mlx5_ifc.h                      |    5 +-
 12 files changed, 464 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
