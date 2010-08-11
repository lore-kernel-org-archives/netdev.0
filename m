From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 6/7] enic: Check if rq/wq buf not NULL before
	freeing them
Date: Tue, 10 Aug 2010 21:55:20 -0700
Message-ID: <20100811045520.3877.54012.stgit@savbu-pc100.cisco.com>
References: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:13281 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932376Ab0HKEzV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:55:21 -0400
In-Reply-To: <20100811045436.3877.51650.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
---
 drivers/net/enic/vnic_rq.c |    6 ++++--
 drivers/net/enic/vnic_wq.c |    6 ++++--
 2 files changed, 8 insertions(+), 4 deletions(-)


diff --git a/drivers/net/enic/vnic_rq.c b/drivers/net/enic/vnic_rq.c
index dbb2aca..b236d7c 100644
--- a/drivers/net/enic/vnic_rq.c
+++ b/drivers/net/enic/vnic_rq.c
@@ -77,8 +77,10 @@ void vnic_rq_free(struct vnic_rq *rq)
 	vnic_dev_free_desc_ring(vdev, &rq->ring);
 
 	for (i = 0; i < VNIC_RQ_BUF_BLKS_MAX; i++) {
-		kfree(rq->bufs[i]);
-		rq->bufs[i] = NULL;
+		if (rq->bufs[i]) {
+			kfree(rq->bufs[i]);
+			rq->bufs[i] = NULL;
+		}
 	}
 
 	rq->ctrl = NULL;
diff --git a/drivers/net/enic/vnic_wq.c b/drivers/net/enic/vnic_wq.c
index 122e33b..4b2a6c6 100644
--- a/drivers/net/enic/vnic_wq.c
+++ b/drivers/net/enic/vnic_wq.c
@@ -77,8 +77,10 @@ void vnic_wq_free(struct vnic_wq *wq)
 	vnic_dev_free_desc_ring(vdev, &wq->ring);
 
 	for (i = 0; i < VNIC_WQ_BUF_BLKS_MAX; i++) {
-		kfree(wq->bufs[i]);
-		wq->bufs[i] = NULL;
+		if (wq->bufs[i]) {
+			kfree(wq->bufs[i]);
+			wq->bufs[i] = NULL;
+		}
 	}
 
 	wq->ctrl = NULL;

