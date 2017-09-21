From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next v2 0/4] cxgb4: add support to offload tc flower
Date: Thu, 21 Sep 2017 23:41:12 +0530
Message-ID: <cover.1506015856.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:64353 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdIUSME (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:12:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches add support to offload tc flower onto Chelsio
NICs.

Patch 1 adds basic skeleton to prepare for offloading tc flower flows.

Patch 2 adds support to add/remove flows for offload.  Flows can have
accompanying masks.  Following match and action are currently supported
for offload:
Match:  ether-protocol, IPv4/IPv6 addresses, L4 ports (TCP/UDP)
Action: drop, redirect to another port on the device.

Patch 3 adds support to offload tc-flower flows having
vlan actions: pop, push, and modify.

Patch 4 adds support to fetch stats for the offloaded tc flower flows
from hardware.

Support for offloading more match and action types are to be followed
in subsequent series.

Thanks,
Rahul

---
v2:
- Setting ftid to -1 not required after bitmap_find_free_region
  in cxgb4_get_free_ftid.
- Direct return can be used as jumping to error path is not needed
  if flower entry allocation failed in cxgb4_tc_flower_replace.
  Same applies if flower entry not found in cxgb4_tc_flower_destroy.
- Also, removed an extra return from cxgb4_tc_flower_destroy.
- Avoid wrapping line for netdev_err message. Also, use
  consistent error message string.

Kumar Sanghvi (4):
  cxgb4: add tc flower offload skeleton
  cxgb4: add basic tc flower offload support
  cxgb4: add support to offload action vlan
  cxgb4: fetch stats for offloaded tc flower flows

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 100 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  25 ++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 452 +++++++++++++++++++++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |  66 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   3 +
 7 files changed, 653 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h

-- 
2.14.1
