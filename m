From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2/9] pcnet32: Use PCI_DEVICE macro
Date: Thu, 29 Jun 2006 13:52:58 -0700
Message-ID: <20060629205258.GA21996@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:26763 "EHLO
	e32.co.us.ibm.com") by vger.kernel.org with ESMTP id S1750983AbWF2Uwn
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jun 2006 16:52:43 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKqhLc004305
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:52:43 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKr0DF115274
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:53:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKqgbU009980
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 14:52:42 -0600
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jon Mason wrote on Thu, 12 Jan 2006 17:07:49 -0600:
This patch adds the PCI_DEVICE macro to the pcnet32 driver.

This has been tested on my opteron with my "trident" adapter.

Don Fry modified it slightly and tested on ia32 and ppc64.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/mismatch.pcnet32.c	Wed Jun 28 11:03:38 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 11:11:37 2006
@@ -58,18 +58,15 @@ static const char *const version =
  * PCI device identifiers for "new style" Linux PCI Device Drivers
  */
 static struct pci_device_id pcnet32_pci_tbl[] = {
-	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{ PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE,
-	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE_HOME), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_AMD, PCI_DEVICE_ID_AMD_LANCE), },
 
 	/*
 	 * Adapters that were sold with IBM's RS/6000 or pSeries hardware have
 	 * the incorrect vendor id.
 	 */
-	{ PCI_VENDOR_ID_TRIDENT, PCI_DEVICE_ID_AMD_LANCE,
-	  PCI_ANY_ID, PCI_ANY_ID,
-	  PCI_CLASS_NETWORK_ETHERNET << 8, 0xffff00, 0},
+	{ PCI_DEVICE(PCI_VENDOR_ID_TRIDENT, PCI_DEVICE_ID_AMD_LANCE),
+	  .class = (PCI_CLASS_NETWORK_ETHERNET << 8), .class_mask = 0xffff00, },
 
 	{ }	/* terminate list */
 };
-- 
Don Fry
brazilnut@us.ibm.com
