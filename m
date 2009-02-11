From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH] ehea: Fix: Remove adapter from adapter list in error path
Date: Wed, 11 Feb 2009 13:29:02 +0100
Message-ID: <200902111329.02954.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	osstklei@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:45628 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754498AbZBKM3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 07:29:06 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove adapter from adapter list before freeing data structure in error path.

Signed-off-by: Hannes Hering <hering2@de.ibm.com>

---

diff -Nurp -X dontdiff linux-2.6.29-rc4/drivers/net/ehea/ehea.h patched_kernel/drivers/net/ehea/ehea.h
--- linux-2.6.29-rc4/drivers/net/ehea/ehea.h	2009-02-11 13:13:42.036506588 +0100
+++ patched_kernel/drivers/net/ehea/ehea.h	2009-02-11 13:14:04.197540184 +0100
@@ -40,7 +40,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0097"
+#define DRV_VERSION	"EHEA_0098"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff -Nurp -X dontdiff linux-2.6.29-rc4/drivers/net/ehea/ehea_main.c patched_kernel/drivers/net/ehea/ehea_main.c
--- linux-2.6.29-rc4/drivers/net/ehea/ehea_main.c	2009-02-11 13:13:47.812542928 +0100
+++ patched_kernel/drivers/net/ehea/ehea_main.c	2009-02-11 13:14:04.197540184 +0100
@@ -3448,6 +3448,7 @@ out_kill_eq:
 	ehea_destroy_eq(adapter->neq);
 
 out_free_ad:
+	list_del(&adapter->list);
 	kfree(adapter);
 
 out:
