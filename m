From: Dave Jones <davej@redhat.com>
Subject: [2/3] 8139too: Force usage of PIO on OQO2
Date: Tue, 15 Jul 2008 19:54:53 -0400
Message-ID: <200807152354.m6FNsre3026948@gelk.kernelslacker.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40654 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754084AbYGPABZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2008 20:01:25 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m6G01O94018272
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01OJK000649
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:24 -0400
Received: from gelk.kernelslacker.org (vpn-12-217.rdu.redhat.com [10.11.12.217])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m6G01Ng5007000
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 20:01:23 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.2/8.14.2) with ESMTP id m6FNsriC026949
	for <netdev@vger.kernel.org>; Tue, 15 Jul 2008 19:54:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The OQO model 2 has an RTL8139 from Atheros that doesn't like MMIO.
It fails on modprobe, with a 'PCI Bus error' message.

Force it to always use polled IO.

Signed-off-by: Dave Jones <davej@redhat.com>

--- linux-2.6.25.noarch/drivers/net/8139too.c~	2008-05-28 21:07:36.000000000 -0400
+++ linux-2.6.25.noarch/drivers/net/8139too.c	2008-05-28 21:19:57.000000000 -0400
@@ -951,6 +951,14 @@ static int __devinit rtl8139_init_one (s
 			   "Use the \"8139cp\" driver for improved performance and stability.\n");
 	}
 
+	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
+	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 &&
+	    pdev->subsystem_vendor == PCI_VENDOR_ID_ATHEROS &&
+	    pdev->subsystem_device == PCI_DEVICE_ID_REALTEK_8139) {
+		printk(KERN_INFO "8139too: OQO Model 2 detected. Forcing PIO\n");
+		use_io = 1;
+	}
+
 	i = rtl8139_init_board (pdev, &dev);
 	if (i < 0)
 		return i;
