From: Thomas Klein <osstklei@de.ibm.com>
Subject: [PATCH 2.6.20-rc6 2/2] ehea: Fixed missing tasklet_kill() call
Date: Mon, 29 Jan 2007 18:44:41 +0100
Message-ID: <200701291844.41333.osstklei@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Christoph Raisch <raisch@de.ibm.com>,
	"Jan-Bernd Themann" <ossthema@de.ibm.com>,
	"Jan-Bernd Themann" <themann@de.ibm.com>,
	"linux-kernel" <linux-kernel@vger.kernel.org>,
	"linux-ppc" <linuxppc-dev@ozlabs.org>,
	Marcus Eder <meder@de.ibm.com>,
	netdev <netdev@vger.kernel.org>,
	Thomas Klein <tklein@de.ibm.com>,
	Stefan Roscher <ossrosch@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:1808 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752523AbXA2Ron (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jan 2007 12:44:43 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NEQ-Tasklet wasn't killed when module is removed.


Signed-off-by: Thomas Klein <tklein@de.ibm.com>
---


 drivers/net/ehea/ehea_main.c |    1 +
 1 files changed, 1 insertion(+)


diff -Nurp -X dontdiff linux-2.6.20-rc6/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.20-rc6/drivers/net/ehea/ehea_main.c	2007-01-29 15:53:00.000000000 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2007-01-29 15:53:34.000000000 +0100
@@ -2598,6 +2598,7 @@ static int __devexit ehea_remove(struct 
 	destroy_workqueue(adapter->ehea_wq);
 
 	ibmebus_free_irq(NULL, adapter->neq->attr.ist1, adapter);
+	tasklet_kill(&adapter->neq_tasklet);
 
 	ehea_destroy_eq(adapter->neq);
 

