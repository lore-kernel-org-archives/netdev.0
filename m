From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/18] mlxsw: Do preparations before ipv4 router offload introduction
Date: Sat,  2 Jul 2016 09:26:22 +0200
Message-ID: <1467444400-9480-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33113 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794AbcGBH1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 03:27:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id r201so9907142wme.0
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 00:26:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset introduces router interfaces. At this point the router
still operates in slowpath, but that's needed in order not to introduce a
regression.

Ido Schimmel (16):
  mlxsw: spectrum: Send untagged packets through a port netdev
  mlxsw: spectrum: Remove VLANs configuration via SELF flag
  mlxsw: spectrum: Sync PVID vPort LAG status
  mlxsw: spectrum: Remove RIF from PVID vPort when joining / leaving LAG
  mlxsw: reg: Add Router General Configuration Register
  mlxsw: spectrum: Initialize ports at the end of init sequence
  mlxsw: spectrum_router: Add basic ipv4 router initialization
  mlxsw: spectrum: Add router interface struct
  mlxsw: reg: Add FDB action to forward to router
  mlxsw: reg: Add Router Interface Table Register
  mlxsw: spectrum: Use action 'discard' when removing traps
  mlxsw: spectrum: Edit RIF properties based on netdev events
  mlxsw: spectrum: Introduce support for router interfaces
  mlxsw: spectrum: Unsplit the vFID range
  mlxsw: spectrum: Configure FIDs based on bridge events
  mlxsw: spectrum: Enable L3 interfaces on top of bridge devices

Jiri Pirko (2):
  mlxsw: spectrum: Add traps needed for router implementation
  mlxsw: spectrum: Add couple of lower device helper functions

 drivers/net/ethernet/mellanox/mlxsw/Makefile       |    2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  276 ++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 1158 ++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   93 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |   68 ++
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  107 +-
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |    5 +
 include/linux/netdevice.h                          |   18 +
 net/core/dev.c                                     |   46 +
 9 files changed, 1358 insertions(+), 415 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c

-- 
2.5.5
