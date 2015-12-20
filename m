From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 0/4] Introduce mlx5 ethernet timestamping
Date: Sun, 20 Dec 2015 23:46:27 +0200
Message-ID: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	saeedm@dev.mellanox.co.il, Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:60475 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751046AbbLTVq6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Dec 2015 16:46:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series introduces the support for ConnectX-4 timestamping
and the PTP kernel interface.

This version addresses all the comments received on v1. The first patch
was replaced with a one that addresses the SKB data issue and fixes it
in the right way (By Achiad), Also Addressed all of Richard's comments
re timestamping patches and fixed the delayed work to work in the correct delay.

In details:

1st patch prevents the driver from modifying skb->data and SKB CB in
device xmit function.

2nd patch adds the needed low level helpers for:
	- Fetching the hardware clock (hardware internal timer)
	- Parsing CQEs timestamps
	- Device frequency capability

3rd patch adds new en_clock.c file that handles all needed timestamping
operations:
	- Internal clock structure initialization and other helper functions
	- Added the needed ioctl for setting/getting the current timestamping
	  configuration.
	- used this configuration in RX/TX data path to fill the SKB with 
	  the timestamp.

4th patch Introduces PTP (PHC) support.

Achiad Shochat (1):
  net/mlx5e: Do not modify the TX SKB

Eran Ben Elisha (3):
  net/mlx5_core: Add support for reading hardware timestamp
  net/mlx5e: Add HW timestamping (TS) support
  net/mlx5e: Add PTP Hardware Clock (PHC) support

 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |    1 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |    2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   27 ++-
 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c |  238 ++++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |   33 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   82 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c    |   10 +
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    |   90 +++++---
 drivers/net/ethernet/mellanox/mlx5/core/main.c     |   31 +++
 .../net/ethernet/mellanox/mlx5/core/mlx5_core.h    |    1 +
 include/linux/mlx5/device.h                        |   20 ++-
 include/linux/mlx5/mlx5_ifc.h                      |    5 +-
 12 files changed, 499 insertions(+), 41 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/en_clock.c
