From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net-next v3 13/15] sfc: do not allow VFs to be destroyed if
 assigned to guests
Date: Tue, 2 Jun 2015 11:40:31 +0100
Message-ID: <556D881F.1020300@solarflare.com>
References: <556D8710.6060706@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:7136 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757279AbbFBKkk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 06:40:40 -0400
In-Reply-To: <556D8710.6060706@solarflare.com>
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
