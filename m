From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/22] mlxsw: Preparations for IPv6 UC router
Date: Tue, 18 Jul 2017 10:10:08 +0200
Message-ID: <20170718081030.2781-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, arkadis@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:35459 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbdGRIKe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 04:10:34 -0400
Received: by mail-wr0-f195.google.com with SMTP id a10so2869663wrd.2
        for <netdev@vger.kernel.org>; Tue, 18 Jul 2017 01:10:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The purpose of this set is to prepare the driver for the introduction of
IPv6 FIB offload. It's mainly composed of small and non-functional
changes, that either add the IPv6 equivalent of existing IPv4 code or
aimed at making the introduction of IPv6-specific code easier.

The first five patches enable IPv6 forwarding in the device and allow us
to configure router interfaces (RIFs) based on inet6addr notifications.

The next six patches add support for programming IPv6 neighbours into
the device's table as well as dumping their activity and updating the
kernel accordingly.

The last 11 patches extend current infrastructure to allow us to program
IPv6 routes, set catch-all IPv6 trap in case of abort and make the code
more receptive towards up-coming changes.

Arkadi Sharshevsky (9):
  mlxsw: spectrum_router: Enable IPv6 router
  mlxsw: reg: Enable IPv6 on router interfaces
  mlxsw: spectrum: Add support for IPv6 traps
  mlxsw: spectrum_router: Configure RIFs based on IPv6 addresses
  mlxsw: reg: Update RAUHT register with IPv6 support
  mlxsw: spectrum_router: Reflect IPv6 neighbours to the device
  mlxsw: reg: Update RAUHTD register with IPv6 support
  mlxsw: spectrum_router: Periodically dump active IPv6 neighbours
  mlxsw: spectrum_router: Set activity interval according to both
    neighbour tables

Ido Schimmel (13):
  mlxsw: spectrum_router: Flood unregistered multicast packets to router
  mlxsw: spectrum_router: Don't assume neighbour type
  mlxsw: spectrum_router: Don't create FIB node during lookup
  mlxsw: spectrum_router: Make FIB node retrieval family agnostic
  mlxsw: spectrum_router: Extend virtual routers with IPv6 support
  mlxsw: reg: Update RALUE register with IPv6 support
  mlxsw: spectrum_router: Allow IPv6 routes to be programmed
  mlxsw: spectrum_router: Set abort trap for IPv6
  mlxsw: spectrum_router: Create IPv4 specific entry struct
  mlxsw: spectrum_router: Mark IPv4 specific function accordingly
  mlxsw: spectrum_router: Drop unnecessary parameter
  mlxsw: spectrum_router: Rename functions to add / delete a FIB entry
  mlxsw: spectrum_router: Update prefix count for IPv6

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  64 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  47 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   2 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 746 ++++++++++++++-------
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |  20 +-
 5 files changed, 622 insertions(+), 257 deletions(-)

-- 
2.9.3
