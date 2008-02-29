From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH UPDATE]  add pcibios_enable_device() return value check
Date: Fri, 29 Feb 2008 11:45:46 +0900
Message-ID: <200802290245.m1T2jkPC014695@po-mbox300.hop.2iij.net>
References: <20080228221538.058d1f40.yoichi_yuasa@tripeaks.co.jp>
	<200802282254.52426.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo31.po.2iij.NET ([210.128.50.54]:7210 "EHLO mo31.po.2iij.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755627AbYB2Cpx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 21:45:53 -0500
In-Reply-To: <200802282254.52426.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

Thank you for your comment.
I updated it.

Yoichi

This patch has added pcibios_enable_device() return value check.

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/ssb/driver_pcicore.c linux/drivers/ssb/driver_pcicore.c
--- linux-orig/drivers/ssb/driver_pcicore.c	2008-02-29 09:39:39.355620210 +0900
+++ linux/drivers/ssb/driver_pcicore.c	2008-02-29 10:59:18.649231996 +0900
@@ -111,7 +111,10 @@ static void __init ssb_fixup_pcibridge(s
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
-	pcibios_enable_device(dev, ~0);
+	if (pcibios_enable_device(dev, ~0) < 0) {
+		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
+		return;
+	}
 
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
