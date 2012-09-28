From: Yevgeny Petrilin <yevgenyp@mellanox.com>
Subject: [PATCH 0/3] net/mlx4: HW Timestamp support
Date: Fri, 28 Sep 2012 12:03:20 +0200
Message-ID: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
Cc: netdev@vger.kernel.org, eugenia@mellanox.co.il
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:34483 "HELO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756866Ab2I1KD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2012 06:03:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches comes to introduce Ethernet HW timestamping support
for ConnectX3 devices.
When RX/TX timestamping is enabled every incoming/outgoing packet
will be timestamped.
Current limitation: for now HWTSTAMP_FILTER_ALL/NONE and HWTSAMP_TX_ON/OFF
are the only supported options.

The series consists of three logical sections:
1. Add timestamping device capability
   Add new device capability for timestamping support and query FW to retrieve it.
2. Read HCA frequency and map internal clock
   Read HCA frequency, read PCI clock bar and offset, map internal clock to PCI bar.
3. Add HW timestamping (TS) support
   The patch allows to enable/disable HW timestamping for incoming and/or
   outgoing packets. It adds and initializes all structs and callbacks
   needed by kernel TS API.
   To enable/disable HW timestamping appropriate ioctl should be used.
   Currently HWTSTAMP_FILTER_ALL/NONE and HWTSAMP_TX_ON/OFF flags only are
   supported.
   When enabling TS on receive flow - VLAN stripping will be disabled.
   Also were made all relevant changes in RX/TX flows to consider TS request
   and plant HW timestamps into relevant structures.
   mlx4_ib was fixed to compile with new mlx4_cq_alloc() signature.

Eugenia Emantayev (3):
   net/mlx4_core: Add timestamping device capability
   net/mlx4_core: Read HCA frequency and map internal clock
   net/mlx4_en: Add HW timestamping (TS) support

  drivers/infiniband/hw/mlx4/cq.c                   |    2
  drivers/net/ethernet/mellanox/mlx4/Makefile       |    2
  drivers/net/ethernet/mellanox/mlx4/cq.c           |   10 -
  drivers/net/ethernet/mellanox/mlx4/en_cq.c        |   10 +
  drivers/net/ethernet/mellanox/mlx4/en_main.c      |    5
  drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   60 +++++++
  drivers/net/ethernet/mellanox/mlx4/en_resources.c |    3
  drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   28 +++
  drivers/net/ethernet/mellanox/mlx4/en_timestamp.c |  153 ++++++++++++++++++++
  drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   33 +++-
  drivers/net/ethernet/mellanox/mlx4/fw.c           |   11 +
  drivers/net/ethernet/mellanox/mlx4/fw.h           |    1
  drivers/net/ethernet/mellanox/mlx4/main.c         |   22 ++
  drivers/net/ethernet/mellanox/mlx4/mlx4.h         |    6
  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   21 ++
  include/linux/mlx4/cq.h                           |   16 ++
  include/linux/mlx4/device.h                       |    6
  drivers/net/ethernet/mellanox/mlx4/fw.c             |    7
  drivers/net/ethernet/mellanox/mlx4/main.c           |   59 +++++++
  include/linux/mlx4/device.h                         |    4
  20 files changed, 439 insertions(+), 20 deletions(-)
