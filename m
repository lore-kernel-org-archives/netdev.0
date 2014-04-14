From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 1/6] qlcnic: Fix panic due to uninitialzed delayed_work struct in use.
Date: Mon, 14 Apr 2014 10:02:18 -0400
Message-ID: <1397484143-9708-2-git-send-email-shahed.shaikh@qlogic.com>
References: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:12432 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752540AbaDNOj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Apr 2014 10:39:59 -0400
In-Reply-To: <1397484143-9708-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o AEN event was being received before initializing delayed_work struct
  and handlers for it. This was resulting in crash. This patch fixes it.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index b48737d..d211af7 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2348,14 +2348,13 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 		goto disable_intr;
 	}
 
+	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
+
 	err = qlcnic_83xx_setup_mbx_intr(adapter);
 	if (err)
 		goto disable_mbx_intr;
 
 	qlcnic_83xx_clear_function_resources(adapter);
-
-	INIT_DELAYED_WORK(&adapter->idc_aen_work, qlcnic_83xx_idc_aen_work);
-
 	qlcnic_83xx_initialize_nic(adapter, 1);
 
 	/* Configure default, SR-IOV or Virtual NIC mode of operation */
-- 
1.8.1.4
