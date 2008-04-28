From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH] r8169: fix panic when using unlisted MAC
Date: Mon, 28 Apr 2008 13:22:09 -0400
Message-ID: <20080428172209.GE26591@gospo.usersys.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org, romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:42514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934280AbYD1RWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 13:22:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


When using the r8169 driver with an unlisted MAC, the system will
panic in rtl8169_get_mac_version since it will try to access tp->pci_dev
when it's unset.  Moving the call to set pci_dev earlier in
rtnl8169_init_one will resolve this and should not introduce any other
problems.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 3acfeea..0faa652 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1617,6 +1617,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	tp = netdev_priv(dev);
 	tp->dev = dev;
+	tp->pci_dev = pdev;
 	tp->msg_enable = netif_msg_init(debug.msg_enable, R8169_MSG_DEFAULT);
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
@@ -1777,7 +1778,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #endif
 
 	tp->intr_mask = 0xffff;
-	tp->pci_dev = pdev;
 	tp->mmio_addr = ioaddr;
 	tp->align = cfg->align;
 	tp->hw_start = cfg->hw_start;
-- 
1.5.2.1

