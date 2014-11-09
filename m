From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V3 net-next 0/2] mlx4: Add CHECKSUM_COMPLETE support
Date: Sun,  9 Nov 2014 13:51:51 +0200
Message-ID: <1415533913-7012-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:42289 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751568AbaKILwJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Nov 2014 06:52:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, 

These patches from Shani, Matan and myself add support for 
CHECKSUM_COMPLETE reporting on non TCP/UDP packets such as 
GRE and ICMP. I'd like to deeply thank Jerry Chu for his 
innovation and support in that effort.

Based on the feedback from Eric and Ido Shamay, in V2 we dropped 
the patch which removed the calls to napi_gro_frags() and added 
a patch which makes the RX code to go through that path 
regardless of the checksum status.

Or.

changes from V2:
 - make sure to decrement the checksum complete ring counter when we
   fail to come up with that status for a packet

changes from V0/V1:
 - added a patch to extend usage napi_gro_frags()
 - applied feedback from David Laight to optimally use checksum helpers


Shani Michaeli (2):
  net/mlx4_en: Extend usage of napi_gro_frags
  net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c  |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_port.c    |    2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c      |  228 +++++++++++++++++------
 drivers/net/ethernet/mellanox/mlx4/main.c       |    9 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    5 +-
 include/linux/mlx4/device.h                     |    1 +
 7 files changed, 193 insertions(+), 59 deletions(-)
