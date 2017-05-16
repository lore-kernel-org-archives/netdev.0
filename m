From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 0/9] nfp: LSO, checksum and XDP datapath updates
Date: Mon, 15 May 2017 17:55:14 -0700
Message-ID: <20170516005523.26124-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36774 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750896AbdEPA4S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 20:56:18 -0400
Received: by mail-pg0-f52.google.com with SMTP id x64so48476922pgd.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 17:56:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This series introduces a number of refinements to standard features
like LSO and checksum offload.  Three major features are support for
CHECKSUM_COMPLETE, refinement of TSO handling and another small speed
up for XDP TX.  This series also switches from depending on some 
app FW<>driver ABI versions to heavier use of capabilities.


Edwin Peer (3):
  nfp: rename l4_offset in struct nfp_net_tx_desc to lso_hdrlen
  nfp: support LSO2 capability
  nfp: version independent support for chained RSS metadata

Jakub Kicinski (6):
  nfp: don't enable TSO on the device when disabled
  nfp: don't assume RSS and IRQ moderation are always enabled
  nfp: add CHECKSUM_COMPLETE support
  nfp: complete the XDP TX ring only when it's full
  nfp: add a helper for wrapping descriptor index
  nfp: eliminate an if statement in calculation of completed frames

 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  19 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 179 +++++++++++++--------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h  |  18 ++-
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  12 +-
 4 files changed, 149 insertions(+), 79 deletions(-)

-- 
2.11.0
