From: Dave Jones <davej@redhat.com>
Subject: [PATCH 2/2] 8139too: Make the OQO2 automatically use PIO mode.
Date: Thu, 29 May 2008 11:08:49 -0400
Message-ID: <20080529150849.GC8247@redhat.com>
References: <20080429171403.GA21035@redhat.com> <48177905.4000409@garzik.org> <20080429215626.GC2859@redhat.com> <48179B56.7000606@garzik.org> <20080429153240.7200e1a3.akpm@linux-foundation.org> <4818546C.4060703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:59270 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753856AbYE2PQS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 11:16:18 -0400
Content-Disposition: inline
In-Reply-To: <4818546C.4060703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The OQO model 2 has an RTL8139 from Atheros that doesn't like MMIO.
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
+		use_pio = 1;
+	}
+
 	i = rtl8139_init_board (pdev, &dev);
 	if (i < 0)
 		return i;

-- 
http://www.codemonkey.org.uk
