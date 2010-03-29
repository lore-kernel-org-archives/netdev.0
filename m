From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 4/5] netxen: fix fw load from file
Date: Mon, 29 Mar 2010 05:43:44 -0700
Message-ID: <1269866625-26151-5-git-send-email-amit.salecha@qlogic.com>
References: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:51320 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751445Ab0C2Mnq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Mar 2010 08:43:46 -0400
In-Reply-To: <1269866625-26151-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rarely: Fw file size can be unaligned to 8.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 141bc43..439f3e8 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1019,6 +1019,16 @@ netxen_load_firmware(struct netxen_adapter *adapter)
 
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

