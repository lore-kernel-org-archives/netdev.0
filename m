From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] ipw2200: remove _must_check warning
Date: Wed, 01 Nov 2006 14:10:28 -0600
Message-ID: <4548FF34.mail76I11BQH0@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yi.zhu@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ms-smtp-02.rdc-kc.rr.com ([24.94.166.122]:43914 "EHLO
	ms-smtp-02.rdc-kc.rr.com") by vger.kernel.org with ESMTP
	id S1752308AbWKAULP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Nov 2006 15:11:15 -0500
To: John Linville <linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In kernel 2.6.19, there is a configuration option that enables the _must_check
logic. This patch adds a check and removes the warning for a pci_enable_device
call in the ipw2200 driver.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---

Index: wireless-2.6/drivers/net/wireless/ipw2200.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/ipw2200.c
+++ wireless-2.6/drivers/net/wireless/ipw2200.c
@@ -11728,11 +11728,14 @@ static int ipw_pci_resume(struct pci_dev
 	struct ipw_priv *priv = pci_get_drvdata(pdev);
 	struct net_device *dev = priv->net_dev;
 	u32 val;
+	int err;
 
 	printk(KERN_INFO "%s: Coming out of suspend...\n", dev->name);
 
 	pci_set_power_state(pdev, PCI_D0);
-	pci_enable_device(pdev);
+	err = pci_enable_device(pdev);
+	if (err)
+		return err;
 	pci_restore_state(pdev);
 
 	/*
