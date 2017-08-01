From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/7] drivers: net: Fix 64-bit statistics seqcount init
Date: Tue,  1 Aug 2017 12:11:05 -0700
Message-ID: <20170801191113.8754-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, edumazet@google.com,
        Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34249 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751983AbdHATLX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 15:11:23 -0400
Received: by mail-wm0-f67.google.com with SMTP id x64so4410103wmg.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 12:11:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

This patch series fixes a bunch of drivers to have their 64-bit statistics
seqcount cookie be initialized correctly. Most of these drivers (except b44,
gtp) are probably used on 64-bit only hosts and so the lockdep splat might have
never been seen.

Florian Fainelli (7):
  b44: Initialize 64-bit stats seqcount
  i40e: Initialize 64-bit statistics TX ring seqcount
  ixgbe: Initialize 64-bit stats seqcounts
  nfp: Initialize RX and TX ring 64-bit stats seqcounts
  gtp: Initialize 64-bit per-cpu stats correctly
  netvsc: Initialize 64-bit stats seqcount
  ipvlan: Fix 64-bit statistics seqcount initialization

 drivers/net/ethernet/broadcom/b44.c                 | 1 +
 drivers/net/ethernet/intel/i40e/i40e_txrx.c         | 2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c   | 4 ++++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 drivers/net/gtp.c                                   | 2 +-
 drivers/net/hyperv/netvsc.c                         | 2 ++
 drivers/net/ipvlan/ipvlan_main.c                    | 2 +-
 7 files changed, 13 insertions(+), 2 deletions(-)

-- 
2.9.3
