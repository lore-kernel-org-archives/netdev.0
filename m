From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/10] igb: Fix for improper allocation flag in igb_get_i2c_client
Date: Fri, 15 Feb 2013 02:04:02 -0800
Message-ID: <1360922649-3388-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Carolyn Wyborny <carolyn.wyborny@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:41880 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935608Ab3BOKER (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2013 05:04:17 -0500
In-Reply-To: <1360922649-3388-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carolyn Wyborny <carolyn.wyborny@intel.com>

This patch fixes the allocation function in igb_get_i2c_client to use
GFP_ATOMIC instead of GFP_KERNEL because we have a spinlock.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Carolyn Wyborny <carolyn.wyborny@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index d84f28c..c19a35c 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7751,7 +7751,7 @@ igb_get_i2c_client(struct igb_adapter *adapter, u8 dev_addr)
 	}
 
 	/* no client_list found, create a new one */
-	client_list = kzalloc(sizeof(*client_list), GFP_KERNEL);
+	client_list = kzalloc(sizeof(*client_list), GFP_ATOMIC);
 	if (client_list == NULL)
 		goto exit;
 
-- 
1.7.11.7
