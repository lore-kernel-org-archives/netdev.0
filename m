From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/6] nfp: refactor app init, and minor flower fixes
Date: Sat,  2 Sep 2017 18:25:59 -0700
Message-ID: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35278 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752951AbdICB0N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:13 -0400
Received: by mail-pf0-f179.google.com with SMTP id g13so9555163pfm.2
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series is a part 2 to what went into net as a simpler fix.
In net we simply moved when existing callbacks are invoked to
ensure flower app does not still use representors when lower 
netdev has already been destroyed.  In this series we add a
callback to notify apps when vNIC netdevs are fully initialized
and they are about to be destroyed.  This allows flower to spawn
representors at the right time, while keeping the start/stop
callbacks for what they are intended to be used - FW initialization
over control channel.

Patch 4 improves drop monitor interaction and patch 5 changes 
the default Kconfig selection of flower offload.  Patch 6 fixes
locking around representor updates which got lost in net-next.

Jakub Kicinski (6):
  nfp: separate app vNIC init/clean from alloc/free
  nfp: flower: base lifetime of representors on existence of lower vNIC
  nfp: move the start/stop app callbacks back
  nfp: be drop monitor friendly
  nfp: build the flower offload by default
  nfp: flower: restore RTNL locking around representor updates

 drivers/net/ethernet/netronome/Kconfig             |  1 +
 drivers/net/ethernet/netronome/nfp/bpf/main.c      | 10 +--
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   | 11 ++-
 drivers/net/ethernet/netronome/nfp/flower/main.c   | 93 +++++++++++++++-------
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  2 +
 drivers/net/ethernet/netronome/nfp/nfp_app.c       |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_app.h       | 35 +++++---
 drivers/net/ethernet/netronome/nfp/nfp_app_nic.c   |  4 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  2 +-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 42 ++++++----
 drivers/net/ethernet/netronome/nfp/nic/main.c      |  2 +-
 11 files changed, 136 insertions(+), 68 deletions(-)

-- 
2.14.1
