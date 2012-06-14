From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH 2/3] be2net: Modify error message to incorporate subsystem
Date: Thu, 14 Jun 2012 11:21:44 +0530
Message-ID: <39d85560-1fe2-452a-b13f-51233f22a846@exht1.ad.emulex.com>
References: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Vasundhara Volam <vasundhara.volam@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51758 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751298Ab2FNFwU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jun 2012 01:52:20 -0400
In-Reply-To: <1339653105-7313-1-git-send-email-sarveshwar.bandi@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Modify IOCTL error message to print subsystem also.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_cmds.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_cmds.c b/drivers/net/ethernet/emulex/benet/be_cmds.c
index f899752..5eab791 100644
--- a/drivers/net/ethernet/emulex/benet/be_cmds.c
+++ b/drivers/net/ethernet/emulex/benet/be_cmds.c
@@ -122,15 +122,15 @@ static int be_mcc_compl_process(struct be_adapter *adapter,
 			goto done;
 
 		if (compl_status == MCC_STATUS_UNAUTHORIZED_REQUEST) {
-			dev_warn(&adapter->pdev->dev, "This domain(VM) is not "
-				"permitted to execute this cmd (opcode %d)\n",
-				opcode);
+			dev_warn(&adapter->pdev->dev,
+				 "opcode %d-%d is not permitted\n",
+				 opcode, subsystem);
 		} else {
 			extd_status = (compl->status >> CQE_STATUS_EXTD_SHIFT) &
 					CQE_STATUS_EXTD_MASK;
-			dev_err(&adapter->pdev->dev, "Cmd (opcode %d) failed:"
-				"status %d, extd-status %d\n",
-				opcode, compl_status, extd_status);
+			dev_err(&adapter->pdev->dev,
+				"opcode %d-%d failed:status %d-%d\n",
+				opcode, subsystem, compl_status, extd_status);
 		}
 	}
 done:
-- 
1.7.9.5
