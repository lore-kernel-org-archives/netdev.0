From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] net/decnet/dn_route.c: fix inconsequent NULL checking
Date: Sat, 11 Mar 2006 00:02:33 +0100
Message-ID: <20060310230233.GB21864@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-decnet-user@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932145AbWCJXCf@vger.kernel.org>
To: patrick@tykepenguin.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The Coverity checker noted this inconsequent NULL checking in
dnrt_drop().

Since all callers ensure that NULL isn't passed, we can simply remove 
the check.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.16-rc5-mm3-full/net/decnet/dn_route.c.old	2006-03-10 23:34:57.000000000 +0100
+++ linux-2.6.16-rc5-mm3-full/net/decnet/dn_route.c	2006-03-10 23:35:08.000000000 +0100
@@ -149,8 +149,7 @@ static inline void dnrt_free(struct dn_r
 
 static inline void dnrt_drop(struct dn_route *rt)
 {
-	if (rt)
-		dst_release(&rt->u.dst);
+	dst_release(&rt->u.dst);
 	call_rcu_bh(&rt->u.dst.rcu_head, dst_rcu_free);
 }
 
