From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net] be2net: Check for POST state in suspend-resume sequence
Date: Fri, 23 Aug 2013 14:59:33 +0530
Message-ID: <771abba1-2664-4807-9a45-56ca9ede3c74@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:44852 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752663Ab3HWJ2a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 05:28:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

In suspend-resume sequence, the OS could attempt to initialize the controller
before it is ready, check for POST state before going ahead.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 4559c35..3d91a5e 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4373,6 +4373,10 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
+	status = be_fw_wait_ready(adapter);
+	if (status)
+		return status;
+
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
-- 
1.7.9.5
