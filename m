From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH 4/5] 6lowpan: duplicate definition of IEEE802154_ALEN
Date: Tue, 24 Apr 2012 14:51:10 +0400
Message-ID: <1335264671-27127-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63896 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752359Ab2DXKvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 06:51:41 -0400
Received: by mail-bk0-f46.google.com with SMTP id w12so313831bku.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 03:51:41 -0700 (PDT)
In-Reply-To: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The same macros is defined in 'include/net/af_ieee802154.h' and is called
IEEE802154_ADDR_LEN. No need another one, so remove it.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |    4 ++--
 net/ieee802154/6lowpan.h |    3 ---
 2 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index a57174e..8c1d212 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -196,7 +196,7 @@ lowpan_compress_addr_64(u8 **hc06_ptr, u8 shift, const struct in6_addr *ipaddr,
 static void
 lowpan_uip_ds6_set_addr_iid(struct in6_addr *ipaddr, unsigned char *lladdr)
 {
-	memcpy(&ipaddr->s6_addr[8], lladdr, IEEE802154_ALEN);
+	memcpy(&ipaddr->s6_addr[8], lladdr, IEEE802154_ADDR_LEN);
 	/* second bit-flip (Universe/Local) is done according RFC2464 */
 	ipaddr->s6_addr[8] ^= 0x02;
 }
@@ -221,7 +221,7 @@ lowpan_uncompress_addr(struct sk_buff *skb, struct in6_addr *ipaddr,
 
 	if (lladdr)
 		lowpan_raw_dump_inline(__func__, "linklocal address",
-						lladdr,	IEEE802154_ALEN);
+						lladdr,	IEEE802154_ADDR_LEN);
 	if (prefcount > 0)
 		memcpy(ipaddr, prefix, prefcount);
 
diff --git a/net/ieee802154/6lowpan.h b/net/ieee802154/6lowpan.h
index aeff3f3..8c2251f 100644
--- a/net/ieee802154/6lowpan.h
+++ b/net/ieee802154/6lowpan.h
@@ -53,9 +53,6 @@
 #ifndef __6LOWPAN_H__
 #define __6LOWPAN_H__
 
-/* need to know address length to manipulate with it */
-#define IEEE802154_ALEN		8
-
 #define UIP_802154_SHORTADDR_LEN	2  /* compressed ipv6 address length */
 #define UIP_IPH_LEN			40 /* ipv6 fixed header size */
 #define UIP_PROTO_UDP			17 /* ipv6 next header value for UDP */
-- 
1.7.2.3
