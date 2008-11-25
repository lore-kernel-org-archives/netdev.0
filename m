From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 01/53] xfrm: initialise xfrm_policy_gc_work statically
Date: Tue, 25 Nov 2008 20:26:33 +0300
Message-ID: <1227634045-27534-1-git-send-email-adobriyan@gmail.com>
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:28929 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbYKYRXa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 12:23:30 -0500
Received: by ug-out-1314.google.com with SMTP id 39so1144223ugf.37
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 09:23:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 net/xfrm/xfrm_policy.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 1785488..ea3456d 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -55,7 +55,6 @@ static struct xfrm_policy_afinfo *xfrm_policy_afinfo[NPROTO];
 
 static struct kmem_cache *xfrm_dst_cache __read_mostly;
 
-static struct work_struct xfrm_policy_gc_work;
 static HLIST_HEAD(xfrm_policy_gc_list);
 static DEFINE_SPINLOCK(xfrm_policy_gc_lock);
 
@@ -296,6 +295,7 @@ static void xfrm_policy_gc_task(struct work_struct *work)
 	hlist_for_each_entry_safe(policy, entry, tmp, &gc_list, bydst)
 		xfrm_policy_gc_kill(policy);
 }
+static DECLARE_WORK(xfrm_policy_gc_work, xfrm_policy_gc_task);
 
 /* Rule must be locked. Release descentant resources, announce
  * entry dead. The rule must be unlinked from lists to the moment.
@@ -2425,7 +2425,6 @@ static void __init xfrm_policy_init(void)
 	}
 
 	INIT_LIST_HEAD(&xfrm_policy_all);
-	INIT_WORK(&xfrm_policy_gc_work, xfrm_policy_gc_task);
 	register_netdevice_notifier(&xfrm_dev_notifier);
 }
 
-- 
1.5.6.5

