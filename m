From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH] sis190: failure to set the MAC address from EEPROM
Date: Thu, 18 Jan 2007 23:22:23 +0100
Message-ID: <20070118222223.GA23506@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, sleepy@mike-neko.net, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43845 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932639AbXARWYd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jan 2007 17:24:33 -0500
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix from http://bugzilla.kernel.org/show_bug.cgi?id=7747

Signed-off-by: Andrew Morton <akpm@osdl.org>
Cc: <sleepy@mike-neko.net>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/sis190.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index b70ed79..45d91b1 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1562,7 +1562,7 @@ static int __devinit sis190_get_mac_addr_from_eeprom(struct pci_dev *pdev,
 	for (i = 0; i < MAC_ADDR_LEN / 2; i++) {
 		__le16 w = sis190_read_eeprom(ioaddr, EEPROMMACAddr + i);
 
-		((u16 *)dev->dev_addr)[0] = le16_to_cpu(w);
+		((u16 *)dev->dev_addr)[i] = le16_to_cpu(w);
 	}
 
 	sis190_set_rgmii(tp, sis190_read_eeprom(ioaddr, EEPROMInfo));
-- 
1.4.4.4

