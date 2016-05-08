From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: thunderx: avoid exposing kernel stack
Date: Mon,  9 May 2016 00:46:18 +0200
Message-ID: <1462747578-6147-1-git-send-email-xypron.glpk@gmx.de>
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Sunil Goutham <sgoutham@cavium.com>,
	Robert Richter <rric@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.17.22]:54787 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750854AbcEHWrB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 May 2016 18:47:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reserved fields should be set to zero to avoid exposing
bits from the kernel stack.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/cavium/thunder/nicvf_queues.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
index 8acd7c0..0ff8e60 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_queues.c
@@ -533,6 +533,7 @@ static void nicvf_rcv_queue_config(struct nicvf *nic, struct queue_set *qs,
 		nicvf_config_vlan_stripping(nic, nic->netdev->features);
 
 	/* Enable Receive queue */
+	memset(&rq_cfg, 0, sizeof(struct rq_cfg));
 	rq_cfg.ena = 1;
 	rq_cfg.tcp_ena = 0;
 	nicvf_queue_reg_write(nic, NIC_QSET_RQ_0_7_CFG, qidx, *(u64 *)&rq_cfg);
@@ -565,6 +566,7 @@ void nicvf_cmp_queue_config(struct nicvf *nic, struct queue_set *qs,
 			      qidx, (u64)(cq->dmem.phys_base));
 
 	/* Enable Completion queue */
+	memset(&cq_cfg, 0, sizeof(struct cq_cfg));
 	cq_cfg.ena = 1;
 	cq_cfg.reset = 0;
 	cq_cfg.caching = 0;
@@ -613,6 +615,7 @@ static void nicvf_snd_queue_config(struct nicvf *nic, struct queue_set *qs,
 			      qidx, (u64)(sq->dmem.phys_base));
 
 	/* Enable send queue  & set queue size */
+	memset(&sq_cfg, 0, sizeof(struct sq_cfg));
 	sq_cfg.ena = 1;
 	sq_cfg.reset = 0;
 	sq_cfg.ldwb = 0;
@@ -649,6 +652,7 @@ static void nicvf_rbdr_config(struct nicvf *nic, struct queue_set *qs,
 
 	/* Enable RBDR  & set queue size */
 	/* Buffer size should be in multiples of 128 bytes */
+	memset(&rbdr_cfg, 0, sizeof(struct rbdr_cfg));
 	rbdr_cfg.ena = 1;
 	rbdr_cfg.reset = 0;
 	rbdr_cfg.ldwb = 0;
-- 
2.1.4
