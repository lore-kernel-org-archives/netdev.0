From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/2] qlge: Set PCIe reset type for EEH to fundamental.
Date: Fri,  6 Nov 2009 09:44:58 -0800
Message-ID: <1257529498-17459-3-git-send-email-ron.mercer@qlogic.com>
References: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26379 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753096AbZKFRvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 12:51:21 -0500
In-Reply-To: <1257529498-17459-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This device requires a fundamental reset when recovering from EEH.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index cea7531..a2fc70a 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3916,6 +3916,8 @@ static int __devinit ql_init_device(struct pci_dev *pdev,
 		goto err_out;
 	}
 
+	/* Set PCIe reset type for EEH to fundamental. */
+	pdev->needs_freset = 1;
 	pci_save_state(pdev);
 	qdev->reg_base =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
-- 
1.6.0.2

