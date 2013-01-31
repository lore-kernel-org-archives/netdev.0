From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch v2] qlcnic: silence false positive overflow warning
Date: Thu, 31 Jan 2013 11:14:10 +0300
Message-ID: <20130131081410.GA14542@elgon.mountain>
References: <20130127.203851.2157088853751625559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sony Chacko <sony.chacko@qlogic.com>, linux-driver@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40542 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755241Ab3AaIOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2013 03:14:23 -0500
Content-Disposition: inline
In-Reply-To: <20130127.203851.2157088853751625559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We actually store the MAC address as well as the board_name here.  The
longest board_name is 75 characters so there is more than enough room
to hold the 17 character MAC and the ": " divider.  But making this
buffer larger silences a static checker warning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
Acked-By: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
v2: Rebased on current net-next.

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index f3deef0..6a59a11 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1813,7 +1813,7 @@ qlcnic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct qlcnic_hardware_context *ahw;
 	int err, pci_using_dac = -1;
 	u32 capab2;
-	char board_name[QLCNIC_MAX_BOARD_NAME_LEN];
+	char board_name[QLCNIC_MAX_BOARD_NAME_LEN + 19]; /* MAC + ": " + name */
 
 	err = pci_enable_device(pdev);
 	if (err)
