From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/4] myri10ge: prevent 4k rdma on SGI TIOCE chipset
Date: Wed, 07 Mar 2007 20:01:53 +0100
Message-ID: <45EF0C21.8070406@myri.com>
References: <45EF0B6C.9070005@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl.myri.com ([64.172.73.26]:1997 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S2992450AbXCGTEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 14:04:00 -0500
In-Reply-To: <45EF0B6C.9070005@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Do not use 4k rdma request on SGI TIOCE chipset since this
bridge does not support it.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    6 ++++++
 1 file changed, 6 insertions(+)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:07.000000000 +0100
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2007-03-07 08:51:47.000000000 +0100
@@ -2514,6 +2514,12 @@
 				 bridge->vendor, bridge->device);
 			mgp->tx.boundary = 4096;
 			mgp->fw_name = myri10ge_fw_aligned;
+		} else if (bridge &&
+			   bridge->vendor == PCI_VENDOR_ID_SGI &&
+			   bridge->device == 0x4002 /* TIOCE pcie-port */ ) {
+			/* this pcie bridge does not support 4K rdma request */
+			mgp->tx.boundary = 2048;
+			mgp->fw_name = myri10ge_fw_aligned;
 		}
 	} else {
 		if (myri10ge_force_firmware == 1) {


