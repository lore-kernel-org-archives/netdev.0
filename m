From: Parvi Kaustubhi <pkaustub@cisco.com>
Subject: [PATCH net-next 1/2] enic: reset fetch index
Date: Thu, 26 Oct 2017 09:30:04 -0700
Message-ID: <1509035405-20497-1-git-send-email-pkaustub@cisco.com>
Cc: gvaradar@cisco.com, benve@cisco.com,
        Parvi Kaustubhi <pkaustub@cisco.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from alln-iport-5.cisco.com ([173.37.142.92]:60526 "EHLO
        alln-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932302AbdJZQkV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 12:40:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we are allowing rx ring size modification, reset fetch index
everytime. Otherwise it could have a stale value that can lead to a null
pointer dereference.

Signed-off-by: Govindarajulu Varadarajan <gvaradar@cisco.com>
Signed-off-by: Parvi Kaustubhi <pkaustub@cisco.com>
---
 drivers/net/ethernet/cisco/enic/vnic_rq.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/vnic_rq.c b/drivers/net/ethernet/cisco/enic/vnic_rq.c
index 36bc2c7..90537d9 100644
--- a/drivers/net/ethernet/cisco/enic/vnic_rq.c
+++ b/drivers/net/ethernet/cisco/enic/vnic_rq.c
@@ -141,18 +141,8 @@ void vnic_rq_init(struct vnic_rq *rq, unsigned int cq_index,
 {
 	u32 fetch_index = 0;
 
-	/* Use current fetch_index as the ring starting point */
-	fetch_index = ioread32(&rq->ctrl->fetch_index);
-
-	if (fetch_index == 0xFFFFFFFF) { /* check for hardware gone  */
-		/* Hardware surprise removal: reset fetch_index */
-		fetch_index = 0;
-	}
-
-	vnic_rq_init_start(rq, cq_index,
-		fetch_index, fetch_index,
-		error_interrupt_enable,
-		error_interrupt_offset);
+	vnic_rq_init_start(rq, cq_index, 0, 0, error_interrupt_enable,
+			   error_interrupt_offset);
 }
 
 unsigned int vnic_rq_error_status(struct vnic_rq *rq)
-- 
1.8.3.1
