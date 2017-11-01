From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 0/7] cxgb4: add hash-filter support to tc-flower offload
Date: Wed,  1 Nov 2017 08:52:58 +0530
Message-ID: <cover.1509505160.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:1768 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdKADYn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:24:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches add support to create hash-filters; a.k.a
exact-match filters, to tc-flower offload.  T6 supports creating
~500K hash-filters in hw and can theoretically be expanded up to
~1 million.

Patch 1 fetches and saves the configured hw filter tuple field shifts
and filter mask.

Patch 2 initializes the driver to use hash-filter configuration.

Patch 3 adds support to create hash filters in hw.

Patch 4 adds support to delete hash filters in hw.

Patch 5 adds support to retrieve filter stats for hash filters.

Patch 6 converts the flower table to use rhashtable instead of
static hlist.

Patch 7 finally adds support to create hash filters via tc-flower
offload.

Thanks,
Rahul

Kumar Sanghvi (7):
  cxgb4: save additional filter tuple field shifts in tp_params
  cxgb4: initialize hash-filter configuration
  cxgb4: add support to create hash filters
  cxgb4: add support to delete hash filter
  cxgb4: add support to retrieve stats for hash filters
  cxgb4: convert flower table to use rhashtable
  cxgb4: add support to create hash-filters via tc-flower offload

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  32 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 928 +++++++++++++++++++--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h  |   8 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  26 +-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 126 ++-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   6 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         |  18 +-
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |   5 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h       |  17 +
 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h        |  22 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |   1 +
 13 files changed, 1082 insertions(+), 115 deletions(-)

-- 
2.14.1
