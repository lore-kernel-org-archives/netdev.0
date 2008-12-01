From: akpm@linux-foundation.org
Subject: [patch 5/5] hysdn: fix writing outside the field on 64 bits
Date: Mon, 01 Dec 2008 14:24:25 -0800
Message-ID: <200812012224.mB1MOPxA014993@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	pterjan@mandriva.com
To: kkeil@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54828 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752727AbYLAWZD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:25:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pascal Terjan <pterjan@mandriva.com>

ifa_local is assumed to be unsigned long which lead to writing the address
at dev->dev_addr-2 instead of +2

noticed thanks to gcc:

drivers/isdn/hysdn/hysdn_net.c: In function `net_open':
drivers/isdn/hysdn/hysdn_net.c:91: warning: array subscript is below array bounds

Signed-off-by: Pascal Terjan <pterjan@mandriva.com>
Cc: Karsten Keil <kkeil@suse.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/hysdn/hysdn_net.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN drivers/isdn/hysdn/hysdn_net.c~hysdn-fix-writing-outside-the-field-on-64-bits drivers/isdn/hysdn/hysdn_net.c
--- a/drivers/isdn/hysdn/hysdn_net.c~hysdn-fix-writing-outside-the-field-on-64-bits
+++ a/drivers/isdn/hysdn/hysdn_net.c
@@ -83,12 +83,12 @@ net_open(struct net_device *dev)
 
 	/* Fill in the MAC-level header (if not already set) */
 	if (!card->mac_addr[0]) {
-		for (i = 0; i < ETH_ALEN - sizeof(unsigned long); i++)
+		for (i = 0; i < ETH_ALEN; i++)
 			dev->dev_addr[i] = 0xfc;
 		if ((in_dev = dev->ip_ptr) != NULL) {
 			struct in_ifaddr *ifa = in_dev->ifa_list;
 			if (ifa != NULL)
-				memcpy(dev->dev_addr + (ETH_ALEN - sizeof(unsigned long)), &ifa->ifa_local, sizeof(unsigned long));
+				memcpy(dev->dev_addr + (ETH_ALEN - sizeof(ifa->ifa_local)), &ifa->ifa_local, sizeof(ifa->ifa_local));
 		}
 	} else
 		memcpy(dev->dev_addr, card->mac_addr, ETH_ALEN);
_
