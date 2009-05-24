From: Brice Goglin <brice@myri.com>
Subject: [PATCH 3/3] myri10ge: Add support for vlan_features
Date: Sun, 24 May 2009 17:27:59 +0200
Message-ID: <4A19677F.9070704@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Network Development list <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1983 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753274AbZEXP1l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 11:27:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for netdev->vlan_features in the myri10ge driver.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 675f677..7e28b46 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.5.0-1.415"
+#define MYRI10GE_VERSION_STR "1.5.0-1.418"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -3916,6 +3916,12 @@ static int myri10ge_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		netdev->features |= NETIF_F_HIGHDMA;
 	netdev->features |= NETIF_F_LRO;
 
+	netdev->vlan_features |= mgp->features;
+	if (mgp->fw_ver_tiny < 37)
+		netdev->vlan_features &= ~NETIF_F_TSO6;
+	if (mgp->fw_ver_tiny < 32)
+		netdev->vlan_features &= ~NETIF_F_TSO;
+
 	/* make sure we can get an irq, and that MSI can be
 	 * setup (if available).  Also ensure netdev->irq
 	 * is set to correct value if MSI is enabled */
-- 
1.6.2.4



