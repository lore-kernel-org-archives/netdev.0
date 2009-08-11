From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 2/6] r8169: differentiate close chipsets in the
	startup identification message
Date: Tue, 11 Aug 2009 07:42:37 +0200
Message-ID: <20090811054236.GC16446@electric-eye.fr.zoreil.com>
References: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: edward_hsu@realtek.com.tw, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:60940 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750847AbZHKLvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 07:51:00 -0400
Content-Disposition: inline
In-Reply-To: <20090811054039.GA16446@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver displays the same 0x18000000 xid for RTL_GIGA_MAC_VER_06
and RTL_GIGA_MAC_VER_05 whereas the former ought to be identified as
0x98000000.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index eac882b..6c4b879 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2180,7 +2180,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	pci_set_drvdata(pdev, dev);
 
 	if (netif_msg_probe(tp)) {
-		u32 xid = RTL_R32(TxConfig) & 0x7cf0f8ff;
+		u32 xid = RTL_R32(TxConfig) & 0x9cf0f8ff;
 
 		printk(KERN_INFO "%s: %s at 0x%lx, "
 		       "%2.2x:%2.2x:%2.2x:%2.2x:%2.2x:%2.2x, "
-- 
1.6.2.5

