From: Werner Almesberger <werner@almesberger.net>
Subject: [PATCH net-next 1/2] IEEE 802.15.4: remove get_bsn from "struct
 ieee802154_mlme_ops"
Date: Thu, 4 Apr 2013 13:32:12 -0300
Message-ID: <0513f7b711c51d695f983aeb8a4631879076bb79.1365092820.git.werner@almesberger.net>
References: <cover.1365092820.git.werner@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.openmoko.org ([88.198.124.205]:38755 "EHLO
	mail.openmoko.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762997Ab3DDQdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 12:33:12 -0400
Content-Disposition: inline
In-Reply-To: <cover.1365092820.git.werner@almesberger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It served no purpose: we never call it from anywhere in the stack
and the only driver that did implement it (fakehard) merely provided
a dummy value.

There is also considerable doubt whether it would make sense to
even attempt beacon processing at this level in the Linux kernel.

Signed-off-by: Werner Almesberger <werner@almesberger.net>
---
 drivers/net/ieee802154/fakehard.c |   21 ---------------------
 include/net/ieee802154_netdev.h   |    1 -
 2 files changed, 22 deletions(-)

diff --git a/drivers/net/ieee802154/fakehard.c b/drivers/net/ieee802154/fakehard.c
index 8f1c256..bf0d55e 100644
--- a/drivers/net/ieee802154/fakehard.c
+++ b/drivers/net/ieee802154/fakehard.c
@@ -106,26 +106,6 @@ static u8 fake_get_dsn(const struct net_device *dev)
 }
 
 /**
- * fake_get_bsn - Retrieve the BSN of the device.
- * @dev: The network device to retrieve the BSN for.
- *
- * Returns the IEEE 802.15.4 BSN for the network device.
- * The BSN is the sequence number which will be added to each
- * beacon frame sent by the MAC.
- *
- * BSN means 'Beacon Sequence Number'.
- *
- * Note: This is in section 7.2.1.2 of the IEEE 802.15.4-2006
- *       document.
- */
-static u8 fake_get_bsn(const struct net_device *dev)
-{
-	BUG_ON(dev->type != ARPHRD_IEEE802154);
-
-	return 0x00; /* BSN are implemented in HW, so return just 0 */
-}
-
-/**
  * fake_assoc_req - Make an association request to the HW.
  * @dev: The network device which we are associating to a network.
  * @addr: The coordinator with which we wish to associate.
@@ -264,7 +244,6 @@ static struct ieee802154_mlme_ops fake_mlme = {
 	.get_pan_id = fake_get_pan_id,
 	.get_short_addr = fake_get_short_addr,
 	.get_dsn = fake_get_dsn,
-	.get_bsn = fake_get_bsn,
 };
 
 static int ieee802154_fake_open(struct net_device *dev)
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index d104c88..642f94c 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -110,7 +110,6 @@ struct ieee802154_mlme_ops {
 	u16 (*get_pan_id)(const struct net_device *dev);
 	u16 (*get_short_addr)(const struct net_device *dev);
 	u8 (*get_dsn)(const struct net_device *dev);
-	u8 (*get_bsn)(const struct net_device *dev);
 };
 
 /* The IEEE 802.15.4 standard defines 2 type of the devices:
-- 
1.7.10.4
