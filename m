From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next v3 0/5] cxgb4: add support for offloading TC u32 filters
Date: Tue, 20 Sep 2016 17:13:05 +0530
Message-ID: <cover.1474029677.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:44132 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751539AbcITLok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 07:44:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches add support to offload TC u32 filters onto
Chelsio NICs.

Patch 1 moves current common filter code to separate files
in order to provide a common api for performing packet classification
and filtering in Chelsio NICs.

Patch 2 enables filters for normal NIC configuration and implements
common api for setting and deleting filters.

Patches 3-5 add support for TC u32 offload via ndo_setup_tc.

---
v3:

Based on review and suggestion from David Miller <davem@davemloft.net>
- Fixed all local variable declarations by placing them in longest line
  first and shortest line last order.

v2:

Based on review and suggestions from Jiri Pirko <jiri@resnulli.us>:
- Replaced macros S and U with appropriate static helper functions.
- Moved completion code for set and delete filters to respective
  functions cxgb4_set_filter() and cxgb4_del_filter().  Renamed the
  original functions to __cxgb4_set_filter() and __cxgb4_del_filter()
  in case synchronization is not required.
- Dropped debugfs patch.
- Merged code for inserting and deleting u32 filters into a single
  patch.
- Reworked and fixed bugs with traversing the actions list.
- Removed all unnecessary extra ().

Rahul Lakkireddy (5):
  cxgb4: move common filter code to separate file
  cxgb4: add common api support for configuring filters
  cxgb4: add parser to translate u32 filters to internal spec
  cxgb4: add support for offloading u32 filters
  cxgb4: add support for drop and redirect actions

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  29 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 721 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h  |  48 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 344 ++--------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c  | 483 ++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h  |  57 ++
 .../ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h    | 294 +++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |  26 +-
 9 files changed, 1720 insertions(+), 284 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_u32_parse.h

-- 
2.5.3
