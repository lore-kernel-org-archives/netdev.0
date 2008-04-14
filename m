From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-2.6.26][SOCK]: Add some notes about per-bind-bucket sock
 lookup.
Date: Mon, 14 Apr 2008 13:39:46 +0400
Message-ID: <48032662.30001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:38660 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751401AbYDNJkp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2008 05:40:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I was asked about "why don't we perform a sk_net filtering in
bind_conflict calls, like we do in other sock lookup places"
for a couple of times.

Can we please add a comment about why we do not need one?

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/ipv4/inet_connection_sock.c  |    7 +++++++
 net/ipv6/inet6_connection_sock.c |    4 ++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 8d70cfb..828ea21 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -55,6 +55,13 @@ int inet_csk_bind_conflict(const struct sock *sk,
 	struct hlist_node *node;
 	int reuse = sk->sk_reuse;
 
+	/*
+	 * Unlike other sk lookup places we do not check
+	 * for sk_net here, since _all_ the socks listed
+	 * in tb->owners list belong to the same net - the
+	 * one this bucket belongs to.
+	 */
+
 	sk_for_each_bound(sk2, node, &tb->owners) {
 		if (sk != sk2 &&
 		    !inet_v6_ipv6only(sk2) &&
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index 78de42a..87801cc 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -33,6 +33,10 @@ int inet6_csk_bind_conflict(const struct sock *sk,
 	const struct hlist_node *node;
 
 	/* We must walk the whole port owner list in this case. -DaveM */
+	/*
+	 * See comment in inet_csk_bind_conflict about sock lookup
+	 * vs net namespaces issues.
+	 */
 	sk_for_each_bound(sk2, node, &tb->owners) {
 		if (sk != sk2 &&
 		    (!sk->sk_bound_dev_if ||
-- 
1.5.3.4

