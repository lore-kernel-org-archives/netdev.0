From: leitao@linux.vnet.ibm.com
Subject: [PATCH 1/2] qlge: Replacing add_timer() to mod_timer()
Date: Thu,  1 Jul 2010 10:00:17 -0300
Message-ID: <e687077281d05d3a2da49431b7c0ff0b1076f3e6.1277936929.git.root@sanx1002.austin.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>,
	Ron Mercer <ron.mercer@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp05.br.ibm.com ([32.104.18.26]:53246 "EHLO
	e24smtp05.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789Ab0GANAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 09:00:24 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp05.br.ibm.com (8.14.4/8.13.1) with ESMTP id o61Cxu5U025421
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 09:59:56 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o61D0KKE4034754
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 10:00:21 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o61D07H0000367
	for <netdev@vger.kernel.org>; Thu, 1 Jul 2010 10:00:08 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently qlge driver calls add_timer() instead of mod_timer().
This patch changes add_timer() to mod_timer(), which seems a better
solution.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index fa4b24c..509dadc 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -4611,8 +4611,7 @@ static void ql_timer(unsigned long data)
 		return;
 	}
 
-	qdev->timer.expires = jiffies + (5*HZ);
-	add_timer(&qdev->timer);
+	mod_timer(&qdev->timer, jiffies + (5*HZ));
 }
 
 static int __devinit qlge_probe(struct pci_dev *pdev,
@@ -4808,8 +4807,7 @@ static void qlge_io_resume(struct pci_dev *pdev)
 		netif_err(qdev, ifup, qdev->ndev,
 			  "Device was not running prior to EEH.\n");
 	}
-	qdev->timer.expires = jiffies + (5*HZ);
-	add_timer(&qdev->timer);
+	mod_timer(&qdev->timer, jiffies + (5*HZ));
 	netif_device_attach(ndev);
 }
 
@@ -4871,8 +4869,7 @@ static int qlge_resume(struct pci_dev *pdev)
 			return err;
 	}
 
-	qdev->timer.expires = jiffies + (5*HZ);
-	add_timer(&qdev->timer);
+	mod_timer(&qdev->timer, jiffies + (5*HZ));
 	netif_device_attach(ndev);
 
 	return 0;
-- 
1.6.5.2

