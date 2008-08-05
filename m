From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: [PATCH] netxen_nic_hw.c: fix warnings
Date: Wed, 6 Aug 2008 00:05:16 +0400
Message-ID: <20080805200516.GB17320@orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: dhananjay@netxen.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:55027 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761632AbYHEUFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 16:05:32 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1375442fgg.17
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 13:05:24 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Beregalov <a.beregalov@gmail.com>

netxen_nic_hw.c: fix warnings

drivers/net/netxen/netxen_nic_hw.c:1414: warning: format '%llx' expects	type 'long long unsigned int', but argument 3 has type 'u64'
drivers/net/netxen/netxen_nic_hw.c:1487: warning: format '%llx' expects type 'long long unsigned int', but argument 3 has type 'u64'


Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
---

 drivers/net/netxen/netxen_nic_hw.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 96a3bc6..06a517b 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1411,7 +1411,8 @@ static int netxen_nic_pci_mem_read_direct(struct netxen_adapter *adapter,
 		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+			"offset is 0x%llx\n", netxen_nic_driver_name,
+			(unsigned long long)off);
 		return -1;
 	}
 
@@ -1484,7 +1485,8 @@ netxen_nic_pci_mem_write_direct(struct netxen_adapter *adapter, u64 off,
 		(netxen_nic_pci_is_same_window(adapter, off+size-1) == 0)) {
 		write_unlock_irqrestore(&adapter->adapter_lock, flags);
 		printk(KERN_ERR "%s out of bound pci memory access. "
-			"offset is 0x%llx\n", netxen_nic_driver_name, off);
+			"offset is 0x%llx\n", netxen_nic_driver_name,
+			(unsigned long long)off);
 		return -1;
 	}
 
