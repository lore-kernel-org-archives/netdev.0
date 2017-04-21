From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 0/5] nfp: DMA flags, adjust head and fixes
Date: Fri, 21 Apr 2017 12:23:05 -0700
Message-ID: <20170421192310.193875-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:34725 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1424785AbdDUTXV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:23:21 -0400
Received: by mail-oi0-f45.google.com with SMTP id x184so109562203oia.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:23:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series takes advantage of Alex's DMA_ATTR_SKIP_CPU_SYNC to make 
XDP packet modifications "correct" from DMA API point of view.  It 
also allows us to parse the metadata before we run XDP at no additional
DMA sync cost.  That way we can get rid of the metadata memcpy, and 
remove the last upstream user of bpf_prog->xdp_adjust_head.

David's patch adds a way to read capabilities from the management
firmware.

There are also two net-next fixes.  Patch 4 which fixes what seems to
be a result of a botched rebase on my part.  Patch 5 corrects locking
when state of ethernet ports is being refreshed.

---
v2: sync rx buffers before giving them to the card (Alex)

David Brunecz (1):
  nfp: add NSP routine to get static information

Jakub Kicinski (4):
  nfp: make use of the DMA_ATTR_SKIP_CPU_SYNC flag
  nfp: parse metadata prepend before XDP runs
  nfp: fix free list buffer size reporting
  nfp: remove the refresh of all ports optimization

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |   7 ++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   9 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 126 ++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  13 ++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  67 +++++++----
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   1 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |   7 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |  24 ++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c  |  89 +++++++++++++++
 10 files changed, 266 insertions(+), 78 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c

-- 
2.11.0
