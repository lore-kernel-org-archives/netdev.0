From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 2/2] drivers/net/netxen/netxen_nic_hw.c: fix printk warnings
Date: Wed, 30 Jul 2008 12:50:12 -0700
Message-ID: <200807301950.m6UJoDY4013256@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48224 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755664AbYG3TvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 15:51:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>

drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_read_direct':
drivers/net/netxen/netxen_nic_hw.c:1414: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'
drivers/net/netxen/netxen_nic_hw.c: In function 'netxen_nic_pci_mem_write_direct':
drivers/net/netxen/netxen_nic_hw.c:1487: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'

You don't know what type was used for u64 hence they cannot be printed without
casting.

Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/netxen/netxen_nic_hw.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN drivers/net/netxen/netxen_nic_hw.c~drivers-net-netxen-netxen_nic_hwc-fix-printk-warnings drivers/net/netxen/netxen_nic_hw.c
--- a/drivers/net/netxen/netxen_nic_hw.c~drivers-net-netxen-netxen_nic_hwc-fix-printk-warnings
+++ a/drivers/net/netxen/netxen_nic_hw.c
@@ -1411,7 +1411,8 @@ static int netxen_nic_pci_mem_read_direc
 		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+			"offset is 0x%llx\n", netxen_nic_driver_name,
+			(unsigned long long)off);
 		return -1;
 	}
 
@@ -1484,7 +1485,8 @@ netxen_nic_pci_mem_write_direct(struct n
 		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+			"offset is 0x%llx\n", netxen_nic_driver_name,
+			(unsigned long long)off);
 		return -1;
 	}
 
_
