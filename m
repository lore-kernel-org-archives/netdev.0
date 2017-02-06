From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 00/12] bnxt_en: Add XDP support.
Date: Mon,  6 Feb 2017 16:55:31 -0500
Message-ID: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35420 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751365AbdBFVz7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:55:59 -0500
Received: by mail-pg0-f51.google.com with SMTP id 194so31832973pgd.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:55:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 10 patches refactor the code (rx/tx code paths and ring logic)
and add the basic infrastructure to support XDP.  The 11th patch adds
basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 12th patch
completes the series with XDP_TX.

Thanks to Andy Gospodarek for testing and uncovering some bugs.

v3: Removed Kconfig option.
    Pass modified offset and length to stack for XDP_PASS.
    Improved buffer recycling scheme for XDP_TX.
    Other minor fixes.

v2: Addressed review comments from Alexei Starovoitov, Jakub Kicinski,
and David Miller:
	- Added missing dma syncs.
	- Added XDP headroom support.
	- Added tracing in exception path.
	- Clarified a parameter change.

Michael Chan (12):
  bnxt_en: Refactor rx SKB function.
  bnxt_en: Don't use DEFINE_DMA_UNMAP_ADDR to store DMA address in RX
    path.
  bnxt_en: Add bp->rx_dir field for rx buffer DMA direction.
  bnxt_en: Parameterize RX buffer offsets.
  bnxt_en: Add RX page mode support.
  bnxt_en: Use event bit map in RX path.
  bnxt_en: Centralize logic to reserve rings.
  bnxt_en: Add tx ring mapping logic.
  bnxt_en: Add a set of TX rings to support XDP.
  bnxt_en: Refactor tx completion path.
  bnxt_en: Add basic XDP support.
  bnxt_en: Add support for XDP_TX action.

 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 406 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  62 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  53 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     | 240 +++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h     |  19 +
 6 files changed, 629 insertions(+), 153 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h

-- 
1.8.3.1
