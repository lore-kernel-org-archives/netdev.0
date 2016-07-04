From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/14] mlxsw: Implement basic FIB offload and router interfaces
Date: Mon,  4 Jul 2016 08:23:03 +0200
Message-ID: <1467613397-17140-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34538 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750898AbcGDGXU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 02:23:20 -0400
Received: by mail-wm0-f67.google.com with SMTP id 187so19171649wmz.1
        for <netdev@vger.kernel.org>; Sun, 03 Jul 2016 23:23:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce LPM trees management including virtual router management for HW.
Implement basic FIB offloading using switchdev FIB objects. For now only support
local routes and direct routes (next-hop support will be introduced in
a follow-up patchset).

Introduce router interfaces in patches 10-14.

Ido Schimmel (5):
  mlxsw: spectrum: Edit RIF properties based on netdev events
  mlxsw: spectrum: Introduce support for router interfaces
  mlxsw: spectrum: Unsplit the vFID range
  mlxsw: spectrum: Configure FIDs based on bridge events
  mlxsw: spectrum: Enable L3 interfaces on top of bridge devices

Jiri Pirko (9):
  mlxsw: spectrum_router: Implement private fib
  mlxsw: reg: Add Router Algorithmic LPM Tree Allocation Register
    definition
  mlxsw: reg: Add Router Algorithmic LPM Structure Tree Register
    definition
  mlxsw: reg: Add Router Algorithmic LPM Tree Binding Register
    definition
  mlxsw: spectrum_router: Implement LPM trees management
  mlxsw: spectrum_router: Add virtual router management
  mlxsw: reg: Add Router Algorithmic LPM Unicast Entry Register
    definition
  mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops
  mlxsw: spectrum: Add couple of lower device helper functions

 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 440 +++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 923 +++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 118 ++-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 748 ++++++++++++++++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  70 +-
 include/linux/netdevice.h                          |  18 +
 net/core/dev.c                                     |  46 +
 7 files changed, 2079 insertions(+), 284 deletions(-)

-- 
2.5.5
