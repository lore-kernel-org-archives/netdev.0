From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 01/10] drivers: net: add missing interrupt.h include
Date: Mon, 17 Jul 2017 13:57:18 +0200
Message-ID: <20170717115727.26042-2-fw@strlen.de>
References: <20170717115727.26042-1-fw@strlen.de>
Cc: steffen.klassert@secunet.com, ilant@mellanox.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43888 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751280AbdGQL5L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 07:57:11 -0400
In-Reply-To: <20170717115727.26042-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

these drivers use tasklets or irq apis, but don't include interrupt.h.
Once flow cache is removed the implicit interrupt.h inclusion goes away
which will break the build.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/arcnet/arcdevice.h                 | 2 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h           | 1 +
 drivers/net/ethernet/synopsys/dwc-xlgmac-net.c | 1 +
 drivers/net/ieee802154/ca8210.c                | 1 +
 4 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index cbb4f8566bbe..d09b2b46ab63 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -20,7 +20,7 @@
 #include <linux/if_arcnet.h>
 
 #ifdef __KERNEL__
-#include  <linux/irqreturn.h>
+#include <linux/interrupt.h>
 
 /*
  * RECON_THRESHOLD is the maximum number of RECON messages to receive
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 0938294f640a..e9282c924621 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -129,6 +129,7 @@
 #include <net/dcbnl.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
+#include <linux/interrupt.h>
 
 #define XGBE_DRV_NAME		"amd-xgbe"
 #define XGBE_DRV_VERSION	"1.0.3"
diff --git a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
index 3b91257683bc..e1b55b8fb8e0 100644
--- a/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
+++ b/drivers/net/ethernet/synopsys/dwc-xlgmac-net.c
@@ -17,6 +17,7 @@
 
 #include <linux/netdevice.h>
 #include <linux/tcp.h>
+#include <linux/interrupt.h>
 
 #include "dwc-xlgmac.h"
 #include "dwc-xlgmac-reg.h"
diff --git a/drivers/net/ieee802154/ca8210.c b/drivers/net/ieee802154/ca8210.c
index a626c539fb17..326243fae7e2 100644
--- a/drivers/net/ieee802154/ca8210.c
+++ b/drivers/net/ieee802154/ca8210.c
@@ -66,6 +66,7 @@
 #include <linux/spinlock.h>
 #include <linux/string.h>
 #include <linux/workqueue.h>
+#include <linux/interrupt.h>
 
 #include <net/ieee802154_netdev.h>
 #include <net/mac802154.h>
-- 
2.13.0
