From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 1/9] pcnet32: Fix Section mismatch error
Date: Thu, 29 Jun 2006 13:52:29 -0700
Message-ID: <20060629205229.GA21991@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:21707 "EHLO e5.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1751300AbWF2UwO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 16:52:14 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5TKqDEo013691
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:52:13 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5TKqDN6284692
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:52:13 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5TKqDr9003129
	for <netdev@vger.kernel.org>; Thu, 29 Jun 2006 16:52:13 -0400
To: tsbogend@alpha.franken.de, jgarzik@pobox.com,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix Section mismatch error.  Tested ia32 and ppc64.

Signed-off-by:  Don Fry <brazilnut@us.ibm.com>

--- linux-2.6.17-git13/drivers/net/orig.pcnet32.c	Wed Jun 28 10:38:46 2006
+++ linux-2.6.17-git13/drivers/net/pcnet32.c	Wed Jun 28 11:03:38 2006
@@ -277,7 +277,6 @@ struct pcnet32_private {
 	u32			phymask;
 };
 
-static void pcnet32_probe_vlbus(void);
 static int pcnet32_probe_pci(struct pci_dev *, const struct pci_device_id *);
 static int pcnet32_probe1(unsigned long, int, struct pci_dev *);
 static int pcnet32_open(struct net_device *);
@@ -952,7 +951,7 @@ static struct ethtool_ops pcnet32_ethtoo
 /* only probes for non-PCI devices, the rest are handled by
  * pci_register_driver via pcnet32_probe_pci */
 
-static void __devinit pcnet32_probe_vlbus(void)
+static void __devinit pcnet32_probe_vlbus(unsigned int *pcnet32_portlist)
 {
 	unsigned int *port, ioaddr;
 
@@ -2730,7 +2729,7 @@ static int __init pcnet32_init_module(vo
 
 	/* should we find any remaining VLbus devices ? */
 	if (pcnet32vlb)
-		pcnet32_probe_vlbus();
+		pcnet32_probe_vlbus(pcnet32_portlist);
 
 	if (cards_found && (pcnet32_debug & NETIF_MSG_PROBE))
 		printk(KERN_INFO PFX "%d cards_found.\n", cards_found);
-- 
Don Fry
brazilnut@us.ibm.com
