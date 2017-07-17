From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/4] mlxsw: Traps enhancements
Date: Mon, 17 Jul 2017 14:15:28 +0200
Message-ID: <20170717121532.4036-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:33287 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751289AbdGQMPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:15:35 -0400
Received: by mail-wr0-f194.google.com with SMTP id 40so2509328wrw.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:15:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:

The first patch makes sure the driver marks packets that were trapped
in the router and might have already been flooded by the bridge, so that
the bridge driver won't flood them again. This isn't critical at this time
point, but will be when Neighbour Discovery traps are introduced as these
are multicast packets that are trapped in the router.

The second and third patches add new traps - for MLD and Router Alert
packets. The last patch takes advantage of that and floods IPv6
unregistered multicast packets only to mrouter ports instead of all ports.

Arkadi Sharshevsky (2):
  mlxsw: spectrum: Add support for IPv6 MLDv1/2 traps
  mlxsw: spectrum: Improve IPv6 unregistered multicast flooding

Ido Schimmel (2):
  mlxsw: spectrum: Mark packets trapped in router
  mlxsw: spectrum: Trap IPv4 packets with Router Alert option

 drivers/net/ethernet/mellanox/mlxsw/reg.h          |  1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     | 25 ++++++++++++++++------
 drivers/net/ethernet/mellanox/mlxsw/spectrum_fid.c |  2 +-
 drivers/net/ethernet/mellanox/mlxsw/trap.h         |  5 +++++
 4 files changed, 25 insertions(+), 8 deletions(-)

-- 
2.9.3
