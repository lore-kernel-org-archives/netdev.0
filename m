From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 0/6] Mellanox Core and Ethernet driver fixes 2013-03-07
Date: Thu,  7 Mar 2013 15:46:51 +0200
Message-ID: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:47399 "EHLO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752741Ab3CGNrR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 08:47:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

Here's a batch of fixes to the mlx4 core and ethernet drivers for 3.9

The commit that disabled RFS when running in SRIOV mode fixes a regression which was 
introduced in 3.9-rc1 but actually present also in the 3.8 -stable series. It turns out 
that a slightly different fix is needed there and we will generate and submit it there.

Patches done against net commit 66d29cbc59433 "benet: Wait f/w POST until timeout"

Or.

Amir Vadai (1):
  net/mlx4_en: Disable RFS when running in SRIOV mode

Jack Morgenstein (3):
  net/mlx4_core: Disable mlx4_QP_ATTACH calls from guests if the host uses flow steering
  net/mlx4_core: Turn off device-managed FS bit in dev-cap wrapper if DMFS is not enabled
  net/mlx4_core: Fix endianness bug in set_param_l

Yan Burman (2):
  net/mlx4_en: Fix race when setting the device MAC address
  net/mlx4_en: Cleanup MAC resources on module unload or port stop

 drivers/net/ethernet/mellanox/mlx4/cq.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |   86 +++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/fw.c            |    8 ++
 drivers/net/ethernet/mellanox/mlx4/main.c          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |    2 +-
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    1 -
 drivers/net/ethernet/mellanox/mlx4/mr.c            |   10 +-
 drivers/net/ethernet/mellanox/mlx4/pd.c            |    2 +-
 drivers/net/ethernet/mellanox/mlx4/port.c          |    8 +-
 drivers/net/ethernet/mellanox/mlx4/qp.c            |    8 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |    3 +
 drivers/net/ethernet/mellanox/mlx4/srq.c           |    2 +-
 12 files changed, 75 insertions(+), 59 deletions(-)
