From: Joe Perches <joe@perches.com>
Subject: [PATCH] ipv4/ipmr and ipv6/ip6mr: Convert int mroute_do_<foo> to
 bool
Date: Sun, 25 Nov 2012 11:35:30 -0800
Message-ID: <1353872130.6558.17.camel@joe-AO722>
References: <1353861705.30446.675.camel@edumazet-glaptop>
	 <1353868023.6558.10.camel@joe-AO722>
	 <1353870787.30446.831.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53952 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753305Ab2KYTf3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Nov 2012 14:35:29 -0500
In-Reply-To: <1353870787.30446.831.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Save a few bytes per table by convert mroute_do_assert and
mroute_do_pim from int to bool.

Remove !! as the compiler does that when assigning int to bool.

Signed-off-by: Joe Perches <joe@perches.com>
---
> mroute is probably used only by a very limited
> number of machines in the world.
> 
> Please submit an additional patch, as I already put too many
> things in mine.

On top of Eric's cleanup...

 net/ipv4/ipmr.c  |    6 +++---
 net/ipv6/ip6mr.c |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 0394a8e..fc09ef9 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -83,8 +83,8 @@ struct mr_table {
 	struct vif_device	vif_table[MAXVIFS];
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
-	int			mroute_do_assert;
-	int			mroute_do_pim;
+	bool			mroute_do_assert;
+	bool			mroute_do_pim;
 #if defined(CONFIG_IP_PIMSM_V1) || defined(CONFIG_IP_PIMSM_V2)
 	int			mroute_reg_vif_num;
 #endif
@@ -1289,7 +1289,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 			return -EINVAL;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
-		mrt->mroute_do_assert = !!v;
+		mrt->mroute_do_assert = v;
 		return 0;
 	}
 #ifdef CONFIG_IP_PIMSM
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index d7330f8..79bb490 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -66,8 +66,8 @@ struct mr6_table {
 	struct mif_device	vif6_table[MAXMIFS];
 	int			maxvif;
 	atomic_t		cache_resolve_queue_len;
-	int			mroute_do_assert;
-	int			mroute_do_pim;
+	bool			mroute_do_assert;
+	bool			mroute_do_pim;
 #ifdef CONFIG_IPV6_PIMSM_V2
 	int			mroute_reg_vif_num;
 #endif
@@ -1648,7 +1648,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 		int v;
 		if (get_user(v, (int __user *)optval))
 			return -EFAULT;
-		mrt->mroute_do_assert = !!v;
+		mrt->mroute_do_assert = v;
 		return 0;
 	}
 
