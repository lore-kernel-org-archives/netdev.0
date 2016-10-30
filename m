From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next 0/7] qed*: Patch series
Date: Sun, 30 Oct 2016 18:38:30 +0200
Message-ID: <1477845517-17228-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:40964 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756907AbcJ3Qio (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 12:38:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series does several things. The bigger changes:

 - Add new notification APIs [& Defaults] for various fields.
The series then utilizes some of those qed <-> qede APIs to bass WoL
support upon.

 - Change the resource allocation scheme to receive the values from
management firmware, instead of equally sharing resources between
functions [that might not need those]. That would, e.g., allow us to
configure additional filters to network interfaces in presence of
storage [PCI] functions from same adapter.

Dave,

Please consider applying this series to `net-next'.

Thanks,
Yuval

Sudarsana Kalluru (1):
  qed*: Management firmware - notifications and defaults

Tomer Tayar (1):
  qed: Learn resources from management firmware

Yuval Mintz (5):
  qed: Add nvram selftest
  qed*: Add support for WoL
  qede: Decouple ethtool caps from qed
  qed: Learn of RDMA capabilities per-device
  qed: Use VF-queue feature

 drivers/net/ethernet/qlogic/qed/qed.h           |  19 +-
 drivers/net/ethernet/qlogic/qed/qed_dev.c       | 382 +++++++++++++++++----
 drivers/net/ethernet/qlogic/qed/qed_hsi.h       | 120 ++++++-
 drivers/net/ethernet/qlogic/qed/qed_int.c       |  32 +-
 drivers/net/ethernet/qlogic/qed/qed_l2.c        |   2 +-
 drivers/net/ethernet/qlogic/qed/qed_main.c      | 105 ++++++
 drivers/net/ethernet/qlogic/qed/qed_mcp.c       | 433 +++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qed/qed_mcp.h       | 158 +++++++++
 drivers/net/ethernet/qlogic/qed/qed_selftest.c  | 101 ++++++
 drivers/net/ethernet/qlogic/qed/qed_selftest.h  |  10 +
 drivers/net/ethernet/qlogic/qed/qed_sriov.c     |  17 +-
 drivers/net/ethernet/qlogic/qede/qede.h         |   2 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c |  54 ++-
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  17 +
 include/linux/qed/qed_eth_if.h                  |   2 +-
 include/linux/qed/qed_if.h                      |  47 +++
 16 files changed, 1404 insertions(+), 97 deletions(-)

-- 
1.9.3
