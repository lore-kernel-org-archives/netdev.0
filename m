From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 5/8] netxen: fix fw load from file
Date: Wed, 24 Mar 2010 06:29:20 -0700
Message-ID: <1269437363-2606-6-git-send-email-amit.salecha@qlogic.com>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:8867 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756227Ab0CXN3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 09:29:25 -0400
In-Reply-To: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fw file size can be unaligned to 8.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 9e89d28..06aa5ea 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1020,6 +1020,16 @@ netxen_load_firmware(struct netxen_adapter *adapter)
 
 			flashaddr += 8;
 		}
+
+		size = (__force u32)nx_get_fw_size(adapter) % 8;
+		if (size) {
+			data = cpu_to_le64(ptr64[i]);
+
+			if (adapter->pci_mem_write(adapter,
+						flashaddr, data))
+				return -EIO;
+		}
+
 	} else {
 		u64 data;
 		u32 hi, lo;
-- 
1.6.0.2

