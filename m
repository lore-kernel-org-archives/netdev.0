From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] rhashtable: ensure cache line alignment on bucket_table
Date: Fri, 20 Feb 2015 06:48:57 -0800
Message-ID: <1424443737.5565.12.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:55452 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754121AbbBTOs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 09:48:59 -0500
Received: by mail-ig0-f181.google.com with SMTP id hn18so3519300igb.2
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 06:48:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

struct bucket_table contains mostly read fields :

size, locks_mask, locks.

Make sure these are not sharing a cache line with buckets[]

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/rhashtable.h |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 58851275fed9..cb2104be2135 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -54,10 +54,11 @@ struct rhash_head {
  * @buckets: size * hash buckets
  */
 struct bucket_table {
-	size_t				size;
-	unsigned int			locks_mask;
-	spinlock_t			*locks;
-	struct rhash_head __rcu		*buckets[];
+	size_t			size;
+	unsigned int		locks_mask;
+	spinlock_t		*locks;
+
+	struct rhash_head __rcu	*buckets[] ____cacheline_aligned_in_smp;
 };
 
 typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
