From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/10] igb: Fix for improper exit in igb_get_i2c_client
Date: Fri, 15 Feb 2013 02:04:01 -0800
Message-ID: <1360922649-3388-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:65113 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935577Ab3BOKEP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:04:15 -0500
In-Reply-To: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes an issue where we check for irq's disabled then exit after
explicitly disabling them with spin_lock_irqsave.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <arron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 7 +------
 1 file changed, 1 insertion(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index b070a97..d84f28c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7750,12 +7750,7 @@ igb_get_i2c_client(struct igb_adapter *adapter, u8 dev_addr)
 		}
 	}
 
-	/* no client_list found, create a new one as long as
-	 * irqs are not disabled
-	 */
-	if (unlikely(irqs_disabled()))
-		goto exit;
-
+	/* no client_list found, create a new one */
 	client_list = kzalloc(sizeof(*client_list), GFP_KERNEL);
 	if (client_list == NULL)
 		goto exit;
-- 
1.7.11.7
