From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 2/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:28 +0900
Message-ID: <20060613081930.370601000@localhost.localdomain>
References: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:23275 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750748AbWFMIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:40 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-ports.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [RFT 2/5] sky2: don't hard code number of ports

It is cleaner, to not loop over both ports if only one exists.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -3430,7 +3430,7 @@ static int sky2_suspend(struct pci_dev *
 	if (!(pstate == PCI_D3hot || pstate == PCI_D3cold))
 		return -EINVAL;
 
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 
 		if (dev) {
@@ -3460,7 +3460,7 @@ static int sky2_resume(struct pci_dev *p
 	if (err)
 		goto out;
 
-	for (i = 0; i < 2; i++) {
+	for (i = 0; i < hw->ports; i++) {
 		struct net_device *dev = hw->dev[i];
 		if (dev && netif_running(dev)) {
 			netif_device_attach(dev);

--

