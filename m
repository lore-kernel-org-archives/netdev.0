From: Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
Subject: [PATCH net-next 0/3] TX max rate limiting for Chelsio T4/T5 adapters
Date: Mon, 22 Aug 2016 16:29:05 +0530
Message-ID: <cover.1471848004.git.rahul.lakkireddy@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
        nirranjan@chelsio.com, indranil@chelsio.com,
        Rahul Lakkireddy <rahul.lakkireddy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:37228 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752834AbcHVLAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 Aug 2016 07:00:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series of patches implement tx max rate limiting per queue on
Chelsio T4/T5 hardware.  This is achieved by first creating a tx
scheduling class with the specified max rate.  The queue is then
bound to the newly created class.  If a scheduling class with similar
max rate already exists, then the queue is bound to the matching class.

Patch 1 adds support for setting tx scheduling classes.
Patch 2 adds support to bind/unbind queues to/from the scheduling classes.
Patch 3 implements the set_tx_maxrate NDO.

Rahul Lakkireddy (3):
  cxgb4: add support for tx traffic scheduling classes
  cxgb4: add support for per queue tx scheduling
  cxgb4: add support for tx max rate limiting

 drivers/net/ethernet/chelsio/cxgb4/Makefile     |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  56 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 102 ++++-
 drivers/net/ethernet/chelsio/cxgb4/sched.c      | 556 ++++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/sched.h      | 110 +++++
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  31 +-
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |  38 +-
 7 files changed, 890 insertions(+), 5 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/sched.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/sched.h

-- 
2.5.3
