From: Ralf Baechle <ralf@linux-mips.org>
Subject: [IOC3] Fix section missmatch
Date: Sat, 8 Mar 2008 16:58:33 +0000
Message-ID: <20080308165833.GA8625@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Jeff Garzik <jeff@garzik.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, linux-mips@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftp.linux-mips.org ([194.74.144.162]:58568 "EHLO
	ftp.linux-mips.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752079AbYCHQ6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Mar 2008 11:58:37 -0500
Received: from localhost.localdomain ([127.0.0.1]:721 "EHLO
	dl5rb.ham-radio-op.net") by ftp.linux-mips.org with ESMTP
	id S28645951AbYCHQ6f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Mar 2008 16:58:35 +0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  LD      drivers/net/built-in.o
WARNING: drivers/net/built-in.o(.text+0x3468): Section mismatch in reference fro
m the function ioc3_probe() to the function .devinit.text:ioc3_serial_probe()
The function ioc3_probe() references
the function __devinit ioc3_serial_probe().
This is often because ioc3_probe lacks a __devinit 
annotation or the annotation of ioc3_serial_probe is wrong.

Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

---
Resend, this time with Jeff's address corrected.

diff --git a/drivers/net/ioc3-eth.c b/drivers/net/ioc3-eth.c
index 373f72c..1f25263 100644
--- a/drivers/net/ioc3-eth.c
+++ b/drivers/net/ioc3-eth.c
@@ -1221,7 +1221,8 @@ static void __devinit ioc3_serial_probe(struct pci_dev *pdev, struct ioc3 *ioc3)
 }
 #endif
 
-static int ioc3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
+static int __devinit ioc3_probe(struct pci_dev *pdev,
+	const struct pci_device_id *ent)
 {
 	unsigned int sw_physid1, sw_physid2;
 	struct net_device *dev = NULL;

----- End forwarded message -----

  Ralf
