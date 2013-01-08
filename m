From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next] ipv6: Optimize ipv6_change_dsfield().
Date: Wed, 09 Jan 2013 01:47:08 +0900
Message-ID: <50EC4D8C.2080408@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:59210 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756502Ab3AHQrK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 11:47:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not convert endian back and forth.
If the caller uses contant "mask" argument (and most callers do),
we can omit runtime endian conversion here.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 include/net/dsfield.h |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/net/dsfield.h b/include/net/dsfield.h
index 8a8d4e0..e1ad903 100644
--- a/include/net/dsfield.h
+++ b/include/net/dsfield.h
@@ -43,11 +43,9 @@ static inline void ipv4_change_dsfield(struct iphdr *iph,__u8 mask,
 static inline void ipv6_change_dsfield(struct ipv6hdr *ipv6h,__u8 mask,
     __u8 value)
 {
-        __u16 tmp;
+	__be16 *p = (__force __be16 *)ipv6h;
 
-	tmp = ntohs(*(__be16 *) ipv6h);
-	tmp = (tmp & ((mask << 4) | 0xf00f)) | (value << 4);
-	*(__be16 *) ipv6h = htons(tmp);
+	*p = (*p & htons((((u16)mask << 4) | 0xf00f))) | htons((u16)value << 4);
 }
 
 
-- 
1.7.9.5
