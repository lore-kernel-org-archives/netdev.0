From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 0/3] bnxt_en: Bug fixes.
Date: Tue, 11 Jul 2017 13:05:33 -0400
Message-ID: <1499792736-28697-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f179.google.com ([209.85.161.179]:35798 "EHLO
        mail-yw0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbdGKRFs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 13:05:48 -0400
Received: by mail-yw0-f179.google.com with SMTP id v193so4325945ywg.2
        for <netdev@vger.kernel.org>; Tue, 11 Jul 2017 10:05:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3 bug fixes in this series.  Fix a crash in bnxt_get_stats64() that can
happen if the device is closing and freeing the statistics block at the
same time.  The 2nd one fixes ethtool -L failing when changing from
combined to non-combined mode or vice versa.  The last one fixes SRIOV
failure on big-endian systems because we were setting a bitmap wrong in
a firmware message.

Michael Chan (3):
  bnxt_en: Fix race conditions in .ndo_get_stats64().
  bnxt_en: Fix bug in ethtool -L.
  bnxt_en: Fix SRIOV on big-endian architecture.

 drivers/net/ethernet/broadcom/bnxt/bnxt.c         | 42 ++++++++++++++++-------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h         |  4 ++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c |  3 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c     |  2 +-
 4 files changed, 35 insertions(+), 16 deletions(-)

-- 
1.8.3.1
