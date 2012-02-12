From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH] enic: remove assignment of random mac on enic vf
Date: Sun, 12 Feb 2012 00:12:44 -0800
Message-ID: <20120212081243.7875.56830.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-3.cisco.com ([173.36.130.14]:3711 "EHLO
	mtv-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014Ab2BLIMo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Feb 2012 03:12:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch removes random mac assignment on vf's. The vf's will start with
a zero mac and with upcoming support in fw/driver, a vf mac can be set
via the pf. vf's also support ndo_set_mac_address. This decision was made
based on the fact that a random mac on a vf is not really needed. And this
will reduce some of the problems with the vf's getting a new mac on
every driver load/unload (one of them being udev renaming the device on ever
load/unload and reboot).

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: sujith sankar <ssujith@cisco.com>
Signed-off-by: ChingWei Chang <cwchang@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c |    5 -----
 2 files changed, 1 insertions(+), 6 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index e65d431..f7c3067 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.34"
+#define DRV_VERSION		"2.1.1.35"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 2838891..dd7e24b 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2463,11 +2463,6 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	enic->port_mtu = enic->config.mtu;
 	(void)enic_change_mtu(netdev, enic->port_mtu);
 
-#ifdef CONFIG_PCI_IOV
-	if (enic_is_sriov_vf(enic) && is_zero_ether_addr(enic->mac_addr))
-		random_ether_addr(enic->mac_addr);
-#endif
-
 	err = enic_set_mac_addr(netdev, enic->mac_addr);
 	if (err) {
 		dev_err(dev, "Invalid MAC address, aborting\n");
