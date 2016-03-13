From: Corcodel Marian <asd@marian1000.go.ro>
Subject: [PATCH 2/2 net v3.16]r8169:  Remove unusued interrupts
Date: Sun, 13 Mar 2016 11:32:49 +0200
Message-ID: <1457861569-1844-2-git-send-email-asd@marian1000.go.ro>
References: <1457861569-1844-1-git-send-email-asd@marian1000.go.ro>
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Corcodel Marian <asd@marian1000.go.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5-14-231-86.residential.rdsnet.ro ([5.14.231.86]:44109 "EHLO
	marian1000.go.ro" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752357AbcCMJwT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 05:52:19 -0400
In-Reply-To: <1457861569-1844-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This patch remove unhandled interupt comparing for existence on PCI
 register.

Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>
---
 drivers/net/ethernet/realtek/r8169.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index ec555e7..eba2253 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -7208,6 +7208,9 @@ rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	tp->opts1_mask = (tp->mac_version != RTL_GIGA_MAC_VER_01) ?
 		~(RxBOVF | RxFOVF) : ~0;
 
+	if (!(cmd & PCI_COMMAND_SERR))
+		tp->event_slow &= ~SYSErr;
+
 	init_timer(&tp->timer);
 	tp->timer.data = (unsigned long) dev;
 	tp->timer.function = rtl8169_phy_timer;
-- 
2.1.4
