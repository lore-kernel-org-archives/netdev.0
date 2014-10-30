From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 0/8] Mellanox ethernet driver update Oct-30-2014
Date: Thu, 30 Oct 2014 18:06:48 +0200
Message-ID: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37955 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1758190AbaJ3QHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Oct 2014 12:07:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The 1st patch from Saeed fixes a bug in the last net-next batch where
a VF could get access to set port configuration, the next patch from Amir
fixes a race in the port VPI logic. Next are two performance patches from Ido.

The last four patches from Shani, Matan and myself add support for CHECKSUM_COMPLETE 
reporting on non TCP/UDP packets such as GRE and ICMP. I'd like to deeply thank 
Jerry Chu for his innovation and support in that effort.

Or.

Amir Vadai (1):
  net/mlx4_core: Protect port type setting by mutex

Ido Shamay (2):
  net/mlx4_en: Remove RX buffers alignment to IP_ALIGN
  net/mlx4_en: Add __GFP_COLD gfp flags in alloc_pages

Matan Barak (1):
  net/mlx4_core: Add retrieval of CONFIG_DEV parameters

Or Gerlitz (1):
  net/mlx4_en: Remove redundant code from RX/GRO path

Saeed Mahameed (1):
  net/mlx4_core: Prevent VF from changing port configuration

Shani Michaeli (1):
  net: Add calaulation of non folded IPV6 pseudo header checksum
  net/mlx4_en: Extend checksum offloading by CHECKSUM COMPLETE

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c    |    2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |    5 +
 drivers/net/ethernet/mellanox/mlx4/en_port.c       |    2 +
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  186 ++++++++++++--------
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  118 ++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c          |   18 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   10 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    6 +-
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 ++
 include/linux/mlx4/cmd.h                           |   29 +++
 include/linux/mlx4/device.h                        |    4 +-
 include/net/ip6_checksum.h                         |   21 +++
 13 files changed, 339 insertions(+), 85 deletions(-)
