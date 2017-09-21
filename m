From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 0/4] cxgb4: add support to offload tc flower
Date: Thu, 21 Sep 2017 13:03:33 +0530
Message-ID: <cover.1505977744.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:47028 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751588AbdIUHeb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 03:34:31 -0400
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

Kumar Sanghvi (4):
  cxgb4: add tc flower offload skeleton
  cxgb4: add basic tc flower offload support
  cxgb4: add support to offload action vlan
  cxgb4: fetch stats for offloaded tc flower flows

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   4 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   4 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 102 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  25 ++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 458 +++++++++++++++++++++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |  66 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   3 +
 7 files changed, 661 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h

-- 
2.14.1
