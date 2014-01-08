From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 2/2] be2net: Need a delay before processing CQE after 2nd mbox register write
Date: Wed, 8 Jan 2014 14:52:02 +0530
Message-ID: <4b4fd4cb-9d23-4900-a20c-f2c2bef70849@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:31439 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162AbaAHJXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 04:23:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to Host platform synchronization issues between the mbox RDY bit polled
status and the completion of the DMA for the CQE, it is preferable that the
Host always wait for the RDY bit to transition to 1 after the 2nd mbox register
write and always follow that with a short wait for the valid bit in the CQE,
before processing the CQE.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index 94c35c8..78560f2 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -502,6 +502,9 @@ static int be_mbox_notify_wait(struct be_adapter *adapter)
 	if (status != 0)
 		return status;
 
+	/* Need a delay before processing CQE after 2nd mbox register write */
+	udelay(1);
+
 	/* A cq entry has been made now */
 	if (be_mcc_compl_is_new(compl)) {
 		status = be_mcc_compl_process(adapter, &mbox->compl);
-- 
1.6.0.2
