From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next 12/14] sfc: do not allow VFs to be destroyed if assigned
 to guests
Date: Fri, 29 May 2015 11:03:18 +0100
Message-ID: <55683966.5090103@solarflare.com>
References: <55683895.2090408@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:6669 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932486AbbE2KD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2015 06:03:27 -0400
In-Reply-To: <55683895.2090408@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Pieczko <dpieczko@solarflare.com>

Signed-off-by: Shradha Shah <sshah@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10_sriov.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10_sriov.c b/drivers/net/ethernet/sfc/ef10_sriov.c
index cd52454..083c534 100644
--- a/drivers/net/ethernet/sfc/ef10_sriov.c
+++ b/drivers/net/ethernet/sfc/ef10_sriov.c
@@ -417,6 +417,15 @@ static int efx_ef10_pci_sriov_disable(struct efx_nic *efx)
 {
 	struct pci_dev *dev = efx->pci_dev;
 
+	if (!efx->vf_count)
+		return 0;
+
+	if (pci_vfs_assigned(dev)) {
+		netif_err(efx, drv, efx->net_dev, "VFs are assigned to guests; "
+			  "please detach them before disabling SR-IOV\n");
+		return -EBUSY;
+	}
+
 	pci_disable_sriov(dev);
 	efx_ef10_sriov_free_vf_vswitching(efx);
 	efx->vf_count = 0;
