From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH] ethernet/sfc: mark state UNINIT after unregister
Date: Fri, 12 Jun 2015 14:51:01 -0400
Message-ID: <1434135061-42521-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this change, modprobe -r sfc hits the BUG_ON() in
efx_pci_remove_main(). Best as I can tell, this was just an oversight,
efx->state gets set to STATE_UNINIT in the error path of
efx_register_netdev() just after unregister_netdevice(), and the same
should happen in efx_unregister_netdev() after its unregister_netdevice()
call. Now I can load and unload no problem.

CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/sfc/efx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0c42ed9..f3eaade 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2448,6 +2448,7 @@ static void efx_unregister_netdev(struct efx_nic *efx)
 #endif
 		device_remove_file(&efx->pci_dev->dev, &dev_attr_phy_type);
 		unregister_netdev(efx->net_dev);
+		efx->state = STATE_UNINIT;
 	}
 }
 
-- 
1.8.3.1
