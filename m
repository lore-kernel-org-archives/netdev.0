From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 0/2] mlxsw: spectrum: Configure TTL of "inherit" for offloaded tunnels
Date: Fri, 20 Oct 2017 09:16:14 +0200
Message-ID: <20171020071616.1498-1-jiri@resnulli.us>
Cc: davem@davemloft.net, petrm@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:47176 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751718AbdJTHQS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2017 03:16:18 -0400
Received: by mail-wm0-f67.google.com with SMTP id t69so19991694wmt.2
        for <netdev@vger.kernel.org>; Fri, 20 Oct 2017 00:16:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Petr says:

Currently mlxsw only offloads tunnels that are configured with TTL of "inherit"
(which is the default). However, Spectrum defaults to 255 and the driver
neglects to change the configuration. Thus the tunnel packets from offloaded
tunnels always have TTL of 255, even though tunnels with explicit TTL of 255 are
never actually offloaded.

To fix this, introduce support for TIGCR, the register that keeps the related
bits of global tunnel configuration, and use it on first offload to properly
configure inheritance of TTL of tunnel packets from overlay packets.

Petr Machata (2):
  mlxsw: reg: Add Tunneling IPinIP General Configuration Register
  mlxsw: spectrum_router: Configure TIGCR on init

 drivers/net/ethernet/mellanox/mlxsw/reg.h          | 31 ++++++++++++++++++++++
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 11 +++++++-
 2 files changed, 41 insertions(+), 1 deletion(-)

-- 
2.9.5
