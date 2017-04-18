From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/8] mlxsw: Allow flow based forwarding in OVS
Date: Tue, 18 Apr 2017 16:55:30 +0200
Message-ID: <1492527338-13298-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:34186 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752936AbdDROzk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 10:55:40 -0400
Received: by mail-wr0-f196.google.com with SMTP id u18so25245188wrc.1
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 07:55:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This patchset does some fixes so the HW is setup correctly to do
flow-based (ACL based) forwarding for OVS-enslaved port.

The first patch is just trivial fix spotted on the way.

Patches 2-4 take care of proper FID setup which HW needs in order to
for ACL based forwarding.

The 7th patch (with dependency of patch 5 and 6) takes care of proper setup
of ports that are enslaved in OVS.

The last patch implements new FID miss trap that is used to push
packets belonging to unknown flows to kernel and userspace.

Jiri Pirko (8):
  mlxsw: spectrum: Fix indent in mlxsw_sp_netdevice_port_upper_event
  mlxsw: spectrum: Implement action to set FID
  mlxsw: spectrum: Add dummy FID initialization
  mlxsw: spectrum_flower: Set dummy FID before forward action
  mlxsw: spectrum: Teach mlxsw_sp_port_vlan_set to accept any vlan range
  net: add netif_is_ovs_port helper
  mlxsw: spectrum: Allow ports to work under OVS master
  mlxsw: spectrum: Add FID miss trap

 .../mellanox/mlxsw/core_acl_flex_actions.c         |  44 ++++++++
 .../mellanox/mlxsw/core_acl_flex_actions.h         |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 113 ++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   7 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum_acl.c |   7 ++
 .../net/ethernet/mellanox/mlxsw/spectrum_flower.c  |   5 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  |   4 +-
 .../ethernet/mellanox/mlxsw/spectrum_switchdev.c   |  33 ++----
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |   1 +
 include/linux/netdevice.h                          |   5 +
 10 files changed, 186 insertions(+), 34 deletions(-)

-- 
2.7.4
