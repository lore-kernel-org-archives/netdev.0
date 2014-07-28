From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net] bna: fill the magic in bnad_get_eeprom() instead of validating
Date: Mon, 28 Jul 2014 15:03:52 +0200
Message-ID: <1406552632-1201-1-git-send-email-ivecera@redhat.com>
Cc: rmody@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18579 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752150AbaG1NDz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jul 2014 09:03:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A driver should fill magic field of ethtool_eeprom struct in .get_eeprom
and validate it in .set_eeprom. The bna incorrectly validates it in both
and this makes its .get_eeprom interface unusable.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 882cad7..d26adac 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -997,10 +997,8 @@ bnad_get_eeprom(struct net_device *netdev, struct ethtool_eeprom *eeprom,
 	unsigned long flags = 0;
 	int ret = 0;
 
-	/* Check if the flash read request is valid */
-	if (eeprom->magic != (bnad->pcidev->vendor |
-			     (bnad->pcidev->device << 16)))
-		return -EFAULT;
+	/* Fill the magic value */
+	eeprom->magic = bnad->pcidev->vendor | (bnad->pcidev->device << 16);
 
 	/* Query the flash partition based on the offset */
 	flash_part = bnad_get_flash_partition_by_offset(bnad,
-- 
1.8.5.5
