From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/14] mlxws: update driver to support offload of bridged vlan devices
Date: Tue, 15 Dec 2015 16:03:33 +0100
Message-ID: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:36013 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933550AbbLOPD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:03:57 -0500
Received: by mail-wm0-f50.google.com with SMTP id n186so169108612wmn.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel says:
        
====================
This patchset introduces support for the offloading of 802.1D bridges
between VLAN devices. These can either be VLAN devices configured on top
of the physical ports or on top of LAG devices.

Patches 1-2 deal with the necessary infrastructure changes needed in order
to enable the above. The main change is that switchdev drivers can now know
the device from which the switchdev op originated from.

Patches 3-10 lay the groundwork for 802.1D bridges support in the mlxsw
driver, with patch 4 doing most of the heavy lifting.

Patch 11 finally offloads these bridges to hardware by listening to the
notifications sent when the VLAN device joins or leaves a bridge. It is
very similar to the already existing 802.1Q bridge we support.

Patches 12-14 add minor modifications to allow one to bridge a VLAN device
configured on top of LAG.
====================

Signed-off-by: Jiri Pirko <jiri@mellanox.com>

Ido Schimmel (14):
  switchdev: vlan: Use switchdev_port* in vlan_netdev_ops
  switchdev: Pass original device to port netdev driver
  mlxsw: spectrum: Allocate active VLANs only for port netdevs
  mlxsw: spectrum: Split vFID range in two
  mlxsw: spectrum: Use appropriate parameter name
  mlxsw: spectrum: Add another flood table for vFIDs
  mlxsw: spectrum: Use FID instead of VID when accessing FDB
  mlxsw: spectrum: Adjust switchdev ops for VLAN devices
  mlxsw: spectrum: Adjust FDB notifications for VLAN devices
  mlxsw: spectrum: Handle VLAN devices linking / unlinking
  mlxsw: spectrum: Add support for VLAN devices bridging
  mlxsw: reg: Add lag_vid field to SFD register
  mlxsw: spectrum: Enable FDB records for VLAN devices on top of LAG
  mlxsw: spectrum: Add support for VLAN devices on top of LAG

 drivers/net/ethernet/mellanox/mlxsw/Kconfig        |   2 +-
 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  22 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 774 ++++++++++++++++++---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     | 102 ++-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 234 ++++++-
 include/net/switchdev.h                            |   2 +
 net/8021q/vlan_dev.c                               |   7 +
 net/bridge/br_fdb.c                                |   1 +
 net/bridge/br_stp.c                                |   2 +
 net/bridge/br_stp_if.c                             |   1 +
 net/bridge/br_vlan.c                               |   2 +
 net/core/net-sysfs.c                               |   1 +
 net/core/rtnetlink.c                               |   1 +
 net/switchdev/switchdev.c                          |  12 +
 14 files changed, 1001 insertions(+), 162 deletions(-)

-- 
1.9.3
