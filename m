From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH] sfc: Remove lro module parameter
Date: Wed, 20 May 2009 00:17:57 +0100
Message-ID: <1242775077.3198.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:32978 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754513AbZESXSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 19:18:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

GRO/LRO can be controlled through ethtool so this is unnecessary.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   15 ++-------------
 1 files changed, 2 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index d3e240b..5f4aae5 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -50,16 +50,6 @@ static struct workqueue_struct *reset_workqueue;
  *************************************************************************/
 
 /*
- * Enable large receive offload (LRO) aka soft segment reassembly (SSR)
- *
- * This sets the default for new devices.  It can be controlled later
- * using ethtool.
- */
-static int lro = true;
-module_param(lro, int, 0644);
-MODULE_PARM_DESC(lro, "Large receive offload acceleration");
-
-/*
  * Use separate channels for TX and RX events
  *
  * Set this to 1 to use separate channels for TX and RX. It allows us
@@ -2167,9 +2157,8 @@ static int __devinit efx_pci_probe(struct pci_dev *pci_dev,
 	if (!net_dev)
 		return -ENOMEM;
 	net_dev->features |= (NETIF_F_IP_CSUM | NETIF_F_SG |
-			      NETIF_F_HIGHDMA | NETIF_F_TSO);
-	if (lro)
-		net_dev->features |= NETIF_F_GRO;
+			      NETIF_F_HIGHDMA | NETIF_F_TSO |
+			      NETIF_F_GRO);
 	/* Mask for features that also apply to VLAN devices */
 	net_dev->vlan_features |= (NETIF_F_ALL_CSUM | NETIF_F_SG |
 				   NETIF_F_HIGHDMA | NETIF_F_TSO);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

