From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/19] mlxsw: traps, trap groups and policers
Date: Fri, 25 Nov 2016 10:33:28 +0100
Message-ID: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:33390 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wj0-f193.google.com with SMTP id kp2so4928068wjc.0
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Nogah says:

For a packet to be sent from the HW to the cpu, it needs to be trapped.
For a trap to be activate it should be assigned to a trap group.
Those trap groups can have policers, to limit the packet rate (the max
number of packets that can be sent to the cpu in a time slot, the rest
will be discarded) or the data rate (the same, but the count is not by the
number of packets but by their total length in bytes).

This patchset rearrange the trap setting API, re-write the traps and the
trap groups list in spectrum and assign them policers.

Nogah Frankel (19):
  mlxsw: spectrum: Remove unused traps
  mlxsw: core: Create a generic function to register / unregister traps
  mlxsw: core: Expose generic macros for rx trap
  mlxsw: spectrum: Use generic listener struct for rx traps
  mlxsw: switchx2: Use generic listener struct for rx traps
  mlxsw: core: Introduce generic macro for event
  mlxsw: spectrum: Use generic listener struct for events
  mlxsw: switchx2: Use generic listener struct for events
  mlxsw: switchib: Use generic listener struct for events
  mlxsw: Change trap set function
  mlxsw: Add option to choose trap group
  mlxsw: core: Change emad trap group settings
  mlxsw: resources: Add max trap groups resource
  mlxsw: Change trap groups setting
  mlxsw: spectrum: Add BGP trap
  mlxsw: Create a different trap group list for each device
  mlxsw: resources: Add max cpu policers resource
  mlxsw: reg: Add QoS Policer Configuration Register
  mlxsw: spectrum: Add policers for trap groups

 drivers/net/ethernet/mellanox/mlxsw/core.c      | 116 ++++++---
 drivers/net/ethernet/mellanox/mlxsw/core.h      |  52 ++++
 drivers/net/ethernet/mellanox/mlxsw/reg.h       | 231 +++++++++++++----
 drivers/net/ethernet/mellanox/mlxsw/resources.h |   4 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c  | 322 ++++++++++++++----------
 drivers/net/ethernet/mellanox/mlxsw/switchib.c  |  78 +++---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c  | 229 +++++------------
 drivers/net/ethernet/mellanox/mlxsw/trap.h      |   1 +
 8 files changed, 625 insertions(+), 408 deletions(-)

-- 
2.7.4
