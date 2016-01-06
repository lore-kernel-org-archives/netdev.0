From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: add offload support for vlan_filtering option
Date: Wed,  6 Jan 2016 11:11:48 +0100
Message-ID: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:37406 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253AbcAFKMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:00 -0500
Received: by mail-wm0-f50.google.com with SMTP id f206so68227945wmf.0
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:11:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Elad says:

This patch adds SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING port attribute.
When a bridge is offloaded to hardware, the hardware can learn if the bridge is
.1Q bridge (VLAN-aware) or not VLAN aware bridge.
In order to toggle the mode a user can use sysfs:
$ echo 1 > /sys/devices/virtual/net/br0/bridge/vlan_filtering
or via iproute2:
$ ip link set dev br0 type bridge vlan_filtering 1

Elad Raz (8):
  bridge: Propagate vlan add failure to user
  switchdev: add bridge vlan_filtering attribute
  bridge: add vlan filtering change notification
  bridge: add vlan filtering change for new bridged device
  mlxsw: Fixing vlans init range
  mlxsw: Renaming local variable names for consistency
  mlxsw: Disable vlan_filtering for non .1D bridge
  mlxsw: Remember untagged VLANs

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  8 +++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |  1 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 39 +++++++++++++++++++---
 include/net/switchdev.h                            |  2 ++
 net/bridge/br_if.c                                 | 10 +++++-
 net/bridge/br_vlan.c                               | 29 ++++++++++++++--
 6 files changed, 81 insertions(+), 8 deletions(-)

-- 
1.9.3
