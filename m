From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 7/8] cxgb4: Use vmalloc, if kmalloc fails
Date: Wed, 21 Oct 2015 14:39:56 +0530
Message-ID: <1445418597-771-8-git-send-email-hariprasad@chelsio.com>
References: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.115.98]:1553 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754165AbbJUJKL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 05:10:11 -0400
In-Reply-To: <1445418597-771-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
index 59374dc..43e0bc5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_ethtool.c
@@ -851,7 +851,7 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 {
 	int i, err = 0;
 	struct adapter *adapter = netdev2adap(dev);
-	u8 *buf = kmalloc(EEPROMSIZE, GFP_KERNEL);
+	u8 *buf = t4_alloc_mem(EEPROMSIZE);
 
 	if (!buf)
 		return -ENOMEM;
@@ -862,7 +862,7 @@ static int get_eeprom(struct net_device *dev, struct ethtool_eeprom *e,
 
 	if (!err)
 		memcpy(data, buf + e->offset, e->len);
-	kfree(buf);
+	t4_free_mem(buf);
 	return err;
 }
 
@@ -891,7 +891,7 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	if (aligned_offset != eeprom->offset || aligned_len != eeprom->len) {
 		/* RMW possibly needed for first or last words.
 		 */
-		buf = kmalloc(aligned_len, GFP_KERNEL);
+		buf = t4_alloc_mem(aligned_len);
 		if (!buf)
 			return -ENOMEM;
 		err = eeprom_rd_phys(adapter, aligned_offset, (u32 *)buf);
@@ -919,7 +919,7 @@ static int set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 		err = t4_seeprom_wp(adapter, true);
 out:
 	if (buf != data)
-		kfree(buf);
+		t4_free_mem(buf);
 	return err;
 }
 
-- 
2.3.4
