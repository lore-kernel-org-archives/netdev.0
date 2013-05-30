From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] include/linux/skbuff.h: using '0xffff' instead of '~0U'
Date: Thu, 30 May 2013 14:03:49 +0800
Message-ID: <51A6EBC5.7040601@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: edumazet@google.com, Pravin Shelar <pshelar@nicira.com>,
	mgorman@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:45947 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967530Ab3E3GEl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 02:04:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Both 'transport_header' and 'mac_header' are u16, which are never equal
to '~0U'.

So need use '0xffff' instead of '~0U'.

The related warning (with EXTRA_CFLAGS=-W ARCH=m68k for allmodconfig)
  include/linux/skbuff.h:1587:2: warning: comparison is always true due to limited range of data type [-Wtype-limits]
  ...


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 include/linux/skbuff.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 2e0ced1..03ba058 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1581,7 +1581,7 @@ static inline void skb_set_inner_mac_header(struct sk_buff *skb,
 }
 static inline bool skb_transport_header_was_set(const struct sk_buff *skb)
 {
-	return skb->transport_header != ~0U;
+	return skb->transport_header != 0xffff;
 }
 
 static inline unsigned char *skb_transport_header(const struct sk_buff *skb)
@@ -1624,7 +1624,7 @@ static inline unsigned char *skb_mac_header(const struct sk_buff *skb)
 
 static inline int skb_mac_header_was_set(const struct sk_buff *skb)
 {
-	return skb->mac_header != ~0U;
+	return skb->mac_header != 0xffff;
 }
 
 static inline void skb_reset_mac_header(struct sk_buff *skb)
-- 
1.7.7.6
