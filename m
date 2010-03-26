From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 1/4] netxen: fix bios version calculation
Date: Fri, 26 Mar 2010 03:30:07 -0700
Message-ID: <1269599410-17809-2-git-send-email-amit.salecha@qlogic.com>
References: <1269599410-17809-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:58798 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753325Ab0CZKaO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Mar 2010 06:30:14 -0400
In-Reply-To: <1269599410-17809-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bios sub version from unified fw image is calculated incorrect.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 1c63610..7eb925a 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -761,7 +761,7 @@ nx_get_bios_version(struct netxen_adapter *adapter)
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

