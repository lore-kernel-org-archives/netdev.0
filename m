From: Jesse Brandeburg <jesse.brandeburg@intel.com>
Subject: [RFC PATCH 1/3] e1000e: implement MDI-X control
Date: Wed, 17 Nov 2010 15:29:10 -0800
Message-ID: <20101117232910.3513.99143.stgit@jbrandeb-ich9b.jf.intel.com>
References: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:1634 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751142Ab0KQX3L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Nov 2010 18:29:11 -0500
Received: from jbrandeb-ich9b.jf.intel.com (localhost.localdomain [127.0.0.1])
	by jbrandeb-ich9b.jf.intel.com (8.14.4/8.14.4) with ESMTP id oAHNTAZ9003560
	for <netdev@vger.kernel.org>; Wed, 17 Nov 2010 15:29:10 -0800
In-Reply-To: <20101117232645.3513.20655.stgit@jbrandeb-ich9b.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

some users report issues with link failing when connected
to certain switches.  This gives the user the ability to
control the MDI-X state from the driver.

This is in regards to the related ethtool patch and
bugzilla.kernel.org bug 11998

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: bruce.w.allan@intel.com
CC: n.poppelier@xs4all.nl
CC: bastien@durel.org
CC: jsveiga@it.eng.br
---

 drivers/net/e1000e/e1000.h   |    1 -
 drivers/net/e1000e/ethtool.c |    4 ++++
 drivers/net/e1000e/netdev.c  |    2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index fdc67fe..10469b2 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -81,7 +81,6 @@ struct e1000_info;
 /* How many Rx Buffers do we bundle into one write to the hardware ? */
 #define E1000_RX_BUFFER_WRITE		16 /* Must be power of 2 */
 
-#define AUTO_ALL_MODES			0
 #define E1000_EEPROM_APME		0x0400
 
 #define E1000_MNG_VLAN_NONE		(-1)
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index 8984d16..f518c9b 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -285,6 +285,10 @@ static int e1000_set_settings(struct net_device *netdev,
 		}
 	}
 
+	/* MDI-X => 2; MDI =>1; Auto =>0 */
+	if (ecmd->eth_tp_mdix && (hw->phy.media_type == e1000_media_type_copper))
+		hw->phy.mdix = ecmd->eth_tp_mdix;
+
 	/* reset the link */
 
 	if (netif_running(adapter->netdev)) {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 68e79c2..9e7d864 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5842,7 +5842,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 
 	/* Copper options */
 	if (adapter->hw.phy.media_type == e1000_media_type_copper) {
-		adapter->hw.phy.mdix = AUTO_ALL_MODES;
+		adapter->hw.phy.mdix = ETH_TP_MDI_INVALID;
 		adapter->hw.phy.disable_polarity_correction = 0;
 		adapter->hw.phy.ms_type = e1000_ms_hw_default;
 	}

