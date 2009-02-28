From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 1/4] jme: Modifies messages to display correct hardware version
Date: Sat, 28 Feb 2009 11:54:07 +0800
Message-ID: <20090228035408.M42101@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:33366 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912AbZB1DzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 22:55:20 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch modifies messages to display correct hardware version.
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index 08b3405..60cb997 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -2856,7 +2856,11 @@ jme_init_one(struct pci_dev *pdev,
 		goto err_out_free_shadow;
 	}
 
-	msg_probe(jme, "JMC250 gigabit%s ver:%x rev:%x macaddr:%pM\n",
+	msg_probe(jme, "%s%s ver:%x rev:%x macaddr:%pM\n",
+		(jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC250) ?
+			"JMC250 Gigabit Ethernet" :
+			(jme->pdev->device == PCI_DEVICE_ID_JMICRON_JMC260) ?
+				"JMC260 Fast Ethernet" : "Unknown",
 		(jme->fpgaver != 0) ? " (FPGA)" : "",
 		(jme->fpgaver != 0) ? jme->fpgaver : jme->chiprev,
 		jme->rev, netdev->dev_addr);
@@ -3002,7 +3006,7 @@ static struct pci_driver jme_driver = {
 static int __init
 jme_init_module(void)
 {
-	printk(KERN_INFO PFX "JMicron JMC250 gigabit ethernet "
+	printk(KERN_INFO PFX "JMicron JMC2XX ethernet "
 	       "driver version %s\n", DRV_VERSION);
 	return pci_register_driver(&jme_driver);
 }


