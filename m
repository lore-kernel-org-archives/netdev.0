From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/3] myri10ge: use regular firmware on Serverworks HT2100
Date: Sun, 18 Mar 2007 21:34:33 +0100
Message-ID: <45FDA259.4090107@myri.com>
References: <45FDA22E.1070805@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1960 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933090AbXCRUgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2007 16:36:25 -0400
In-Reply-To: <45FDA22E.1070805@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[PATCH 1/3] myri10ge: use regular firmware on Serverworks HT2100

Use the regular firmware on Serverworks HT2100 PCIe ports since this
chipset provides aligned PCIe completions.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:01:42.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-18 21:14:12.000000000 +0100
@@ -2483,6 +2483,8 @@
 
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
 #define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
+#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST 0x140
+#define PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST 0x142
 
 static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 {
@@ -2514,6 +2516,12 @@
 			   ((bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
 			     && bridge->device ==
 			     PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE)
+			    /* ServerWorks HT2100 */
+			    || (bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
+				&& bridge->device >=
+				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_FIRST
+				&& bridge->device <=
+				PCI_DEVICE_ID_SERVERWORKS_HT2100_PCIE_LAST)
 			    /* All Intel E5000 PCIE ports */
 			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
 				&& bridge->device >=


