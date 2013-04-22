From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 0/5] net/mlx4: HW timestamping support
Date: Mon, 22 Apr 2013 14:56:02 +0300
Message-ID: <1366631767-16493-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:59815 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752069Ab3DVMCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 08:02:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This V2 series of patches introduces Ethernet HW timestamping support in the
mlx4 driver.

Also apologizing for the long pauses in submitting V2 for review, and the
changing hands of the main internal reviewer. I will be responsible to finish
this submission process from now on.

The series is made of of five patches
1. Add timestamping device capability
2. Read HCA frequency and map internal clock
3. Add HW timestamping (TS) support --  Enable/disable HW timestamping 
   for incoming and/or outgoing packets. Add and initialize all structs and 
   callbacks needed by the kernel timestamping API.
4. Add needed call to enable software timestamping
5. Add a service task to mlx4_en to run periodic tasks. Currently only running
   a watchdog to prevent clock overflow  

The patches provide raw HW timestamps, where registeration in the 
driver as PHC class device will be done in a 2nd step, once the basic 
code is merged.

Changes from V0:
- accept HWTSTAMP_FILTER_PTP_ and HWTSTAMP_FILTER_SOME flags but 
  reply with HWTSTAMP_FILTER_ALL
- remove usage of the timecompare API
- call netdev_features_change() after changing dev->features

Changes from V1:
- get_ts_info function provided.
- watchdog function was added to catch overflows
- indentation and style fixes
- en_timestamp.c => en_clock.c
- use utility clockcounter utility functions


Amir Vadai (3):
  net/mlx4_en: Add HW timestamping (TS) support
  net/mlx4_en: Support software timestamping
  net/mlx4_en: Add a service task

Eugenia Emantayev (2):
  net/mlx4_core: Add timestamping device capability
  net/mlx4_core: Read HCA frequency and map internal clock

 drivers/infiniband/hw/mlx4/cq.c                   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/Makefile       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c           |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_clock.c     |  149 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c   |   30 ++++
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   99 ++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   29 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   31 ++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c           |   18 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.h           |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c         |   79 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |    6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   25 ++++-
 include/linux/mlx4/cq.h                           |   16 +++
 include/linux/mlx4/device.h                       |   10 +-
 18 files changed, 505 insertions(+), 20 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_clock.c

-- 
1.7.8.2
