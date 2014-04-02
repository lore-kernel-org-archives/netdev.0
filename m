From: Josh Boyer <jwboyer@fedoraproject.org>
Subject: [PATCH] net: bnx2x: include irq.h for irqreturn_t definitions
Date: Wed, 2 Apr 2014 11:21:58 -0400
Message-ID: <20140402152158.GB20438@zod>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ariel Elior <ariele@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:41257 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751231AbaDBPWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 11:22:01 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bnx2x driver fails to build on ARM with:

In file included from drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c:28:0:
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:243:1: error: unknown type name 'irqreturn_t'
 irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance);
 ^
drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h:251:1: error: unknown type name 'irqreturn_t'
 irqreturn_t bnx2x_interrupt(int irq, void *dev_instance);
 ^

Nothing in bnx2x_link.c or bnx2x_cmn.h is explicitly including the irq
definitions, so we add an include of linux/irq.h to pick them up.

Signed-off-by: Josh Boyer <jwboyer@fedoraproject.org>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index a89a40f88c25..384025605948 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -21,6 +21,7 @@
 #include <linux/pci.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/irq.h>
 
 #include "bnx2x.h"
 #include "bnx2x_sriov.h"
-- 
1.8.5.3
