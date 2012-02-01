From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv6: Remove never used function inet6_ac_check().
Date: Wed, 01 Feb 2012 16:15:02 -0500 (EST)
Message-ID: <20120201.161502.1573313945997804732.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34859 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932618Ab2BAVPE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2012 16:15:04 -0500
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id q11LF2tR002108
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 1 Feb 2012 13:15:03 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It went from unused, to commented out, and never changing after
that.

Just get rid of it, if someone wants it they can unearth it from
the history.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Commited to net-next.

 include/net/addrconf.h |    1 -
 net/ipv6/anycast.c     |   29 -----------------------------
 2 files changed, 0 insertions(+), 30 deletions(-)

diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index f68dce2..757a176 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -160,7 +160,6 @@ extern void addrconf_prefix_rcv(struct net_device *dev,
 extern int ipv6_sock_ac_join(struct sock *sk,int ifindex, const struct in6_addr *addr);
 extern int ipv6_sock_ac_drop(struct sock *sk,int ifindex, const struct in6_addr *addr);
 extern void ipv6_sock_ac_close(struct sock *sk);
-extern int inet6_ac_check(struct sock *sk, const struct in6_addr *addr, int ifindex);
 
 extern int ipv6_dev_ac_inc(struct net_device *dev, const struct in6_addr *addr);
 extern int __ipv6_dev_ac_dec(struct inet6_dev *idev, const struct in6_addr *addr);
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 59402b4..db00d27 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -211,35 +211,6 @@ void ipv6_sock_ac_close(struct sock *sk)
 	rcu_read_unlock();
 }
 
-#if 0
-/* The function is not used, which is funny. Apparently, author
- * supposed to use it to filter out datagrams inside udp/raw but forgot.
- *
- * It is OK, anycasts are not special comparing to delivery to unicasts.
- */
-
-int inet6_ac_check(struct sock *sk, struct in6_addr *addr, int ifindex)
-{
-	struct ipv6_ac_socklist *pac;
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	int	found;
-
-	found = 0;
-	read_lock(&ipv6_sk_ac_lock);
-	for (pac=np->ipv6_ac_list; pac; pac=pac->acl_next) {
-		if (ifindex && pac->acl_ifindex != ifindex)
-			continue;
-		found = ipv6_addr_equal(&pac->acl_addr, addr);
-		if (found)
-			break;
-	}
-	read_unlock(&ipv6_sk_ac_lock);
-
-	return found;
-}
-
-#endif
-
 static void aca_put(struct ifacaddr6 *ac)
 {
 	if (atomic_dec_and_test(&ac->aca_refcnt)) {
-- 
1.7.7.6
