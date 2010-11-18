From: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
Subject: [PATCH] qlge: Fix incorrect usage of module parameters and netdev msg
 level
Date: Thu, 18 Nov 2010 04:25:03 -0600
Message-ID: <1290075903-3038-1-git-send-email-sonnyrao@linux.vnet.ibm.com>
Cc: Sonny Rao <sonnyrao@linux.vnet.ibm.com>,
	Milton Miller <miltonm@bga.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:35941 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754498Ab0KRTVl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Nov 2010 14:21:41 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oAIIxvXW029561
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 13:59:57 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oAIJLeOk189350
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 14:21:40 -0500
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oAIJLeqv017633
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 12:21:40 -0700
Received: from us.ibm.com (dyn9414181.austin.ibm.com [9.41.41.81])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id oAIJLdNW017604
	for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 12:21:39 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver appears to be mistaking the permission field with default value
in the case of debug and qlge_irq_type.

Driver is also passing debug as a bitmask into netif_msg_init()
which really wants a number of bits, so fix that.

Signed-off-by: Milton Miller <miltonm@bga.com>
Signed-off-by: Sonny Rao <sonnyrao@linux.vnet.ibm.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d9a7626..66878bb 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -62,15 +62,15 @@ static const u32 default_msg =
 /* NETIF_MSG_PKTDATA | */
     NETIF_MSG_HW | NETIF_MSG_WOL | 0;

-static int debug = 0x00007fff;	/* defaults above */
-module_param(debug, int, 0);
+static int debug = 15;	/* defaults above */
+module_param(debug, int, 0664);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");

 #define MSIX_IRQ 0
 #define MSI_IRQ 1
 #define LEG_IRQ 2
 static int qlge_irq_type = MSIX_IRQ;
-module_param(qlge_irq_type, int, MSIX_IRQ);
+module_param(qlge_irq_type, int, 0664);
 MODULE_PARM_DESC(qlge_irq_type, "0 = MSI-X, 1 = MSI, 2 = Legacy.");

 static int qlge_mpi_coredump;
-- 
1.5.6.5

