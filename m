From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 00/15] mlxsw: Reflect nexthop status changes
Date: Wed,  8 Feb 2017 11:16:27 +0100
Message-ID: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35168 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752511AbdBHKQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 05:16:45 -0500
Received: by mail-wm0-f68.google.com with SMTP id u63so32403644wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 02:16:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

When the kernel forwards IPv4 packets via multipath routes it doesn't
consider nexthops that are dead or linkdown. For example, if the nexthop
netdev is administratively down or doesn't have a carrier.

Devices capable of offloading such multipath routes need to be made
aware of changes in the reflected nexthops' status. Otherwise, the
device might forward packets via non-functional nexthops, resulting in
packet loss. This patchset aims to fix that.

The first 11 patches deal with the necessary restructuring in the
mlxsw driver, so that it's able to correctly add and remove nexthops
from the device's adjacency table.

The 12th patch adds the NH_{ADD,DEL} events to the FIB notification
chain. These notifications are sent whenever the kernel decides to add
or remove a nexthop from the forwarding plane.

Finally, the last three patches add support for these events in the
mlxsw driver, which is currently the only driver capable of offloading
multipath routes.

Ido Schimmel (15):
  mlxsw: spectrum_router: Nullify nexthop's neigh pointer
  mlxsw: spectrum_router: Store nexthop groups in a hash table
  mlxsw: spectrum_router: Store nexthops in a hash table
  mlxsw: spectrum_router: Use nexthop's scope to set action type
  mlxsw: spectrum_router: Add gateway indication to nexthop group
  mlxsw: spectrum_router: Store routes in a more generic way
  mlxsw: spectrum_router: Remove FIB info from FIB entry struct
  mlxsw: spectrum_router: Refactor nexthop init routine
  mlxsw: spectrum_router: More accurately set offload flag
  mlxsw: spectrum_router: Determine offload status using generic
    function
  mlxsw: spectrum_router: Use trap action only for some route types
  ipv4: fib: Notify about nexthop status changes
  mlxsw: spectrum_router: Reflect nexthop status changes
  mlxsw: spectrum_router: Don't reflect LINKDOWN nexthops
  mlxsw: spectrum_router: Flush resources when RIF is deleted

 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   6 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   7 +-
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 534 ++++++++++++++++-----
 include/net/ip_fib.h                               |   7 +
 net/ipv4/fib_semantics.c                           |  33 ++
 5 files changed, 457 insertions(+), 130 deletions(-)

-- 
2.7.4
