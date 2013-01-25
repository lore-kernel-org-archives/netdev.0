From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] qlcnic: silence false positive overflow warning
Date: Fri, 25 Jan 2013 09:41:42 +0300
Message-ID: <20130125064141.GB4882@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:17649 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751108Ab3AYGlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jan 2013 01:41:50 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We actually store the MAC address as well as the board_name here.  The
longest board_name is 75 characters so there is more than enough room
to hold the 17 character MAC and the ": " divider.  But making this
buffer larger silences a static checker warning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
I'm not sure if this is worth sending.  Feel free to drop this if you
want.

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 7f63b5f..09870d4 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1724,7 +1724,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_adapter *adapter = NULL;
 	struct qlcnic_hardware_context *ahw;
 	int err, pci_using_dac = -1;
-	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
+	char board_name[QLCNIC_MAX_BOARD_NAME_LEN + 19]; /* MAC + ": " + name */
 
 	err = pci_enable_device(pdev);
 	if (err)
