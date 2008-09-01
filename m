From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 18/52] sfc: Set net_device::vlan_features appropriately
Date: Mon, 1 Sep 2008 12:46:54 +0100
Message-ID: <20080901114653.GL7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:35325 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757102AbYIALq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:56 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 7eb11d3..022dc36 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -2092,6 +2092,9 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 			      NETIF_F_HIGHDMA | NETIF_F_TSO);
 	if (lro)
 		net_dev->features |= NETIF_F_LRO;
+	/* Mask for features that also apply to VLAN devices */
+	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
+				   NETIF_F_HIGHDMA);
 	efx = netdev_priv(net_dev);
 	pci_set_drvdata(pci_dev, efx);
 	rc = efx_init_struct(efx, type, pci_dev, net_dev);
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

