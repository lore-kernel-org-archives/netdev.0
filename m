From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e100: cleanup unneeded math
Date: Wed, 05 Dec 2007 11:57:37 -0800
Message-ID: <20071205195737.6859.11168.stgit@localhost.localdomain>
References: <20071205195729.6859.97796.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 12o3l@tiscali.nl
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50415 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589AbXLET7b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 14:59:31 -0500
In-Reply-To: <20071205195729.6859.97796.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to convert to bytes and back - cleanup unneeded code.

Adapted from fix from 'Roel Kluin <12o3l@tiscali.nl>'

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e100.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 9189aff..27f4d4a 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2284,13 +2284,11 @@ static void e100_get_drvinfo(struct net_device *netdev,
 	strcpy(info->bus_info, pci_name(nic->pdev));
 }
 
+#define E100_PHY_REGS 0x1C
 static int e100_get_regs_len(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
-#define E100_PHY_REGS		0x1C
-#define E100_REGS_LEN		1 + E100_PHY_REGS + \
-	sizeof(nic->mem->dump_buf) / sizeof(u32)
-	return E100_REGS_LEN * sizeof(u32);
+	return 1 + E100_PHY_REGS + sizeof(nic->mem->dump_buf);
 }
 
 static void e100_get_regs(struct net_device *netdev,
