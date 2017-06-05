From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/19] Remove support from bridge bypass for mlxsw/rocker drivers
Date: Mon,  5 Jun 2017 11:20:24 +0200
Message-ID: <20170605092043.3523-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com, roopa@cumulusnetworks.com,
        stephen@networkplumber.org, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33969 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751512AbdFEJUq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 05:20:46 -0400
Received: by mail-wr0-f195.google.com with SMTP id u101so4373974wrc.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 02:20:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Currently setting bridge port attributes and adding FDBs are done via
setting the SELF flag which implies unconsistent offloading model. This
patch-set fixes this behavior by making the bridge and drivers which are
using it to be totally in sync.

This implies several changes:
- Offloading bridge flags from the bridge code.
- Sending notification about FDB add/del to the software bridge in a
  similiar way it is done for the hardware externally learned FDBs.

By making the offloading model more consistent a cleanup is done in
the drivers supporting it. This is done in order to remove un-needed
logic related to dump operation which is redundant.

First add missing functionality to bridge, then clean up the mlxsw/rocker
drivers.

Arkadi Sharshevsky (19):
  net: switchdev: Add support for querying supported bridge flags by
    hardware
  net: bridge: Add support for offloading port attributes
  net: bridge: Add support for calling FDB external learning under rcu
  net: switchdev: Change notifier chain to be atomic
  net: bridge: Add support for notifying devices about FDB add/del
  net: bridge: Receive notification about successful FDB offload
  mlxsw: spectrum: Remove support for bridge FDB learning sync
  mlxsw: spectrum_switchdev: Add support for querying supported bridge
    flags
  mlxsw: spectrum: Remove support for bypass bridge port attributes/vlan
    set
  mlxsw: spectrum_switchdev: Change switchdev notifier API
  mlxsw: spectrum_switchdev: Add support for learning FDB through
    notification
  mlxsw: spectrum: Remove support for bridge bypass FDB add/del
  net: Remove support for bridge bypass ndos from stacked devices
  rocker: Remove support for bridge FDB learning sync
  rocker: Add support for querying supported bridge flags
  rocker: Change world_ops API and implementation to be switchdev
    independant
  rocker: Add support for learning FDB through notification
  rocker: Remove support for bypass bridge port attributes/vlan set
  rocker: Remove support bridge bypass FDB

 drivers/net/bonding/bond_main.c                    |   6 -
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   8 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 360 +++++-------
 drivers/net/ethernet/rocker/rocker.h               |  21 +-
 drivers/net/ethernet/rocker/rocker_main.c          | 235 +++++---
 drivers/net/ethernet/rocker/rocker_ofdpa.c         | 610 ++++++++-------------
 drivers/net/team/team.c                            |   6 -
 include/net/switchdev.h                            |   9 +-
 include/uapi/linux/neighbour.h                     |   1 +
 net/8021q/vlan_dev.c                               |   6 -
 net/bridge/br.c                                    |  19 +-
 net/bridge/br_fdb.c                                |  46 +-
 net/bridge/br_netlink.c                            | 112 +++-
 net/bridge/br_private.h                            |  23 +-
 net/bridge/br_switchdev.c                          |  13 +
 net/switchdev/switchdev.c                          |  30 +-
 17 files changed, 714 insertions(+), 792 deletions(-)

-- 
2.9.3
