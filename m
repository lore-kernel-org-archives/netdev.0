From: Patrick Simmons <linuxrocks123@netscape.net>
Subject: [PATCH] Add IRQF_SAMPLE_RANDOM Flag to forcedeth
Date: Sat, 09 Oct 2010 17:45:42 -0600
Message-ID: <4CB0FEA6.3030206@netscape.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr-da03.mx.aol.com ([205.188.105.145]:35105 "EHLO
	imr-da03.mx.aol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab0JIXpw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 19:45:52 -0400
Received: from mtaout-db06.r1000.mx.aol.com (mtaout-db06.r1000.mx.aol.com [172.29.51.198])
	by imr-da03.mx.aol.com (8.14.1/8.14.1) with ESMTP id o99Njh6u026474
	for <netdev@vger.kernel.org>; Sat, 9 Oct 2010 19:45:43 -0400
Received: from [10.0.0.104] (c-98-253-56-154.hsd1.il.comcast.net [98.253.56.154])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mtaout-db06.r1000.mx.aol.com (MUA/Third Party Client Interface) with ESMTPSA id 8FB95E0000EF
	for <netdev@vger.kernel.org>; Sat,  9 Oct 2010 19:45:43 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the IRQF_SAMPLE_RANDOM flag to the forcedeth driver, 
allowing the interrupt timing for forcedeth to be used for entropy 
generation.  This should help /dev/random generate more secure random 
numbers on machines using this driver.

Signed-off-by: Patrick Simmons <linuxrocks123@netscape.net>

Please CC me with any comments as I am not subscribed to the list.

--- linux/drivers/net/forcedeth.c.orig    2010-10-09 17:12:08.400000015 
-0600
+++ linux/drivers/net/forcedeth.c    2010-10-09 17:14:44.880000015 -0600
@@ -3819,7 +3819,7 @@ static int nv_request_irq(struct net_dev
                  /* Request irq for rx handling */
                  sprintf(np->name_rx, "%s-rx", dev->name);
                  if 
(request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector,
-                        nv_nic_irq_rx, IRQF_SHARED, np->name_rx, dev) 
!= 0) {
+                        nv_nic_irq_rx, IRQF_SHARED | 
IRQF_SAMPLE_RANDOM, np->name_rx, dev) != 0) {
                      printk(KERN_INFO "forcedeth: request_irq failed 
for rx %d\n", ret);
                      pci_disable_msix(np->pci_dev);
                      np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -3828,7 +3828,7 @@ static int nv_request_irq(struct net_dev
                  /* Request irq for tx handling */
                  sprintf(np->name_tx, "%s-tx", dev->name);
                  if 
(request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_TX].vector,
-                        nv_nic_irq_tx, IRQF_SHARED, np->name_tx, dev) 
!= 0) {
+                        nv_nic_irq_tx, IRQF_SHARED | 
IRQF_SAMPLE_RANDOM, np->name_tx, dev) != 0) {
                      printk(KERN_INFO "forcedeth: request_irq failed 
for tx %d\n", ret);
                      pci_disable_msix(np->pci_dev);
                      np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -3837,7 +3837,7 @@ static int nv_request_irq(struct net_dev
                  /* Request irq for link and timer handling */
                  sprintf(np->name_other, "%s-other", dev->name);
                  if 
(request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_OTHER].vector,
-                        nv_nic_irq_other, IRQF_SHARED, np->name_other, 
dev) != 0) {
+                        nv_nic_irq_other, IRQF_SHARED | 
IRQF_SAMPLE_RANDOM, np->name_other, dev) != 0) {
                      printk(KERN_INFO "forcedeth: request_irq failed 
for link %d\n", ret);
                      pci_disable_msix(np->pci_dev);
                      np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -3851,7 +3851,7 @@ static int nv_request_irq(struct net_dev
                  set_msix_vector_map(dev, NV_MSI_X_VECTOR_OTHER, 
NVREG_IRQ_OTHER);
              } else {
                  /* Request irq for all interrupts */
-                if 
(request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, 
IRQF_SHARED, dev->name, dev) != 0) {
+                if 
(request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, 
IRQF_SHARED | IRQF_SAMPLE_RANDOM, dev->name, dev) != 0) {
                      printk(KERN_INFO "forcedeth: request_irq failed 
%d\n", ret);
                      pci_disable_msix(np->pci_dev);
                      np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -3868,7 +3868,7 @@ static int nv_request_irq(struct net_dev
          if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
              np->msi_flags |= NV_MSI_ENABLED;
              dev->irq = np->pci_dev->irq;
-            if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, 
dev->name, dev) != 0) {
+            if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED | 
IRQF_SAMPLE_RANDOM, dev->name, dev) != 0) {
                  printk(KERN_INFO "forcedeth: request_irq failed %d\n", 
ret);
                  pci_disable_msi(np->pci_dev);
                  np->msi_flags &= ~NV_MSI_ENABLED;
@@ -3884,7 +3884,7 @@ static int nv_request_irq(struct net_dev
          }
      }
      if (ret != 0) {
-        if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, 
dev->name, dev) != 0)
+        if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED | 
IRQF_SAMPLE_RANDOM, dev->name, dev) != 0)
              goto out_err;

      }

