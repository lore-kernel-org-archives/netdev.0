From: "Sanagi, Koki" <sanagi.koki@jp.fujitsu.com>
Subject: RE: [PATCH] skb: add a comment to skb_csum_unnecessary to avoid
 miuse
Date: Wed, 23 Jan 2013 05:11:14 +0000
Message-ID: <F6CB40852BC6EF489E0AA83EFF537F470876BBCF@G01JPEXMBYT04>
References: <50FF2F18.1050408@jp.fujitsu.com>
	<20130122.205346.633138554393148358.davem@davemloft.net>
	<F6CB40852BC6EF489E0AA83EFF537F470876B9FD@G01JPEXMBYT04>
 <20130122.231353.2100388787067184936.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:57695 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750886Ab3AWFLR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2013 00:11:17 -0500
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 130E23EE0C0
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:11:16 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E911645DE59
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:11:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D143F45DE54
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:11:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C09101DB8041
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:11:15 +0900 (JST)
Received: from g01jpexchyt04.g01.fujitsu.local (g01jpexchyt04.g01.fujitsu.local [10.128.194.43])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ECFE1DB803C
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2013 14:11:15 +0900 (JST)
In-Reply-To: <20130122.231353.2100388787067184936.davem@davemloft.net>
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: "Sanagi, Koki" <sanagi.koki@jp.fujitsu.com>
> Date: Wed, 23 Jan 2013 02:32:52 +0000
> 
> >> From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> >> Date: Wed, 23 Jan 2013 09:30:16 +0900
> >>
> >> > Due to its name and appearance, someone thinks this only checks if
> >> > ip_summed is CHECKSUM_UNNECESARRY.  But actually, this returns true
> >> > even if ip_summed is CHECKSUM_PARTIAL.  To avoid misuse, this patch
> >> > a comment which specifies that CHECKSUM_PARTIAL is OK.
> >> >
> >> > Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
> >>
> >> I'm not applying this, sorry.  It's a one line function and it's not
> >> so non-obvious that it deserves an 8 line comment.
> >
> > OK.  I just felt weird that CHECKSUM_* is not bit flag but this
> > function handles it as if it was bit flag.
> 
> The function name says what it does, it determines whether a checksum is
> necessary or not.  How that is implemented is another issue.

As for name of the function which confused me, I'm ok now.  But as for how to implement,
I still think it is inappropriate because of the above reason.  So, how about introducing
CHECKSUM_UNNECESSARY_BIT like below ?

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8b2256e..b1dbd36 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -39,6 +39,8 @@
 #define CHECKSUM_COMPLETE 2
 #define CHECKSUM_PARTIAL 3

+#define CHECKSUM_UNNECESSARY_BIT (1 << 0)
+
 #define SKB_DATA_ALIGN(X)      (((X) + (SMP_CACHE_BYTES - 1)) & \
                                 ~(SMP_CACHE_BYTES - 1))
 #define SKB_WITH_OVERHEAD(X)   \
@@ -2524,7 +2526,7 @@ extern __sum16 __skb_checksum_complete(struct sk_buff *skb);

 static inline int skb_csum_unnecessary(const struct sk_buff *skb)
 {
-       return skb->ip_summed & CHECKSUM_UNNECESSARY;
+       return skb->ip_summed & CHECKSUM_UNNECESSARY_BIT;
 }

 /**
