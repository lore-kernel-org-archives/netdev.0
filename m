From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/7] mlxsw: Offload FDB learning configuration
Date: Wed, 24 Aug 2016 12:00:22 +0200
Message-ID: <1472032829-6322-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34521 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932368AbcHXKBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2016 06:01:21 -0400
Received: by mail-wm0-f65.google.com with SMTP id q128so1861745wma.1
        for <netdev@vger.kernel.org>; Wed, 24 Aug 2016 03:00:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:
This patchset addresses two long standing issues in the mlxsw driver
concerning FDB learning.

Patch 1 limits the number of FDB records processed by the driver in a
single session. This is useful in situations in which many new records
need to be processed, thereby causing the RTNL mutex to be held for
long periods of time.

Patches 2-6 offload the learning configuration (on / off) of bridge
ports to the device instead of having the driver decide whether a
record needs to be learned or not.

The last patch is fallout and removes configuration no longer necessary
after the first patches are applied.

Ido Schimmel (7):
  mlxsw: spectrum: Limit number of FDB records per learning session
  mlxsw: spectrum: Make VLAN deletion function symmetric
  mlxsw: spectrum: Don't abort on first error when removing VLANs
  mlxsw: spectrum: Configure learning for VLAN-aware bridge port
  mlxsw: spectrum: Offload learning to the switch ASIC
  mlxsw: spectrum: Remove unnecessary check in FDB processing
  mlxsw: spectrum: Don't set learning when creating vPorts

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |   7 ++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |  24 ++--
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   3 +
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   | 128 +++++++++++++++------
 4 files changed, 115 insertions(+), 47 deletions(-)

-- 
2.5.5
