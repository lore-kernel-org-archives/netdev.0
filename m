From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
Subject: [PATCH net-next 0/5] qed*: PTP enhancements.
Date: Wed, 26 Apr 2017 09:00:48 -0700
Message-ID: <20170426160053.8356-1-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <richardcochran@gmail.com>, <netdev@vger.kernel.org>,
        <Yuval.Mintz@cavium.com>,
        Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0076.outbound.protection.outlook.com ([104.47.42.76]:65056
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753296AbdDZQBT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 12:01:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>

The patch series contains set of enhancements for qed/qede ptp
implementation.
Patches (1)-(3) adds resource locking implementation to allow 
PTP functionality only on the first detected ethernet PF of the port.
The change is required as the adapter currently supports only one
instance of the PTP client on a given port.
Patch (4) removes the un-needed header file.
Patch (5) moves the ptt-lock get/release logic to the ptp specific
code.

Please consider applying this series to "net-next" branch.

Sudarsana Reddy Kalluru (5):
  qed: Add support for MFW resource locking.
  qed: Add support for PTP resource locking.
  qede: Add support for PTP resource locking.
  qed: Remove the un-needed ptp header file.
  qed: Acquire/release ptt_ptp lock when enabling/disabling PTP.

 drivers/net/ethernet/qlogic/qed/qed.h        |   8 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c    |  26 +++--
 drivers/net/ethernet/qlogic/qed/qed_main.c   |  12 ---
 drivers/net/ethernet/qlogic/qed/qed_mcp.c    |  30 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.h    |  22 +++-
 drivers/net/ethernet/qlogic/qed/qed_ptp.c    | 103 +++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_ptp.h    |  47 ---------
 drivers/net/ethernet/qlogic/qede/qede_main.c |  18 +---
 drivers/net/ethernet/qlogic/qede/qede_ptp.c  | 150 +++++++++++++--------------
 drivers/net/ethernet/qlogic/qede/qede_ptp.h  |   6 +-
 10 files changed, 249 insertions(+), 173 deletions(-)
 delete mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.h

-- 
1.8.3.1
