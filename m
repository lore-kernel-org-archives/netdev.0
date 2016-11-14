From: Michael Weiser <michael.weiser@gmx.de>
Subject: [PATCH 0/3 v5] Fixes for running a big-endian kernel on Cubieboard2
Date: Mon, 14 Nov 2016 18:58:04 +0100
Message-ID: <20161114175807.4747-1-michael.weiser@gmx.de>
Cc: Michael Weiser <michael.weiser@gmx.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from heinz.dinsnail.net ([85.214.155.104]:46516 "EHLO
        heinz.dinsnail.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753273AbcKNTAO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2016 14:00:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the following patches are what remains to be fixed in order to allow running a
big-endian kernel on the Cubieboard2.

The first patch fixes up endianness problems with DMA descriptors in
the stmmac driver preventing it from working correctly when runnning a
big-endian kernel.

The second patch adds the ability to enable diagnostic messages in the
sun4i-emac driver which were instrumental in finding the problem fixed
by patch number three: Endianness confusion caused by dual-purpose I/O
register usage in sun4i-emac.

All of these have been tested successfully on a Cubieboard2 DualCard.

Changes since v4:
- Rebased to current master
- Removed already applied patches to sunxi-mmc and sunxi-Kconfig

Changes since v3:
- Rebased sunxi-mmc patch against Ulf's mmc.git/next
- Changed Kconfig change to enable big-endian support only for sun7i
  devices

Changes since v2:
- Fixed typo in stmmac patch causing a build failure
- Added sun4i-emac patches

Changes since v1:
- Fixed checkpatch niggles
- Added respective Cc:s

Regards,
Michael

Michael Weiser (3):
  net: ethernet: stmmac: change dma descriptors to __le32
  net: ethernet: sun4i-emac: Allow to enable netif messages
  net: ethernet: sun4i-emac: Read rxhdr in CPU byte-order

 drivers/net/ethernet/allwinner/sun4i-emac.c        | 25 ++++++++-
 drivers/net/ethernet/stmicro/stmmac/chain_mode.c   | 55 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/descs.h        | 20 ++++----
 drivers/net/ethernet/stmicro/stmmac/descs_com.h    | 48 +++++++++--------
 drivers/net/ethernet/stmicro/stmmac/dwmac4_descs.c | 60 +++++++++++-----------
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c     | 55 ++++++++++----------
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    | 48 ++++++++---------
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c    | 39 +++++++-------
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  | 51 +++++++++---------
 9 files changed, 218 insertions(+), 183 deletions(-)

-- 
2.9.3 (Apple Git-75)
