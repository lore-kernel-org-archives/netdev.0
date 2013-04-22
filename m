From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 2/5] be2net: Don't log "Out of MCCQ wrbs" error
Date: Mon, 22 Apr 2013 14:58:15 +0530
Message-ID: <1366622898-1416-3-git-send-email-sathya.perla@emulex.com>
References: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:12513 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755711Ab3DVJZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 05:25:43 -0400
In-Reply-To: <1366622898-1416-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Don't log "Out of MCCQ wrbs" msg. When the driver doesn't receive any
response from the FW it already logs a "FW not responding" message.
The driver runs out of MCCQ wrbs much later. Also, this message can
swamp the kernel log in HW/FW error scenarios.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 5d96f77..a20b31d 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -687,10 +687,8 @@ static struct be_mcc_wrb *wrb_from_mccq(struct be_adapter *adapter)
 	if (!mccq->created)
 		return NULL;
 
-	if (atomic_read(&mccq->used) >= mccq->len) {
-		dev_err(&adapter->pdev->dev, "Out of MCCQ wrbs\n");
+	if (atomic_read(&mccq->used) >= mccq->len)
 		return NULL;
-	}
 
 	wrb = queue_head_node(mccq);
 	queue_head_inc(mccq);
-- 
1.7.1
