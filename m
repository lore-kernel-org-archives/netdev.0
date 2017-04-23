From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v3 0/5] nfp: DMA flags, adjust head and fixes
Date: Sat, 22 Apr 2017 20:17:51 -0700
Message-ID: <20170423031756.94429-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:32859 "EHLO
        mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932150AbdDWDTP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 22 Apr 2017 23:19:15 -0400
Received: by mail-io0-f175.google.com with SMTP id k87so154148914ioi.0
        for <netdev@vger.kernel.org>; Sat, 22 Apr 2017 20:19:15 -0700 (PDT)
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
v3: move the sync from alloc func to the actual give to hw func
v2: sync rx buffers before giving them to the card (Alex)


David Brunecz (1):
  nfp: add NSP routine to get static information

Jakub Kicinski (4):
  nfp: make use of the DMA_ATTR_SKIP_CPU_SYNC attr
  nfp: parse metadata prepend before XDP runs
  nfp: fix free list buffer size reporting
  nfp: remove the refresh of all ports optimization

 drivers/net/ethernet/netronome/nfp/Makefile        |   1 +
 drivers/net/ethernet/netronome/nfp/nfp_main.c      |   7 ++
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |   9 +-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 125 ++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  13 ++-
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  |  67 +++++++----
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp.h   |   1 +
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.c   |   7 ++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nsp.h   |  24 ++++
 .../ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c  |  89 +++++++++++++++
 10 files changed, 265 insertions(+), 78 deletions(-)
 create mode 100644 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nsp_cmds.c

-- 
2.11.0
