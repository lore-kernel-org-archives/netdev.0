From: Steve Wise <swise@opengridcomputing.com>
Subject: [PATCH 2.6.24] RDMA/cxgb3: Set the max_qp_init_rd_atom attribute.
Date: Fri, 09 Nov 2007 09:21:58 -0600
Message-ID: <20071109152158.21493.24110.stgit@dell3.ogc.int>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]:33201 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753329AbXKIPV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Nov 2007 10:21:59 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


RDMA/cxgb3: Set the max_qp_init_rd_atom attribute.

Attribute max_qp_init_rd_atom is not getting set.  Version 1.0.4 of
librdmacm now validates the user's requested initiator and responder
resources vs the max supported by the device.  Since iw_cxgb3 wasn't
setting this attribute (and it defaulted to 0), all rdma_connect()s fail
if there are initiator resources requested by the app.

Signed-off-by: Steve Wise <swise@opengridcomputing.com>
---

 drivers/infiniband/hw/cxgb3/iwch_provider.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/infiniband/hw/cxgb3/iwch_provider.c b/drivers/infiniband/hw/cxgb3/iwch_provider.c
index f0c7775..b5436ca 100644
--- a/drivers/infiniband/hw/cxgb3/iwch_provider.c
+++ b/drivers/infiniband/hw/cxgb3/iwch_provider.c
@@ -1000,6 +1000,7 @@ static int iwch_query_device(struct ib_device *ibdev,
 	props->max_sge = dev->attr.max_sge_per_wr;
 	props->max_sge_rd = 1;
 	props->max_qp_rd_atom = dev->attr.max_rdma_reads_per_qp;
+	props->max_qp_init_rd_atom = dev->attr.max_rdma_reads_per_qp;
 	props->max_cq = dev->attr.max_cqs;
 	props->max_cqe = dev->attr.max_cqes_per_cq;
 	props->max_mr = dev->attr.max_mem_regs;
