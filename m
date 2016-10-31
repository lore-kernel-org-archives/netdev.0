From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 00/14] cleanups and RX path rewrite
Date: Mon, 31 Oct 2016 20:43:08 +0000
Message-ID: <1477946602-19644-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:35209 "EHLO
        mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S946718AbcJaUn5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 16:43:57 -0400
Received: by mail-wm0-f52.google.com with SMTP id a197so43030660wmd.0
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 13:43:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series lays groundwork for upcoming XDP support by updating
the RX path not to pre-allocate sk_buffs.  I start with few
cleanups, removal of NFP3200-related code being the most significant.
Patch 7 moves to alloc_frag() and build_skb() APIs.  Again, a number
of small cleanups follow.  The set ends with adding support for
different number of RX and TX rings.

Jakub Kicinski (14):
  nfp: simplify nfp_net_poll()
  nfp: remove support for nfp3200
  nfp: remove unnecessary call to ether_setup()
  nfp: remove inline attributes and dead code
  nfp: centralize the buffer size calculation
  nfp: add buffer drop/recycle helper for RX
  nfp: use alloc_frag() and build_skb()
  nfp: add separate buffer allocation function for napi
  nfp: use AND instead of modulo to get ring indexes
  nfp: create separate define for max number of vectors
  nfp: use unsigned int for vector/ring counts
  nfp: remove nfp_net_irqs_wanted()
  nfp: replace num_irqs with max_r_vecs
  nfp: bring back support for different ring counts

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  43 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 471 ++++++++++-----------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  13 +-
 .../net/ethernet/netronome/nfp/nfp_net_debugfs.c   |   9 +-
 .../net/ethernet/netronome/nfp/nfp_netvf_main.c    |  45 +-
 5 files changed, 263 insertions(+), 318 deletions(-)

-- 
1.9.1
