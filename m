From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 5/7] be2net: issue function reset cmd in resume path
Date: Tue, 20 Jan 2015 03:51:47 -0500
Message-ID: <1421743909-14716-6-git-send-email-sathya.perla@emulex.com>
References: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:42758 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbbATItA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 03:49:00 -0500
In-Reply-To: <1421743909-14716-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalesh AP <kalesh.purayil@emulex.com>

The Lancer FW is picky about requiring a function reset FW cmd as a part
of the initialization sequence.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f5ac35c..0b0482b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -5071,6 +5071,10 @@ static int be_resume(struct pci_dev *pdev)
 	if (status)
 		return status;
 
+	status = be_cmd_reset_function(adapter);
+	if (status)
+		return status;
+
 	be_intr_set(adapter, true);
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
-- 
2.2.0
