From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 1/2] af_ieee802154: fix check on broadcast address
Date: Thu, 20 Mar 2014 14:57:02 +0100
Message-ID: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, phoebe.buckheister@itwm.fraunhofer.de,
	jlu@pengutronix.de, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:61191 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264AbaCTN5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 09:57:19 -0400
Received: by mail-ee0-f47.google.com with SMTP id b15so687916eek.20
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 06:57:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes an issue which was introduced by commit
(b70ab2e87f17176d18f67ef331064441a032b5f3).

The correct behaviour should be a check on the broadcast address field
which is 0xffff.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
Reported-by: Jan Luebbe <jlu@pengutronix.de>
Cc: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 net/ieee802154/af_ieee802154.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
index be44a86..351d9a9 100644
--- a/net/ieee802154/af_ieee802154.c
+++ b/net/ieee802154/af_ieee802154.c
@@ -63,7 +63,7 @@ ieee802154_get_dev(struct net *net, const struct ieee802154_addr *addr)
 	case IEEE802154_ADDR_SHORT:
 		if (addr->pan_id == cpu_to_le16(IEEE802154_PANID_BROADCAST) ||
 		    addr->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF) ||
-		    addr->short_addr == cpu_to_le16(IEEE802154_ADDR_UNDEF))
+		    addr->short_addr == cpu_to_le16(IEEE802154_ADDR_BROADCAST))
 			break;
 
 		rtnl_lock();
-- 
1.9.0
