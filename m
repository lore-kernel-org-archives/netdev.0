From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 4/8] netxen: fix bios version calculation
Date: Wed, 24 Mar 2010 06:29:19 -0700
Message-ID: <1269437363-2606-5-git-send-email-amit.salecha@qlogic.com>
References: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:21311 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1756246Ab0CXN3Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Mar 2010 09:29:25 -0400
In-Reply-To: <1269437363-2606-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bios sub version from unified fw image is calculated incorrect.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 80a99a0..9e89d28 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -892,7 +892,7 @@ nx_get_bios_version(struct netxen_adapter *adapter)
 	if (adapter->fw_type == NX_UNIFIED_ROMIMAGE) {
 		bios_ver = cpu_to_le32(*((u32 *) (&fw->data[prd_off])
 						+ NX_UNI_BIOS_VERSION_OFF));
-		return (bios_ver << 24) + ((bios_ver >> 8) & 0xff00) +
+		return (bios_ver << 16) + ((bios_ver >> 8) & 0xff00) +
 							(bios_ver >> 24);
 	} else
 		return cpu_to_le32(*(u32 *)&fw->data[NX_BIOS_VERSION_OFFSET]);
-- 
1.6.0.2

