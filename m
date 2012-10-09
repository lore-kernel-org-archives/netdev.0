From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 0/3] net/mlx4: HW timestamping support
Date: Tue,  9 Oct 2012 17:20:10 +0200
Message-ID: <1349796013-31106-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog108.obsmtp.com ([207.126.144.125]:57999 "HELO
	eu1sys200aog108.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752918Ab2JIPUn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 11:20:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches introduces Ethernet HW timestamping support in the mlx4 driver.

changes from v0:

- accept HWTSTAMP_FILTER_PTP_ and HWTSTAMP_FILTER_SOME flags but 
  reply with HWTSTAMP_FILTER_ALL
- remove usage of the timecompare API
- call netdev_features_change() after changing dev->features

Dave, the submission/review of this series begun before net-next
got closed, so we continue now that for the sake of getting feedback 
of the comments that were addressed and hopefully acceptance...

When RX/TX is enabled every incoming/outgoing packet will be timestamped.

The series is made of of three patches

1. Add timestamping device capability

2. Read HCA frequency and map internal clock

3. Add HW timestamping (TS) support --  Enable/disable HW timestamping 
for incoming and/or outgoing packets. Add and initialize all structs and 
callbacks needed by the kernel timestamping API.

The patches provide raw HW timestamps, where registeration in the 
driver as PHC class device will be done in a 2nd step, once the basic 
code is merged.

Or.


Eugenia Emantayev (3):
  net/mlx4_core: Add timestamping device capability
  net/mlx4_core: Read HCA frequency and map internal clock
  net/mlx4_en: Add HW timestamping (TS) support

 drivers/infiniband/hw/mlx4/cq.c                   |    2 +-
 drivers/net/ethernet/mellanox/mlx4/Makefile       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/cq.c           |   10 +-
 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |   10 ++-
 drivers/net/ethernet/mellanox/mlx4/en_main.c      |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |   75 +++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |    3 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |   28 ++++-
 drivers/net/ethernet/mellanox/mlx4/en_timestamp.c |  136 +++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |   31 +++++-
 drivers/net/ethernet/mellanox/mlx4/fw.c           |   18 +++-
 drivers/net/ethernet/mellanox/mlx4/fw.h           |    1 +
 drivers/net/ethernet/mellanox/mlx4/main.c         |   80 ++++++++++++
 drivers/net/ethernet/mellanox/mlx4/mlx4.h         |    6 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |   17 +++
 include/linux/mlx4/cq.h                           |   16 +++
 include/linux/mlx4/device.h                       |   10 ++-
 17 files changed, 431 insertions(+), 19 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx4/en_timestamp.c

Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Eugenia Emantayev <eugenia@mellanox.com>
