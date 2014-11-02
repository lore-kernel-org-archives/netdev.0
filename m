From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH V1 net-next 0/5] Mellanox ethernet driver update Oct-30-2014
Date: Sun,  2 Nov 2014 16:26:12 +0200
Message-ID: <1414938377-421-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:52331 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751074AbaKBO0X (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 2 Nov 2014 09:26:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The 1st patch from Saeed fixes a bug in the last net-next batch where
a VF could get access to set port configuration, the next patch from Amir
fixes a race in the port VPI logic. Next are two performance patches from Ido.

The patch to add checksum complete status on GRE and such packets was 
preceded with a patch that converted the driver to only use napi_gro_receive 
vs. the current code which goes through napi_gro_frags on it's usual track.
Eric D. has some thoughts and suggestions on that change for which we 
want to take the time and consider, so for the time being dropped that
patch and the ones that depend on it.

Or.

Changes from V0:
  - have the caller to provide the __GFP_COLD hint to the service function
  - dropped the patch that changes the GRO logic and the subsequent dependent
    patches. 

Amir Vadai (1):
  net/mlx4_core: Protect port type setting by mutex

Ido Shamay (2):
  net/mlx4_en: Remove RX buffers alignment to IP_ALIGN
  net/mlx4_en: Add __GFP_COLD gfp flags in alloc_pages

Matan Barak (1):
  net/mlx4_core: Add retrieval of CONFIG_DEV parameters

Saeed Mahameed (1):
  net/mlx4_core: Prevent VF from changing port configuration

 drivers/net/ethernet/mellanox/mlx4/cmd.c           |    6 +-
 drivers/net/ethernet/mellanox/mlx4/en_rx.c         |   23 ++---
 drivers/net/ethernet/mellanox/mlx4/fw.c            |  118 +++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlx4/main.c          |    9 ++-
 drivers/net/ethernet/mellanox/mlx4/mlx4.h          |   10 ++
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h       |    1 -
 .../net/ethernet/mellanox/mlx4/resource_tracker.c  |   17 +++
 include/linux/mlx4/cmd.h                           |   29 +++++
 include/linux/mlx4/device.h                        |    3 +-
 9 files changed, 190 insertions(+), 26 deletions(-)
