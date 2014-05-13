From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH] be2net: enable interrupts in EEH resume
Date: Tue, 13 May 2014 14:03:11 +0530
Message-ID: <1399969991-22762-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3323 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758786AbaEMI37 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 04:29:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

On some BE3 FW versions, after a HW reset, interrupts will remain disabled
for each function. So, explicitly enable the interrupts in the eeh_resume
handler, else after an eeh recovery interrupts wouldn't work.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a186454..dc19bc5 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4949,6 +4949,12 @@ static void be_eeh_resume(struct pci_dev *pdev)
 	if (status)
 		goto err;
 
+	/* On some BE3 FW versions, after a HW reset,
+	 * interrupts will remain disabled for each function.
+	 * So, explicitly enable interrupts
+	 */
+	be_intr_set(adapter, true);
+
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
-- 
1.7.1
