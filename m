From: Vipul Pandya <vipul@chelsio.com>
Subject: [PATCH 00/10] Doorbell drop recovery for T4 iWARP
Date: Wed, 19 Oct 2011 22:40:54 +0530
Message-ID: <1319044264-779-1-git-send-email-vipul@chelsio.com>
Cc: roland@purestorage.com, davem@davemloft.net, divy@chelsio.com,
	dm@chelsio.com, kumaras@chelsio.com, swise@opengridcomputing.com,
	Vipul Pandya <vipul@chelsio.com>
To: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:10756 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756842Ab1JSRNN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 13:13:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-series implements doorbell drop recovery for T4 iWARP driver.

In the event where DBs are dropped application can get stalled for one or more
reasons. So, we recover RDMA and LLD queues in such an event.
We also take care for handling DB overflow events.

The patch-series also has some bug fixes, adds RDMA debugfs stats and removes
kfifo usage for ID mangement.

The patch-series is based on linux-next, and involves changes on
drivers/net/ethernet/chelsio/cxgb4 and drivers/infiniband/hw/cxgb4.

The changes on drivers/infiniband/hw/cxgb4 are dependent on the changes of
drivers/net/ethernet/chelsio/cxgb4 for the T4-iWARP driver to build correctly.
So, we request to merge the entire patch-series through one tree - either
through Roland's tree, or through Dave Miller's tree.

Both linux-rdma and netdev are included in this post for review.

Vipul Pandya (10):
  cxgb4: Detect DB FULL events and notify RDMA ULD.
  cxgb4: DB Drop Recovery for RDMA and LLD queues.
  cxgb4: DB Drop Recovery for RDMA and LLD queues.
  RDMA/cxgb4: Add debugfs rdma memory stats
  RDMA/cxgb4: Add DB Overflow Avoidance.
  RDMA/cxgb4: disable interrupts in c4iw_ev_dispatch().
  RDMA/cxgb4: DB Drop Recovery for RDMA and LLD queues.
  RDMA/cxgb4: Use vmalloc for debugfs qp dump. Allows dumping thousands
    of qps.
  RDMA/cxgb4: remove kfifo usage
  RDMA/cxgb4: Add query_qp support in driver to query the qp state
    before flushing.

 drivers/infiniband/hw/cxgb4/Makefile            |    2 +-
 drivers/infiniband/hw/cxgb4/cm.c                |   23 ++-
 drivers/infiniband/hw/cxgb4/device.c            |  339 ++++++++++++++++++++++-
 drivers/infiniband/hw/cxgb4/ev.c                |    8 +-
 drivers/infiniband/hw/cxgb4/id_table.c          |  112 ++++++++
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |  134 ++++++++--
 drivers/infiniband/hw/cxgb4/mem.c               |   21 +-
 drivers/infiniband/hw/cxgb4/provider.c          |   19 +-
 drivers/infiniband/hw/cxgb4/qp.c                |  105 +++++++-
 drivers/infiniband/hw/cxgb4/resource.c          |  180 +++++-------
 drivers/infiniband/hw/cxgb4/t4.h                |   24 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |   11 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  235 +++++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |   11 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |   22 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |   62 ++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |   53 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |   28 ++
 18 files changed, 1218 insertions(+), 171 deletions(-)
 create mode 100644 drivers/infiniband/hw/cxgb4/id_table.c
