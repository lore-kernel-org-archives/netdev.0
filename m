From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/2] myri10ge - drop workaround pci_save_state() disabling MSI
Date: Thu, 22 Jun 2006 21:12:36 -0400
Message-ID: <20060623011235.GB18337@myri.com>
References: <20060623011043.GA18234@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:17113 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932737AbWFWBMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 21:12:38 -0400
Received: from ice.sw.myri.com (ice.sw.myri.com [172.31.160.2])
	by myri.com (8.12.9+Sun/8.12.9) with ESMTP id k5N1CZmc002330
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 18:12:36 -0700 (PDT)
Received: from bgoglin by ice.sw.myri.com with local (Exim 3.36 #1 (Debian))
	id 1FtaDs-0004m3-00
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 21:12:36 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060623011043.GA18234@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] myri10ge - drop workaround pci_save_state() disabling MSI

We don't need to restore the state right after saving it for later recovery
since commit 99dc804d9bcc2c53f4c20c291bf4e185312a1a0c (PCI: disable msi mode
in pci_disable_device) now prevents pci_save_state() from disabling MSI.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    2 --
 1 file changed, 2 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-06-22 20:42:34.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-06-22 20:42:45.000000000 -0400
@@ -2726,8 +2726,6 @@
 	/* Save configuration space to be restored if the
 	 * nic resets due to a parity error */
 	myri10ge_save_state(mgp);
-	/* Restore state immediately since pci_save_msi_state disables MSI */
-	myri10ge_restore_state(mgp);
 
 	/* Setup the watchdog timer */
 	setup_timer(&mgp->watchdog_timer, myri10ge_watchdog_timer,
