From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 0/5] mlxsw: Introduce support for offload forward mark
Date: Thu, 25 Aug 2016 18:42:35 +0200
Message-ID: <1472143360-15796-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        gospo@cumulusnetworks.com, ast@plumgrid.com, edumazet@google.com,
        f.fainelli@gmail.com, dsa@cumulusnetworks.com,
        daniel@iogearbox.net, vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34235 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757520AbcHYQnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 12:43:53 -0400
Received: by mail-wm0-f66.google.com with SMTP id q128so8149553wma.1
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 09:42:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Ido says:
This patchset enables the forwarding of certain control packets by the
device instead of relying on the CPU to do the forwarding.

The first two patches simplify the current switchdev offload forward
infrastructure and make it usable for stacked devices. This is done by
moving the packet and port marking to the bridge driver instead of the
switch driver.

Patches 3-5 add the mlxsw specific bits to support the forward mark.

Ido Schimmel (5):
  switchdev: Support parent ID comparison for stacked devices
  bridge: switchdev: Add forward mark support for stacked devices
  mlxsw: spectrum: Simplify traps definition
  mlxsw: spectrum: Allow different traps to have different actions
  mlxsw: spectrum: Mirror certain packets to CPU

 Documentation/networking/switchdev.txt         |  13 +--
 drivers/net/ethernet/mellanox/mlxsw/core.h     |   1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 156 +++++++------------------
 drivers/net/ethernet/rocker/rocker_main.c      |   2 +-
 drivers/net/ethernet/rocker/rocker_ofdpa.c     |   4 -
 include/linux/netdevice.h                      |   5 -
 include/linux/skbuff.h                         |  13 +--
 include/net/switchdev.h                        |   6 -
 net/bridge/Makefile                            |   2 +
 net/bridge/br_forward.c                        |   3 +-
 net/bridge/br_if.c                             |  10 +-
 net/bridge/br_input.c                          |   2 +
 net/bridge/br_private.h                        |  37 ++++++
 net/bridge/br_switchdev.c                      |  57 +++++++++
 net/core/dev.c                                 |  10 --
 net/switchdev/switchdev.c                      |  87 --------------
 16 files changed, 158 insertions(+), 250 deletions(-)
 create mode 100644 net/bridge/br_switchdev.c

-- 
2.5.5
