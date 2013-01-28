From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net] ipv6 addrconf: Fix interface identifiers of 802.15.4
 devices.
Date: Tue, 29 Jan 2013 05:44:29 +0900
Message-ID: <5106E32D.1080309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:45293 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752049Ab3A1Uoc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jan 2013 15:44:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The "Universal/Local" (U/L) bit must be complmented according to RFC4944
and RFC2464.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/addrconf.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 420e563..1b5d8cb 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -1660,6 +1660,7 @@ static int addrconf_ifid_eui64(u8 *eui, struct net_device *dev)
 	if (dev->addr_len != IEEE802154_ADDR_LEN)
 		return -1;
 	memcpy(eui, dev->dev_addr, 8);
+	eui[0] ^= 2;
 	return 0;
 }
 
-- 
1.7.9.5
