From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [patch 06/14] e1000: disable TSO on the 82544 with slab debugging
Date: Fri, 15 Dec 2006 10:34:46 +0100
Message-ID: <1166175286.3365.121.camel@laptopd505.fenrus.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from a222036.upc-a.chello.nl ([62.163.222.36]:47094 "EHLO
	laptopd505.fenrus.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751493AbWLOKA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 05:00:59 -0500
Received: from laptopd505.fenrus.org (localhost.localdomain [127.0.0.1])
	by laptopd505.fenrus.org (8.13.8/8.13.8) with ESMTP id kBF9gpoZ006155
	for <netdev@vger.kernel.org>; Fri, 15 Dec 2006 10:42:51 +0100
Received: (from arjan@localhost)
	by laptopd505.fenrus.org (8.13.8/8.13.8/Submit) id kBF9goIu006154
	for netdev@vger.kernel.org; Fri, 15 Dec 2006 10:42:50 +0100
To: netdev@vger.kernel.org
In-Reply-To: <1166174907.3365.108.camel@laptopd505.fenrus.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: e1000: disable TSO on the 82544 with slab debugging
From: Jesse Brandeburg <jesse.brandeburg@intel.com>

CONFIG_DEBUG_SLAB changes alignments of the data structures the slab
allocators return. These break certain workarounds for TSO on the 82544.
Since DEBUG_SLAB is relatively rare and not used for performance sensitive
cases, the simplest fix is to disable TSO in this special situation.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---

 drivers/net/e1000/e1000_main.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -911,6 +911,12 @@ e1000_probe(struct pci_dev *pdev,
 	   (adapter->hw.mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
+#ifdef CONFIG_DEBUG_SLAB
+	/* 82544's work arounds do not play nicely with DEBUG SLAB */
+	if (adapter->hw.mac_type == e1000_82544)
+		netdev->features &= ~NETIF_F_TSO;
+#endif
+
 #ifdef NETIF_F_TSO6
 	if (adapter->hw.mac_type > e1000_82547_rev_2)
 		netdev->features |= NETIF_F_TSO6;

