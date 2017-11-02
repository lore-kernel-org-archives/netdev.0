From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/8] nfp: TC block fixes, app fallback and dev_alloc()
Date: Thu,  2 Nov 2017 01:31:28 -0700
Message-ID: <20171102083136.2096-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:52631 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755341AbdKBIcW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 04:32:22 -0400
Received: by mail-pg0-f68.google.com with SMTP id a192so4432714pge.9
        for <netdev@vger.kernel.org>; Thu, 02 Nov 2017 01:32:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series has three parts.  First of all John and I fix some 
fallout from the TC block conversion.  John also fixes sleeping 
in the neigh notifier.

Secondly I reorganise the nfp_app table to make it easier to
deal with excluding apps which have unmet Kconfig dependencies.

Last but not least after the fixes which went into -net some time
ago I refactor the page allocation, add a ethtool counter for
failed allocations and clean the ethtool stat code while at it.


Jakub Kicinski (6):
  nfp: bpf: reject TC offload if XDP loaded
  nfp: reorganize the app table
  nfp: bpf: fall back to core NIC app if BPF not selected
  nfp: switch to dev_alloc_page()
  nfp: use a counter instead of log message for allocation failures
  nfp: improve defines for constants in ethtool

John Hurley (2):
  nfp: flower: app should use struct nfp_repr
  nfp: flower: vxlan - ensure no sleep in atomic context

 drivers/net/ethernet/netronome/nfp/Makefile        |  4 +-
 drivers/net/ethernet/netronome/nfp/bpf/main.c      |  3 ++
 drivers/net/ethernet/netronome/nfp/bpf/offload.c   |  3 --
 drivers/net/ethernet/netronome/nfp/flower/cmsg.c   |  9 +++--
 drivers/net/ethernet/netronome/nfp/flower/cmsg.h   |  2 +-
 drivers/net/ethernet/netronome/nfp/flower/main.h   |  2 +-
 .../net/ethernet/netronome/nfp/flower/offload.c    | 14 +++----
 .../ethernet/netronome/nfp/flower/tunnel_conf.c    | 47 +++++++++-------------
 drivers/net/ethernet/netronome/nfp/nfp_app.c       | 20 ++++-----
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 17 +++++---
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 25 +++++++-----
 12 files changed, 77 insertions(+), 72 deletions(-)

-- 
2.14.1
