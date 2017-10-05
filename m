From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/6] mlxsw: Offload bridge device mrouter
Date: Thu,  5 Oct 2017 12:36:36 +0200
Message-ID: <20171005103642.1414-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:37638 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751522AbdJEKgp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:45 -0400
Received: by mail-wr0-f196.google.com with SMTP id v38so6397789wrc.4
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 03:36:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

Similarly to a bridged port, the bridge device itself can be configured by
the user to be an mrouter port. In this case, all multicast traffic should
be forwarded to it. Make the mlxsw Spectrum driver offload these directives
to the Spectrum hardware.

Patches 1-3 add a new switchdev notification for bridge device mrouter
port status and make the bridge module notify about it.

Patches 4-6 change the mlxsw Spectrum driver to handle these notifications
by adding the Spectrum router port to the bridge MDB entries.

Yotam Gigi (6):
  net: bridge: Use the MDB_RTR_TYPE_TEMP on bridge device too
  net: bridge: Notify on bridge device mrouter state changes
  net: bridge: Export bridge multicast router state
  mlxsw: spectrum: router: Export the mlxsw_sp_router_port function
  mlxsw: spectrum_switchdev: Add support for router port in SMID entries
  mlxsw: spectrum_switchdev: Support bridge mrouter notifications

 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |  2 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.h  |  1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 76 +++++++++++++++++++++-
 include/linux/if_bridge.h                          |  5 ++
 include/net/switchdev.h                            |  1 +
 net/bridge/br_multicast.c                          | 56 ++++++++++++++--
 net/bridge/br_netlink.c                            |  3 +-
 net/bridge/br_private.h                            | 13 +++-
 net/bridge/br_sysfs_br.c                           |  3 +-
 9 files changed, 147 insertions(+), 13 deletions(-)

-- 
2.9.5
