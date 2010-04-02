From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 1/9] qlcnic: fix fw load from file
Date: Thu,  1 Apr 2010 22:01:28 -0700
Message-ID: <1270184496-18985-2-git-send-email-amit.salecha@qlogic.com>
References: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:28428 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754590Ab0DBFBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Apr 2010 01:01:38 -0400
In-Reply-To: <1270184496-18985-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rarely: Fw file size can be unaligned to 8.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_init.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 7c34e4e..0a424e0 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -949,6 +949,16 @@ qlcnic_load_firmware(struct qlcnic_adapter *adapter)
 
 			flashaddr += 8;
 		}
+
+		size = (__force u32)qlcnic_get_fw_size(adapter) % 8;
+		if (size) {
+			data = cpu_to_le64(ptr64[i]);
+
+			if (qlcnic_pci_mem_write_2M(adapter,
+						flashaddr, data))
+				return -EIO;
+		}
+
 	} else {
 		u64 data;
 		u32 hi, lo;
-- 
1.6.0.2

