From: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>
Subject: [PATCH]  add pcibios_enable_device() return value check
Date: Thu, 28 Feb 2008 22:15:38 +0900
Message-ID: <20080228221538.058d1f40.yoichi_yuasa@tripeaks.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoichi_yuasa@tripeaks.co.jp, netdev@vger.kernel.org
To: mb@bu3sch.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mfo31.po.2iij.NET ([210.128.50.52]:19887 "EHLO
	mfo31.po.2iij.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751906AbYB1OCd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 09:02:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch has added pcibios_enable_device() return value check.

Signed-off-by: Yoichi Yuasa <yoichi_yuasa@tripeaks.co.jp>

diff -pruN -X /home/yuasa/Memo/dontdiff linux-orig/drivers/ssb/driver_pcicore.c linux/drivers/ssb/driver_pcicore.c
--- linux-orig/drivers/ssb/driver_pcicore.c	2008-02-26 15:51:13.146734949 +0900
+++ linux/drivers/ssb/driver_pcicore.c	2008-02-26 15:54:29.257910690 +0900
@@ -111,7 +111,8 @@ static void __init ssb_fixup_pcibridge(s
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
-	pcibios_enable_device(dev, ~0);
+	if (pcibios_enable_device(dev, ~0) < 0)
+		return;
 
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
