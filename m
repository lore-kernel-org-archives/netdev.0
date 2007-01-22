From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 2/2] NetXen: Use pci_register_driver() instead of pci_module_init() in init_module
Date: Mon, 22 Jan 2007 06:52:53 -0800
Message-ID: <200701221452.l0MEqrdx005015@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	linuxram@us.ibm.com, netxenproj@linsyssoft.com,
	ricknu-0@student.ltu.se, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:11591 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751850AbXAVOxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 09:53:00 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am extremely sorry for sending this patch with wrong subject line before this.
Now i am resending the patch with correct line.

Thanks,
--Amit

This will use pci_register_driver() instead of pci_module_init().

Signed-off-by: Amit S. Kale <amitkale@netxen.com>
Signed-off-by: Richard Knutsson <ricknu-0@student.ltu.se>

---
 netxen_nic.h      |    2 +-
 netxen_nic_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 663fa2f..59324b1 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -63,7 +63,7 @@ #include <asm/pgtable.h>
 
 #include "netxen_nic_hw.h"
 
-#define NETXEN_NIC_BUILD_NO     "1"
+#define NETXEN_NIC_BUILD_NO     "2"
 #define _NETXEN_NIC_LINUX_MAJOR 3
 #define _NETXEN_NIC_LINUX_MINOR 3
 #define _NETXEN_NIC_LINUX_SUBVERSION 3
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 8a5792f..96e1bee 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1144,7 +1144,7 @@ static int __init netxen_init_module(voi
 	if ((netxen_workq = create_singlethread_workqueue("netxen")) == 0)
 		return -ENOMEM;
 
-	return pci_module_init(&netxen_driver);
+	return pci_register_driver(&netxen_driver);
 }
 
 module_init(netxen_init_module);
