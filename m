From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: cleanup neigh handling
Date: Mon,  6 Feb 2017 16:20:09 +0100
Message-ID: <1486394417-8011-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33605 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdBFPUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 10:20:20 -0500
Received: by mail-wm0-f65.google.com with SMTP id v77so22463909wmv.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 07:20:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

This series addresses long standing issues in the mlxsw driver
concerning neighbour reflection. It also prepares the code for follow-up
changes dealing with proper resource cleanup and nexthop reflection.

The first two patches convert the neighbour reflection code to use an
ordered workqueue, to prevent re-ordering of NEIGH_UPDATE events that
may happen following subsequent patches.

The third to fifth patches remove the ndo_neigh_{construct,destroy}
entry points from the driver, thereby relying only on NEIGH_UPDATE
events for neighbour reflection. This simplifies the code considerably.

Last patches are fallout and adjust nits in the code I noticed while
going over it.

Ido Schimmel (8):
  mlxsw: core: Queue work immediately instead of delaying it
  mlxsw: spectrum_router: Use ordered workqueue for neigh updates
  mlxsw: spectrum_router: Remove unused variable
  mlxsw: spectrum_router: Simplify neighbour reflection
  net: remove ndo_neigh_{construct,destroy} from stacked devices
  mlxsw: spectrum_router: Remove redundant check
  mlxsw: spectrum_router: Don't read 'nud_state' without lock
  mlxsw: spectrum_router: Fix typo in comment

 drivers/net/bonding/bond_main.c                    |   2 -
 drivers/net/ethernet/mellanox/mlxsw/core.c         |   6 +-
 drivers/net/ethernet/mellanox/mlxsw/core.h         |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 -
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 287 +++++++++++----------
 drivers/net/team/team.c                            |   2 -
 include/linux/netdevice.h                          |   4 -
 net/8021q/vlan_dev.c                               |   2 -
 net/bridge/br_device.c                             |   2 -
 net/core/dev.c                                     |  44 ----
 11 files changed, 148 insertions(+), 209 deletions(-)

-- 
2.7.4
