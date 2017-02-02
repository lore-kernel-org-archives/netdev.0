From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 00/12] bnxt_en: Add XDP support.
Date: Thu,  2 Feb 2017 11:55:28 -0500
Message-ID: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f177.google.com ([209.85.192.177]:32994 "EHLO
        mail-pf0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751465AbdBBQz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:55:56 -0500
Received: by mail-pf0-f177.google.com with SMTP id y143so6518067pfb.0
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:55:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 10 patches refactor the code (rx/tx code paths and ring logic)
and add the basic infrastructure to support XDP.  The 11th patch adds
basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 12th patch
completes the series with XDP_TX.

Thanks to Andy Gospodarek for testing and uncovering some bugs.

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

 drivers/net/ethernet/broadcom/Kconfig             |   8 +
 drivers/net/ethernet/broadcom/bnxt/Makefile       |   2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 395 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  62 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  53 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     | 247 ++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h     |  29 ++
 7 files changed, 646 insertions(+), 150 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h

-- 
1.8.3.1
