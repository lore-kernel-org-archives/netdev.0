From: Roopa Prabhu <roprabhu@cisco.com>
Subject: [net-next-2.6 PATCH 4/4] enic: Add support for fw init command on
	sriov vf's
Date: Mon, 20 Feb 2012 02:12:04 -0800
Message-ID: <20120220101203.5794.32375.stgit@rhel6.1>
References: <20120220101140.5794.60233.stgit@rhel6.1>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtv-iport-1.cisco.com ([173.36.130.12]:42850 "EHLO
	mtv-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753525Ab2BTCSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2012 21:18:12 -0500
In-Reply-To: <20120220101140.5794.60233.stgit@rhel6.1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roprabhu@cisco.com>

This patch fixes enic_probe to do a fw init devcmd for sriov vfs.
This enables vf driver in the guest to get into adapter init state without
having to explicitly issue an init fw cmd with portprofile info. But a
successful init on the vf will require the port profile information to be
pre-provisioned by the hypervisor via the pf

Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: Christian Benvenuti <benve@cisco.com>
Signed-off-by: Sujith Sankar <ssujith@cisco.com>
---
 drivers/net/ethernet/cisco/enic/enic.h      |    2 +-
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)


diff --git a/drivers/net/ethernet/cisco/enic/enic.h b/drivers/net/ethernet/cisco/enic/enic.h
index 922b646..99998c6 100644
--- a/drivers/net/ethernet/cisco/enic/enic.h
+++ b/drivers/net/ethernet/cisco/enic/enic.h
@@ -32,7 +32,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"2.1.1.37"
+#define DRV_VERSION		"2.1.1.38"
 #define DRV_COPYRIGHT		"Copyright 2008-2011 Cisco Systems, Inc"
 
 #define ENIC_BARS_MAX		6
diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 2278c43..e27ec1d 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2452,7 +2452,7 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	 * called later by an upper layer.
 	 */
 
-	if (!enic_is_dynamic(enic) && !enic_is_sriov_vf(enic)) {
+	if (!enic_is_dynamic(enic)) {
 		err = vnic_dev_init(enic->vdev, 0);
 		if (err) {
 			dev_err(dev, "vNIC dev init failed, aborting\n");
