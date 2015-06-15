From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: mark state UNINIT after unregister
Date: Mon, 15 Jun 2015 18:27:54 +0100
Message-ID: <557F0B1A.2040809@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:54822 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754109AbbFOR17 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 13:27:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this change, modprobe -r sfc hits the BUG_ON() in
efx_pci_remove_main().

Fixes: e7fef9b45ae1 ("sfc: add sysfs entry to control MCDI tracing")
Reported-by: Jarod Wilson <jarod@redhat.com>
Reviewed-by: Jarod Wilson <jarod@redhat.com>
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 0c42ed9..67bdaf3 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2920,6 +2920,7 @@ static void efx_pci_remove(struct pci_dev *pci_dev)
 	efx_dissociate(efx);
 	dev_close(efx->net_dev);
 	efx_disable_interrupts(efx);
+	efx->state = STATE_UNINIT;
 	rtnl_unlock();
 
 	if (efx->type->sriov_fini)
