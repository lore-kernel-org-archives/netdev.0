From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH 1/3] netxen: fix i2c init
Date: Wed, 21 Oct 2009 22:39:01 -0700
Message-ID: <1256189943-20477-2-git-send-email-dhananjay@netxen.com>
References: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:24196 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751815AbZJVFjA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Oct 2009 01:39:00 -0400
In-Reply-To: <1256189943-20477-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid resetting subsys ID in i2c block. Also remove duplicate
check for address tranlsation error.

Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_hdr.h  |    1 +
 drivers/net/netxen/netxen_nic_init.c |    8 ++------
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 7a71774..1c46da6 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -419,6 +419,7 @@ enum {
 #define NETXEN_CRB_ROMUSB	\
 	NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_ROMUSB)
 #define NETXEN_CRB_I2Q		NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_I2Q)
+#define NETXEN_CRB_I2C0		NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_I2C0)
 #define NETXEN_CRB_SMB		NETXEN_PCI_CRB_WINDOW(NETXEN_HW_PX_MAP_CRB_SMB)
 #define NETXEN_CRB_MAX		NETXEN_PCI_CRB_WINDOW(64)
 
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 91c2bc6..e40b914 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -531,6 +531,8 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 			continue;
 
 		if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+			if (off == (NETXEN_CRB_I2C0 + 0x1c))
+				continue;
 			/* do not reset PCI */
 			if (off == (ROMUSB_GLB + 0xbc))
 				continue;
@@ -553,12 +555,6 @@ int netxen_pinit_from_rom(struct netxen_adapter *adapter, int verbose)
 				continue;
 		}
 
-		if (off == NETXEN_ADDR_ERROR) {
-			printk(KERN_ERR "%s: Err: Unknown addr: 0x%08x\n",
-					netxen_nic_driver_name, buf[i].addr);
-			continue;
-		}
-
 		init_delay = 1;
 		/* After writing this register, HW needs time for CRB */
 		/* to quiet down (else crb_window returns 0xffffffff) */
-- 
1.6.0.2

