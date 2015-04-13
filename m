From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next v2 0/4] cxgb4: add FCoE DDP and RSS
Date: Mon, 13 Apr 2015 19:34:22 +0530
Message-ID: <cover.1428930614.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21515 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754138AbbDMOEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:04:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables RSS for FCoE frames and adds
DDP support for FCoE target.

v2: add patch 1/4 to fix build error "redefinition of 
    struct ulptx_idata".

Varun Prakash (4):
  cxgb4/iw_cxgb4/cxgb4i: remove duplicate definitions
  cxgb4: add structure and macro definitions for FCoE DDP
  cxgb4: add DDP support for FCoE target
  cxgb4: enable RSS for FCoE frames

 drivers/infiniband/hw/cxgb4/t4fw_ri_api.h       |    9 -
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.c |  600 +++++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_fcoe.h |   54 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |   47 ++-
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 +
 drivers/net/ethernet/chelsio/cxgb4/sge.c        |  328 ++++++++++++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |    1 +
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.h      |   29 ++
 drivers/net/ethernet/chelsio/cxgb4/t4_msg.h     |   64 +++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    8 +
 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h     |   90 ++++
 drivers/net/ethernet/chelsio/cxgb4/t4_values.h  |    3 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    9 +
 drivers/scsi/cxgbi/cxgb4i/cxgb4i.h              |    5 -
 15 files changed, 1234 insertions(+), 21 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/t4_tcb.h
