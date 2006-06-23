From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/2] myri10ge - drop workaround for the missing AER ext cap on nVidia CK804
Date: Thu, 22 Jun 2006 21:11:59 -0400
Message-ID: <20060623011158.GA18337@myri.com>
References: <20060623011043.GA18234@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:13529 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S932736AbWFWBMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 21:12:01 -0400
Received: from ice.sw.myri.com (ice.sw.myri.com [172.31.160.2])
	by myri.com (8.12.9+Sun/8.12.9) with ESMTP id k5N1Bwmc002300
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 18:11:58 -0700 (PDT)
Received: from bgoglin by ice.sw.myri.com with local (Exim 3.36 #1 (Debian))
	id 1FtaDH-0004lx-00
	for <netdev@vger.kernel.org>; Thu, 22 Jun 2006 21:11:59 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060623011043.GA18234@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH] myri10ge - drop workaround for the missing AER ext cap on nVidia CK804

We don't need to hardcode the AER capability of the nVidia CK804 chipset
anymore since commit cf34a8e07f02c76f3f1232eecb681301a3d7b10b (PCI: nVidia
quirk to make AER PCI-E extended capability visible) now makes sure that
this cap will be available to pci_find_ext_capability().

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 ------
 1 file changed, 6 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-06-22 20:41:50.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-06-22 20:41:59.000000000 -0400
@@ -2251,12 +2251,6 @@
 	}
 
 	cap = pci_find_ext_capability(bridge, PCI_EXT_CAP_ID_ERR);
-	/* nvidia ext cap is not always linked in ext cap chain */
-	if (!cap
-	    && bridge->vendor == PCI_VENDOR_ID_NVIDIA
-	    && bridge->device == PCI_DEVICE_ID_NVIDIA_NFORCE_CK804_PCIE)
-		cap = 0x160;
-
 	if (!cap)
 		return;
 
