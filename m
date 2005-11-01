From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH] ibmveth fix panic in initial replenish cycle
Date: Tue, 1 Nov 2005 14:15:09 -0500
Message-ID: <20051101175617.25145.73324.sendpatchset@ltcml8p7.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751156AbVKATPM@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a panic in the current tree caused by a race condition between the initial replenish cycle and the rx processing of the first packets trying to replenish the buffers.

Signed-off-by: Santiago Leon <santil@us.ibm.com>

diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -535,7 +535,7 @@ static int ibmveth_open(struct net_devic
 	}
 
 	ibmveth_debug_printk("initial replenish cycle\n");
-	ibmveth_replenish_task(adapter);
+	ibmveth_interrupt(netdev->irq, netdev, NULL);
 
 	netif_start_queue(netdev);
 
