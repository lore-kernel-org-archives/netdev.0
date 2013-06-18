From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net] sfc: Remove write permission from phy_type attribute
Date: Tue, 18 Jun 2013 17:45:40 +0100
Message-ID: <1371573940.1956.19.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:37026 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932168Ab3FRQpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jun 2013 12:45:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Driver probe currently results in:

WARNING: at drivers/base/core.c:576 device_create_file+0x57/0x7e()
Attribute phy_type: write permission without 'store'

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 39e4cb3..4a14a94 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -2139,7 +2139,7 @@ show_phy_type(struct device *dev, struct device_attribute *attr, char *buf)
 	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
 	return sprintf(buf, "%d\n", efx->phy_type);
 }
-static DEVICE_ATTR(phy_type, 0644, show_phy_type, NULL);
+static DEVICE_ATTR(phy_type, 0444, show_phy_type, NULL);
 
 static int efx_register_netdev(struct efx_nic *efx)
 {
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
