From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH] ipv6 addrconf: Fix addrconf_ifid_eui64 of 802.15.4 devices
Date: Thu,  7 Mar 2013 21:13:03 +0100
Message-ID: <1362687183-3425-1-git-send-email-alex.aring@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	Alexander Aring <alex.aring@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:42846 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab3CGUMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 15:12:15 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so669273eek.41
        for <netdev@vger.kernel.org>; Thu, 07 Mar 2013 12:12:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function addrconf_ifid_eui64 will copy eui into dev->dev_addr.
We need first to manipulate eui[0] before we call memcpy afterwards.

Broken since commit:
5e98a36ed4bf6ea396170e3af0dd4fcbe51d772f

Since this commit I got many trouble with the ieee802154 stack.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 net/ipv6/addrconf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fa36a67..4460237 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1731,8 +1731,8 @@ static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != IEEE802154_ADDR_LEN)
 		return -1;
-	memcpy(eui, dev->dev_addr, 8);
 	eui[0] ^= 2;
+	memcpy(eui, dev->dev_addr, 8);
 	return 0;
 }
 
-- 
1.8.1.5
