From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 0/8] cxgb4: enable more tc flower offload matches and actions
Date: Wed, 18 Oct 2017 20:49:06 +0530
Message-ID: <cover.1508312071.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, kumaras@chelsio.com, ganeshgr@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:18875 "EHLO
        stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751161AbdJRPUa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:20:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enable more matches and actions for TC Flower
Offload support on Chelsio adapters.

Patch 1 enables matching on IP TOS.

Patch 2 enables matching on VLAN TCI.

Patch 3 adds support for action PASS.

Patch 4 adds support for ETH-DMAC rewrite via TC-PEDIT action. Also,
adds a check to assert that vlan/eth-dmac rewrite actions are valid
only in combination with action egress redirect.

Patch 5 introduces SMT ops for adding/removing entries from SMAC Table
in HW in preparation for patch 6.

Patch 6 adds support for ETH-SMAC rewrite via TC-PEDIT action.

Patch 7 introduces fw_filter2_wr to support L3/L4 header rewrites
in preparation for patch 8.

Patch 8 adds support for rewrite on L3/L4 header fields via TC-PEDIT
action. Supported fields for rewrite are:
IPv4 src/dst address, IPv6 src/dst address, TCP/UDP sport/dport.

Thanks,
Rahul

Kumar Sanghvi (8):
  cxgb4: add tc flower match support for TOS
  cxgb4: add tc flower match support for vlan
  cxgb4: add tc flower support for action PASS
  cxgb4: add tc flower support for ETH-DMAC rewrite
  cxgb4: introduce SMT ops to prepare for SMAC rewrite support
  cxgb4: add tc flower support for ETH-SMAC rewrite
  cxgb4: introduce fw_filter2_wr to prepare for L3/L4 rewrite support
  cxgb4: add tc flower support for L3/L4 rewrite

 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |  17 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_filter.c  | 126 ++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    |  22 ++
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.c   | 385 ++++++++++++++++++++-
 .../net/ethernet/chelsio/cxgb4/cxgb4_tc_flower.h   |  54 +++
 drivers/net/ethernet/chelsio/cxgb4/smt.c           | 247 +++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/smt.h           |  76 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h        |  44 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h        |  47 +++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h      |  75 +++-
 11 files changed, 1068 insertions(+), 27 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/smt.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/smt.h
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h

-- 
2.14.1
