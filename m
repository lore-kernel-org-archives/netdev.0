From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V2 net-next 00/10] mlx4 driver update
Date: Thu, 11 Dec 2014 10:57:50 +0200
Message-ID: <1418288280-334-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:40405 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932393AbaLKI6l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Dec 2014 03:58:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

This series from Matan, Jenny, Dotan and myself is mostly about adding
support to a new performance optimized flow steering mode (patches 4-10).

The 1st two patches are small fixes (one for VXLAN and one for SRIOV),
and the third patch is a fix to avoid hard-lockup situation when many
(hunderds) processes holding user-space QPs/CQs get events.

Matan and Or. 

changes from V1:
 - in patch #3, follow the pratice used by __do_softirq and limit 
   the tasklet running time by 2ms instread of hard coded 1000 iterations

changes from V0:
 - avoid using magic constancts in patch #2
 - open-coded trivial helpers in patch #6

Dotan Barak (1):
  net/mlx4: Add a check if there are too many reserved QPs

Eugenia Emantayev (1):
  net/mlx4: Change QP allocation scheme

Matan Barak (6):
  net/mlx4_core: Use tasklet for user-space CQ completion events
  net/mlx4: Add mlx4_bitmap zone allocator
  net/mlx4: Add A0 hybrid steering
  net/mlx4_core: Add explicit error message when rule doesn't meet configuration
  net/mlx4: Refactor QUERY_PORT
  net/mlx4: Add support for A0 steering

Or Gerlitz (2):
  net/mlx4_en: Set csum level for encapsulated packets
  net/mlx4_core: Mask out host side virtualization features for guests

 drivers/infiniband/hw/mlx4/cq.c                    |    5 +-
 drivers/infiniband/hw/mlx4/main.c                  |    2 +-
 drivers/infiniband/hw/mlx4/qp.c                    |   13 +-
 drivers/net/ethernet/mellanox/mlx4/alloc.c         |  425 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/cq.c            |   50 +++
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   13 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |    8 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c         |   14 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c            |   16 +-
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  225 ++++++++---
 drivers/net/ethernet/mellanox/mlx4/fw.h            |   42 ++-
 drivers/net/ethernet/mellanox/mlx4/main.c          |  218 +++++++++--
 drivers/net/ethernet/mellanox/mlx4/mcg.c           |   21 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   97 +++++-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    2 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |  303 +++++++++++++-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    7 +-
 include/linux/mlx4/device.h                        |   51 +++-
 18 files changed, 1342 insertions(+), 170 deletions(-)
