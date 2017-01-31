From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 00/10] bnxt_en: Add XDP support.
Date: Mon, 30 Jan 2017 20:49:25 -0500
Message-ID: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:34058 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdAaBur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:50:47 -0500
Received: by mail-pf0-f173.google.com with SMTP id e4so96191986pfg.1
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:49:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first 8 patches refactor the code (rx/tx code paths and ring logic)
and add the basic infrastructure to support XDP.  The 9th patch adds
basic ndo_xdp to support XDP_DROP and XDP_PASS only.  The 10th patch
completes the series with XDP_TX.

Michael Chan (10):
  bnxt_en: Refactor rx SKB function.
  bnxt_en: Add bp->rx_dir field for rx buffer DMA direction.
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
 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 347 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  56 +++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  53 ++--
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     | 231 ++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h     |  30 ++
 7 files changed, 599 insertions(+), 128 deletions(-)
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
 create mode 100644 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h

-- 
1.8.3.1
