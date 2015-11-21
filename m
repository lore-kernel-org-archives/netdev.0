From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH net-next 2/9] net: ipmr: always define mroute_reg_vif_num
Date: Sat, 21 Nov 2015 14:01:35 +0100
Message-ID: <1448110902-28793-3-git-send-email-razor@blackwall.org>
References: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Cc: davem@davemloft.net,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35740 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752256AbbKUNBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2015 08:01:49 -0500
Received: by wmuu63 with SMTP id u63so6065629wmu.0
        for <netdev@vger.kernel.org>; Sat, 21 Nov 2015 05:01:48 -0800 (PST)
In-Reply-To: <1448110902-28793-1-git-send-email-razor@blackwall.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

Before mroute_reg_vif_num was defined only if any of the CONFIG_PIMSM_
options were set, but that's not really necessary as the size of the
struct is the same in both cases (checked with pahole, both cases size
is 3256 bytes) and we can remove some unnecessary ifdefs to simplify the
code.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/ipv4/ipmr.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5271e2eee110..dd2462f70d34 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -84,9 +84,7 @@ struct mr_table {
 	atomic_t		cache_resolve_queue_len;
 	bool			mroute_do_assert;
 	bool			mroute_do_pim;
-#if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 	int			mroute_reg_vif_num;
-#endif
 };
 
 struct ipmr_rule {
@@ -347,9 +345,7 @@ static struct mr_table *ipmr_new_table(struct net *net, u32 id)
 	setup_timer(&mrt->ipmr_expire_timer, ipmr_expire_process,
 		    (unsigned long)mrt);
 
-#ifdef CONFIG_IP_PIMSM
 	mrt->mroute_reg_vif_num = -1;
-#endif
 #ifdef CONFIG_IP_MROUTE_MULTIPLE_TABLES
 	list_add_tail_rcu(&mrt->list, &net->ipv4.mr_tables);
 #endif
@@ -584,10 +580,8 @@ static int vif_delete(struct mr_table *mrt, int vifi, int notify,
 		return -EADDRNOTAVAIL;
 	}
 
-#ifdef CONFIG_IP_PIMSM
 	if (vifi == mrt->mroute_reg_vif_num)
 		mrt->mroute_reg_vif_num = -1;
-#endif
 
 	if (vifi + 1 == mrt->maxvif) {
 		int tmp;
@@ -824,10 +818,8 @@ static int vif_add(struct net *net, struct mr_table *mrt,
 	/* And finish update writing critical data */
 	write_lock_bh(&mrt_lock);
 	v->dev = dev;
-#ifdef CONFIG_IP_PIMSM
 	if (v->flags & VIFF_REGISTER)
 		mrt->mroute_reg_vif_num = vifi;
-#endif
 	if (vifi+1 > mrt->maxvif)
 		mrt->maxvif = vifi+1;
 	write_unlock_bh(&mrt_lock);
-- 
2.4.3
