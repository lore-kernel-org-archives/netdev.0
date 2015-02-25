From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: [PATCH net] enic: do notify_check before returning credits
Date: Wed, 25 Feb 2015 15:26:55 +0530
Message-ID: <1424858215-18918-1-git-send-email-_govind@gmx.com>
Cc: Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: davem@davemloft.net, netdev@vger.kernel.org, benve@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.18]:58967 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991AbbBYJ5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 04:57:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sujith Sankar <ssujith@cisco.com>

We should complete notify_check before returning the credits. Once we return the
credits, adaptor may access the notify data.

Signed-off-by: Sujith Sankar <ssujith@cisco.com>
Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 9cbe038..a5179bf 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -272,8 +272,8 @@ static irqreturn_t enic_isr_legacy(int irq, void *data)
 	}
 
 	if (ENIC_TEST_INTR(pba, notify_intr)) {
-		vnic_intr_return_all_credits(&enic->intr[notify_intr]);
 		enic_notify_check(enic);
+		vnic_intr_return_all_credits(&enic->intr[notify_intr]);
 	}
 
 	if (ENIC_TEST_INTR(pba, err_intr)) {
@@ -346,8 +346,8 @@ static irqreturn_t enic_isr_msix_notify(int irq, void *data)
 	struct enic *enic = data;
 	unsigned int intr = enic_msix_notify_intr(enic);
 
-	vnic_intr_return_all_credits(&enic->intr[intr]);
 	enic_notify_check(enic);
+	vnic_intr_return_all_credits(&enic->intr[intr]);
 
 	return IRQ_HANDLED;
 }
-- 
2.3.0
