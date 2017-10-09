From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 0/5] mlxsw: Offload bridge device mrouter
Date: Mon,  9 Oct 2017 11:15:30 +0200
Message-ID: <20171009091535.1315-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com, ivecera@redhat.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:44070 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751550AbdJIJPh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 05:15:37 -0400
Received: by mail-wm0-f44.google.com with SMTP id 196so10584370wma.1
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 02:15:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Yotam says:

Similarly to a bridged port, the bridge device itself can be configured by
the user to be an mrouter port. In this case, all multicast traffic should
be forwarded to it. Make the mlxsw Spectrum driver offload these directives
to the Spectrum hardware.

Patches 1 and 2 add a new switchdev notification for bridge device mrouter
port status and make the bridge module notify about it.

Patches 3-5 change the mlxsw Spectrum driver to handle these notifications
by adding the Spectrum router port to the bridge MDB entries.

---
v1->v2:
 - patch1:
   - Don't add the MDB_RTR_TYPE_TEMP state and use the timer_pending to
     distinguish between learning-on and learning-off states

Yotam Gigi (5):
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
 net/bridge/br_multicast.c                          | 50 +++++++++++++-
 6 files changed, 128 insertions(+), 7 deletions(-)

-- 
2.9.5
