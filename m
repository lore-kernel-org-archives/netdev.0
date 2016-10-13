From: Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
Subject: [PATCH net 0/3] qed: Fix dependencies and warnings series
Date: Thu, 13 Oct 2016 22:57:00 +0300
Message-ID: <1476388623-31032-1-git-send-email-Yuval.Mintz@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <arnd@arndb.de>, <dan.carpenter@oracle.com>,
        Yuval Mintz <Yuval.Mintz@caviumnetworks.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49758 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1756820AbcJMT5z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2016 15:57:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

The first patch in this series follows Dan Carpenter's reports about
Smatch warnings for recent qed additions and fixes those.

The second patch is the most significant one [and the reason this is
ntended for 'net'] - it's based on Arnd Bermann's suggestion for fixing
compilation issues that were introduced with the roce addition as a result
of certain combinations of qed, qede and qedr Kconfig options.

The third follows the discussion with Arnd and clears a lot of the warnings
that arise when compiling the drivers with "C=1".

Please consider applying this series to 'net'.

Thanks,
Yuval

Yuval Mintz (3):
  qed: Fix static checker warning.
  qed*: Fix Kconfig dependencies with INFINIBAND_QEDR
  qed: Additional work toward cleaning C=1

 drivers/net/ethernet/qlogic/Kconfig         |   4 +
 drivers/net/ethernet/qlogic/qed/Makefile    |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_cxt.c   |  15 +-
 drivers/net/ethernet/qlogic/qed/qed_debug.c |  53 +++----
 drivers/net/ethernet/qlogic/qed/qed_dev.c   |  19 +--
 drivers/net/ethernet/qlogic/qed/qed_ll2.c   |  16 +--
 drivers/net/ethernet/qlogic/qed/qed_ll2.h   |  20 ---
 drivers/net/ethernet/qlogic/qed/qed_main.c  |  30 ++--
 drivers/net/ethernet/qlogic/qed/qed_roce.c  | 216 ++++++++--------------------
 drivers/net/ethernet/qlogic/qed/qed_roce.h  |  95 ++++++------
 drivers/net/ethernet/qlogic/qed/qed_sp.h    |   1 -
 drivers/net/ethernet/qlogic/qed/qed_spq.c   |   4 -
 drivers/net/ethernet/qlogic/qede/Makefile   |   2 +-
 include/linux/qed/qede_roce.h               |   2 +-
 14 files changed, 179 insertions(+), 300 deletions(-)

-- 
1.9.3
