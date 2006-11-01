From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ipw2100: remove _must_check warning
Date: Wed, 01 Nov 2006 14:10:52 -0600
Message-ID: <4548FF4C.mail76S1O9FFV@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-04.rdc-kc.rr.com ([24.94.166.116]:30360 "EHLO
	ms-smtp-04.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1752297AbWKAULM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 15:11:12 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In kernel 2.6.19, there is a configuration option that enables the _must_check
logic. This patch adds a check and removes the warning for a pci_enable_device
call in the ipw2100 driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
Index: wireless-2.6/drivers/net/wireless/ipw2100.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/ipw2100.c
+++ wireless-2.6/drivers/net/wireless/ipw2100.c
@@ -6424,6 +6424,7 @@ static int ipw2100_resume(struct pci_dev
 	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
 	struct net_device *dev = priv->net_dev;
 	u32 val;
+	int err;
 
 	if (IPW2100_PM_DISABLED)
 		return 0;
@@ -6433,7 +6434,9 @@ static int ipw2100_resume(struct pci_dev
 	IPW_DEBUG_INFO("%s: Coming out of suspend...\n", dev->name);
 
 	pci_set_power_state(pci_dev, PCI_D0);
-	pci_enable_device(pci_dev);
+	err = pci_enable_device(pci_dev);
+	if (err)
+		return err;
 	pci_restore_state(pci_dev);
 
 	/*
