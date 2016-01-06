From: Lance Richardson <lrichard@redhat.com>
Subject: [PATCH net 2/3] ipv4: eliminate endianness warnings in ip_fib.h
Date: Wed,  6 Jan 2016 17:22:46 -0500
Message-ID: <1452118967-32123-3-git-send-email-lrichard@redhat.com>
References: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:58150 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbcAFWWs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 17:22:48 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (Postfix) with ESMTPS id AE6ADC117672
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 22:22:48 +0000 (UTC)
Received: from dhcp129-205.rdu.redhat.com (dhcp129-10.rdu.redhat.com [10.13.129.10])
	by int-mx10.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id u06MMlZp005846
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2016 17:22:48 -0500
In-Reply-To: <1452118967-32123-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fib_multipath_hash() computes a hash using __be32 values, force
cast these to u32 to pacify sparse.

Signed-off-by: Lance Richardson <lrichard@redhat.com>
---
 include/net/ip_fib.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/net/ip_fib.h b/include/net/ip_fib.h
index 9f4df68..7029527 100644
--- a/include/net/ip_fib.h
+++ b/include/net/ip_fib.h
@@ -325,7 +325,8 @@ extern u32 fib_multipath_secret __read_mostly;
 
 static inline int fib_multipath_hash(__be32 saddr, __be32 daddr)
 {
-	return jhash_2words(saddr, daddr, fib_multipath_secret) >> 1;
+	return jhash_2words((__force u32)saddr, (__force u32)daddr,
+			    fib_multipath_secret) >> 1;
 }
 
 void fib_select_multipath(struct fib_result *res, int hash);
-- 
2.5.0
