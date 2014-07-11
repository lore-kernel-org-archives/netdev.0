From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH 0/4] Misc. fixes for iw_cxgb4
Date: Fri, 11 Jul 2014 20:44:18 +0530
Message-ID: <1405091662-5270-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, roland@purestorage.com,
	swise@opengridcomputing.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org, linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:34041
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752406AbaGKPIk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 11:08:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support to determine ingress padding boundary at runtime.
Advertise a larger max read queue depth for qps, and gather the resource limits
from fw and use them to avoid exhausting all the resources and display TPTE on
errors and add support for work request logging feature.

The patches series is created against 'net-next' tree.
And includes patches on cxgb4 and iw_cxgb4 driver.

Since this patch-series contains changes which are dependent on commit id
fc5ab02 ("cxgb4: Replaced the backdoor mechanism to access the HW memory with
PCIe Window method") of net-next tree, we would like to request this patch
series to get merged via David Miller's 'net-next' tree.

We have included all the maintainers of respective drivers. Kindly review the
change and let us know in case of any review comments.

Hariprasad Shenai (4):
  iw_cxgb4: Detect Ing. Padding Boundary at run-time
  cxgb4/iw_cxgb4: use firmware ord/ird resource limits
  cxgb4/iw_cxgb4: display TPTE on errors
  cxgb4/iw_cxgb4: work request logging feature

 drivers/infiniband/hw/cxgb4/cm.c                |   80 +++++++---
 drivers/infiniband/hw/cxgb4/cq.c                |    8 +-
 drivers/infiniband/hw/cxgb4/device.c            |  187 ++++++++++++++++++++++-
 drivers/infiniband/hw/cxgb4/ev.c                |   53 ++++++-
 drivers/infiniband/hw/cxgb4/iw_cxgb4.h          |   38 +++++-
 drivers/infiniband/hw/cxgb4/provider.c          |   10 +-
 drivers/infiniband/hw/cxgb4/qp.c                |   75 ++++++++--
 drivers/infiniband/hw/cxgb4/t4.h                |   16 +--
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |    3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |  100 ++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |    7 +
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    6 +
 drivers/net/ethernet/chelsio/cxgb4/t4fw_api.h   |    2 +
 13 files changed, 524 insertions(+), 61 deletions(-)
