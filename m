From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next v5 0/2] qed*: Add support for PTP
Date: Mon, 13 Feb 2017 15:46:24 +0200
Message-ID: <1486993586-16431-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
        <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:34685 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750943AbdBMNrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 08:47:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds required changes for qed/qede drivers for
supporting the IEEE Precision Time Protocol (PTP).

Dave,
Please consider applying this series to "net-next".

Thanks,
Yuval

Changes from previous versions:
-------------------------------
v5: Removed two divisions from the adjust-frequency loop.
    Resulting logic would use 8 divisions [instead of 24].

v4: Remove the loop iteration for value '0' in the qed_ptp_hw_adjfreq()
    implementation.

v3: Use div_s64 for 64-bit divisions as do_div gives error for signed
    types.
    Incorporated review comments from Richard Cochran.
      - Clear timestamp resgisters as soon as timestamp is read.
      - Use shift operation in the place of 'divide by 16'.

v2: Use do_div for 64-bit divisions.

Sudarsana Reddy Kalluru (2):
  qed: Add infrastructure for PTP support
  qede: Add driver support for PTP

 drivers/net/ethernet/qlogic/Kconfig             |   1 +
 drivers/net/ethernet/qlogic/qed/Makefile        |   2 +-
 drivers/net/ethernet/qlogic/qed/qed.h           |   2 +
 drivers/net/ethernet/qlogic/qed/qed_l2.c        |   5 +
 drivers/net/ethernet/qlogic/qed/qed_l2.h        |   1 +
 drivers/net/ethernet/qlogic/qed/qed_main.c      |  15 +
 drivers/net/ethernet/qlogic/qed/qed_ptp.c       | 317 ++++++++++++++
 drivers/net/ethernet/qlogic/qed/qed_ptp.h       |  47 +++
 drivers/net/ethernet/qlogic/qed/qed_reg_addr.h  |  31 ++
 drivers/net/ethernet/qlogic/qede/Makefile       |   2 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  10 +
 drivers/net/ethernet/qlogic/qede/qede_fp.c      |   5 +
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  39 ++
 drivers/net/ethernet/qlogic/qede/qede_ptp.c     | 536 ++++++++++++++++++++++++
 drivers/net/ethernet/qlogic/qede/qede_ptp.h     |  65 +++
 include/linux/qed/qed_eth_if.h                  |  22 +
 17 files changed, 1102 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qed/qed_ptp.h
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.c
 create mode 100644 drivers/net/ethernet/qlogic/qede/qede_ptp.h

-- 
1.9.3
