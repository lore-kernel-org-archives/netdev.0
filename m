From: roy.qing.li@gmail.com
Subject: [PATCH] ipv6: remove aca_lock spinlock from struct ifacaddr6
Date: Sat, 11 Oct 2014 13:03:34 +0800
Message-ID: <1413003814-14216-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:59607 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750747AbaJKFDm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 01:03:42 -0400
Received: by mail-pd0-f179.google.com with SMTP id r10so2763426pdi.38
        for <netdev@vger.kernel.org>; Fri, 10 Oct 2014 22:03:41 -0700 (PDT)
Received: from localhost ([106.120.101.38])
        by mx.google.com with ESMTPSA id ri9sm5010543pbc.5.2014.10.10.22.03.38
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Fri, 10 Oct 2014 22:03:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

no user uses this lock.

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 include/net/if_inet6.h |    1 -
 net/ipv6/anycast.c     |    1 -
 2 files changed, 2 deletions(-)

diff --git a/include/net/if_inet6.h b/include/net/if_inet6.h
index 55a8d40..98e5f95 100644
--- a/include/net/if_inet6.h
+++ b/include/net/if_inet6.h
@@ -146,7 +146,6 @@ struct ifacaddr6 {
 	struct ifacaddr6	*aca_next;
 	int			aca_users;
 	atomic_t		aca_refcnt;
-	spinlock_t		aca_lock;
 	unsigned long		aca_cstamp;
 	unsigned long		aca_tstamp;
 };
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index f5e319a..baf2742 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -235,7 +235,6 @@ static struct ifacaddr6 *aca_alloc(struct rt6_info *rt,
 	/* aca_tstamp should be updated upon changes */
 	aca->aca_cstamp = aca->aca_tstamp = jiffies;
 	atomic_set(&aca->aca_refcnt, 1);
-	spin_lock_init(&aca->aca_lock);
 
 	return aca;
 }
-- 
1.7.10.4
