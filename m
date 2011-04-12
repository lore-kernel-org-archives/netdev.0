From: Prabhakar Kushwaha <prabhakar@freescale.com>
Subject: [PATCH] driver/e1000e: Fix default interrupt mode select
Date: Tue, 12 Apr 2011 10:26:03 +0530
Message-ID: <1302584163-22318-1-git-send-email-prabhakar@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <meet2prabhu@gmail.com>, Prabhakar <prabhakar@freescale.com>,
	Jin Qing <b24347@freescale.com>
To: <linuxppc-dev@lists.ozlabs.org>, <linux.nics@intel.com>,
	<auke-jan.h.kok@intel.com>, <e1000-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:58111 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab1DLE4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:56:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prabhakar <prabhakar@freescale.com>

The Intel e1000 device driver defaults to MSI interrupt mode, even if MSI
support is not enabled

Signed-off-by: Jin Qing <b24347@freescale.com>
Signed-off-by: Prabhakar Kushwaha <prabhakar@freescale.com>
---
 Based upon git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git(branch master)

 added  netdev mail-list and e1000 mail-list & maintainer

 drivers/net/e1000e/param.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index a150e48..7b3bbec 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -390,7 +390,11 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 			.type = range_option,
 			.name = "Interrupt Mode",
 			.err  = "defaulting to 2 (MSI-X)",
+#ifdef CONFIG_PCI_MSI
 			.def  = E1000E_INT_MODE_MSIX,
+#else
+			.def  = E1000E_INT_MODE_LEGACY,
+#endif
 			.arg  = { .r = { .min = MIN_INTMODE,
 					 .max = MAX_INTMODE } }
 		};
-- 
1.7.3


