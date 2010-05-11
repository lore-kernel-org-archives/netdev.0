From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH net-next 2/3] cxgb4: report the PCIe link speed
Date: Mon, 10 May 2010 18:58:08 -0700
Message-ID: <1273543089-10938-2-git-send-email-dm@chelsio.com>
References: <1273543089-10938-1-git-send-email-dm@chelsio.com>
Cc: Dimitris Michailidis <dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13268 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932156Ab0EKB6L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 21:58:11 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o4B1wATT007194
	for <netdev@vger.kernel.org>; Mon, 10 May 2010 18:58:10 -0700
In-Reply-To: <1273543089-10938-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Report the PCIe link speed (2.5 or 5 Gbps).

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index a73cda9..80c3fc5 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3080,6 +3080,12 @@ static void __devinit print_port_info(struct adapter *adap)
 
 	int i;
 	char buf[80];
+	const char *spd = "";
+
+	if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_2_5GB)
+		spd = " 2.5 GT/s";
+	else if (adap->params.pci.speed == PCI_EXP_LNKSTA_CLS_5_0GB)
+		spd = " 5 GT/s";
 
 	for_each_port(adap, i) {
 		struct net_device *dev = adap->port[i];
@@ -3099,10 +3105,10 @@ static void __devinit print_port_info(struct adapter *adap)
 			--bufp;
 		sprintf(bufp, "BASE-%s", base[pi->port_type]);
 
-		netdev_info(dev, "Chelsio %s rev %d %s %sNIC PCIe x%d%s\n",
+		netdev_info(dev, "Chelsio %s rev %d %s %sNIC PCIe x%d%s%s\n",
 			    adap->params.vpd.id, adap->params.rev,
 			    buf, is_offload(adap) ? "R" : "",
-			    adap->params.pci.width,
+			    adap->params.pci.width, spd,
 			    (adap->flags & USING_MSIX) ? " MSI-X" :
 			    (adap->flags & USING_MSI) ? " MSI" : "");
 		if (adap->name == dev->name)
-- 
1.5.4

