From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH] atm: nicstar: fix regression made by previous patch
Date: Fri, 13 Sep 2013 18:00:58 +0300
Message-ID: <1379084458-23793-1-git-send-email-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: Chas Williams <chas@cmf.nrl.navy.mil>,
	linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:20789 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756215Ab3IMPBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Sep 2013 11:01:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 8390f814 "atm: nicstar: re-use native mac_pton() helper" did a
usefull thing. However, mac_pton() returns 1 in the case of the successfully
parsed input. This patch fixes a typo.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/atm/nicstar.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/atm/nicstar.c b/drivers/atm/nicstar.c
index 409502a..5aca5f4 100644
--- a/drivers/atm/nicstar.c
+++ b/drivers/atm/nicstar.c
@@ -778,7 +778,7 @@ static int ns_init_card(int i, struct pci_dev *pcidev)
 		return error;
 	}
 
-	if (mac[i] == NULL || mac_pton(mac[i], card->atmdev->esi)) {
+	if (mac[i] == NULL || !mac_pton(mac[i], card->atmdev->esi)) {
 		nicstar_read_eprom(card->membase, NICSTAR_EPROM_MAC_ADDR_OFFSET,
 				   card->atmdev->esi, 6);
 		if (memcmp(card->atmdev->esi, "\x00\x00\x00\x00\x00\x00", 6) ==
-- 
1.8.4.rc3
