From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next 2/7] sctp: remove macros sctp_local_bh_{disable|enable}
Date: Tue, 21 Jan 2014 15:44:07 +0800
Message-ID: <1390290252-16080-3-git-send-email-wangweidong1@huawei.com>
References: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <dborkman@redhat.com>, <netdev@vger.kernel.org>,
	<linux-sctp@vger.kernel.org>
To: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:28928 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750891AbaAUHt6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 02:49:58 -0500
In-Reply-To: <1390290252-16080-1-git-send-email-wangweidong1@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Redefined local_bh_{disable|enable} to sctp_local_bh_{disable|enable}
for user space friendly code which we haven't use in years, so removing them.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
 include/net/sctp/sctp.h |  2 --
 net/sctp/endpointola.c  |  4 ++--
 net/sctp/input.c        | 20 ++++++++++----------
 net/sctp/proc.c         | 12 ++++++------
 net/sctp/socket.c       | 16 ++++++++--------
 5 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index b180a8f..c17121a 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -171,8 +171,6 @@ extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
  */
 
 /* spin lock wrappers. */
-#define sctp_local_bh_disable() local_bh_disable()
-#define sctp_local_bh_enable()  local_bh_enable()
 #define sctp_spin_lock(lock)    spin_lock(lock)
 #define sctp_spin_unlock(lock)  spin_unlock(lock)
 #define sctp_write_lock(lock)   write_lock(lock)
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 6ffb6c1..8e5fdea 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -368,9 +368,9 @@ struct sctp_association *sctp_endpoint_lookup_assoc(
 {
 	struct sctp_association *asoc;
 
-	sctp_local_bh_disable();
+	local_bh_disable();
 	asoc = __sctp_endpoint_lookup_assoc(ep, paddr, transport);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	return asoc;
 }
diff --git a/net/sctp/input.c b/net/sctp/input.c
index 1f4eeb4..e22b326 100644
--- a/net/sctp/input.c
+++ b/net/sctp/input.c
@@ -726,9 +726,9 @@ static void __sctp_hash_endpoint(struct sctp_endpoint *ep)
 /* Add an endpoint to the hash. Local BH-safe. */
 void sctp_hash_endpoint(struct sctp_endpoint *ep)
 {
-	sctp_local_bh_disable();
+	local_bh_disable();
 	__sctp_hash_endpoint(ep);
-	sctp_local_bh_enable();
+	local_bh_enable();
 }
 
 /* Remove endpoint from the hash table.  */
@@ -752,9 +752,9 @@ static void __sctp_unhash_endpoint(struct sctp_endpoint *ep)
 /* Remove endpoint from the hash.  Local BH-safe. */
 void sctp_unhash_endpoint(struct sctp_endpoint *ep)
 {
-	sctp_local_bh_disable();
+	local_bh_disable();
 	__sctp_unhash_endpoint(ep);
-	sctp_local_bh_enable();
+	local_bh_enable();
 }
 
 /* Look up an endpoint. */
@@ -809,9 +809,9 @@ void sctp_hash_established(struct sctp_association *asoc)
 	if (asoc->temp)
 		return;
 
-	sctp_local_bh_disable();
+	local_bh_disable();
 	__sctp_hash_established(asoc);
-	sctp_local_bh_enable();
+	local_bh_enable();
 }
 
 /* Remove association from the hash table.  */
@@ -839,9 +839,9 @@ void sctp_unhash_established(struct sctp_association *asoc)
 	if (asoc->temp)
 		return;
 
-	sctp_local_bh_disable();
+	local_bh_disable();
 	__sctp_unhash_established(asoc);
-	sctp_local_bh_enable();
+	local_bh_enable();
 }
 
 /* Look up an association. */
@@ -891,9 +891,9 @@ struct sctp_association *sctp_lookup_association(struct net *net,
 {
 	struct sctp_association *asoc;
 
-	sctp_local_bh_disable();
+	local_bh_disable();
 	asoc = __sctp_lookup_association(net, laddr, paddr, transportp);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	return asoc;
 }
diff --git a/net/sctp/proc.c b/net/sctp/proc.c
index 63ba0bd..0947f1e 100644
--- a/net/sctp/proc.c
+++ b/net/sctp/proc.c
@@ -218,7 +218,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		return -ENOMEM;
 
 	head = &sctp_ep_hashtable[hash];
-	sctp_local_bh_disable();
+	local_bh_disable();
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		ep = sctp_ep(epb);
@@ -235,7 +235,7 @@ static int sctp_eps_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "\n");
 	}
 	read_unlock(&head->lock);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	return 0;
 }
@@ -326,7 +326,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		return -ENOMEM;
 
 	head = &sctp_assoc_hashtable[hash];
-	sctp_local_bh_disable();
+	local_bh_disable();
 	read_lock(&head->lock);
 	sctp_for_each_hentry(epb, &head->chain) {
 		assoc = sctp_assoc(epb);
@@ -362,7 +362,7 @@ static int sctp_assocs_seq_show(struct seq_file *seq, void *v)
 		seq_printf(seq, "\n");
 	}
 	read_unlock(&head->lock);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	return 0;
 }
@@ -446,7 +446,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 		return -ENOMEM;
 
 	head = &sctp_assoc_hashtable[hash];
-	sctp_local_bh_disable();
+	local_bh_disable();
 	read_lock(&head->lock);
 	rcu_read_lock();
 	sctp_for_each_hentry(epb, &head->chain) {
@@ -505,7 +505,7 @@ static int sctp_remaddr_seq_show(struct seq_file *seq, void *v)
 
 	rcu_read_unlock();
 	read_unlock(&head->lock);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	return 0;
 
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index fd7337a..f2e0005 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -1510,7 +1510,7 @@ static void sctp_close(struct sock *sk, long timeout)
 	/* Supposedly, no process has access to the socket, but
 	 * the net layers still may.
 	 */
-	sctp_local_bh_disable();
+	local_bh_disable();
 	sctp_bh_lock_sock(sk);
 
 	/* Hold the sock, since sk_common_release() will put sock_put()
@@ -1520,7 +1520,7 @@ static void sctp_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 
 	sctp_bh_unlock_sock(sk);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	sock_put(sk);
 
@@ -5918,7 +5918,7 @@ static long sctp_get_port_local(struct sock *sk, union sctp_addr *addr)
 
 	pr_debug("%s: begins, snum:%d\n", __func__, snum);
 
-	sctp_local_bh_disable();
+	local_bh_disable();
 
 	if (snum == 0) {
 		/* Search for an available port. */
@@ -6052,7 +6052,7 @@ fail_unlock:
 	sctp_spin_unlock(&head->lock);
 
 fail:
-	sctp_local_bh_enable();
+	local_bh_enable();
 	return ret;
 }
 
@@ -6297,9 +6297,9 @@ static inline void __sctp_put_port(struct sock *sk)
 
 void sctp_put_port(struct sock *sk)
 {
-	sctp_local_bh_disable();
+	local_bh_disable();
 	__sctp_put_port(sk);
-	sctp_local_bh_enable();
+	local_bh_enable();
 }
 
 /*
@@ -6950,14 +6950,14 @@ static void sctp_sock_migrate(struct sock *oldsk, struct sock *newsk,
 	/* Hook this new socket in to the bind_hash list. */
 	head = &sctp_port_hashtable[sctp_phashfn(sock_net(oldsk),
 						 inet_sk(oldsk)->inet_num)];
-	sctp_local_bh_disable();
+	local_bh_disable();
 	sctp_spin_lock(&head->lock);
 	pp = sctp_sk(oldsk)->bind_hash;
 	sk_add_bind_node(newsk, &pp->owner);
 	sctp_sk(newsk)->bind_hash = pp;
 	inet_sk(newsk)->inet_num = inet_sk(oldsk)->inet_num;
 	sctp_spin_unlock(&head->lock);
-	sctp_local_bh_enable();
+	local_bh_enable();
 
 	/* Copy the bind_addr list from the original endpoint to the new
 	 * endpoint so that we can handle restarts properly
-- 
1.7.12
