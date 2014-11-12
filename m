From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] udp: Neaten function pointer calls and add braces
Date: Tue, 11 Nov 2014 21:59:20 -0800
Message-ID: <1415771960.16070.21.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0110.hostedemail.com ([216.40.44.110]:48893 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752386AbaKLF7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2014 00:59:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Standardize function pointer uses.

Convert calling style from:
	(*foo)(args...);
to:
	foo(args...);

Other miscellanea:

o Add braces around loops with single ifs on multiple lines
o Realign arguments around these functions
o Invert logic in if to return immediately.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv4/udp.c | 34 +++++++++++++++++-----------------
 1 file changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5d0fdca..6a0d940 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -144,7 +144,7 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 	struct hlist_nulls_node *node;
 	kuid_t uid = sock_i_uid(sk);
 
-	sk_nulls_for_each(sk2, node, &hslot->head)
+	sk_nulls_for_each(sk2, node, &hslot->head) {
 		if (net_eq(sock_net(sk2), net) &&
 		    sk2 != sk &&
 		    (bitmap || udp_sk(sk2)->udp_port_hash == num) &&
@@ -152,14 +152,13 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
-		      !uid_eq(uid, sock_i_uid(sk2))) &&
-		    (*saddr_comp)(sk, sk2)) {
-			if (bitmap)
-				__set_bit(udp_sk(sk2)->udp_port_hash >> log,
-					  bitmap);
-			else
+		     !uid_eq(uid, sock_i_uid(sk2))) &&
+		    saddr_comp(sk, sk2)) {
+			if (!bitmap)
 				return 1;
+			__set_bit(udp_sk(sk2)->udp_port_hash >> log, bitmap);
 		}
+	}
 	return 0;
 }
 
@@ -168,10 +167,10 @@ static int udp_lib_lport_inuse(struct net *net, __u16 num,
  * can insert/delete a socket with local_port == num
  */
 static int udp_lib_lport_inuse2(struct net *net, __u16 num,
-			       struct udp_hslot *hslot2,
-			       struct sock *sk,
-			       int (*saddr_comp)(const struct sock *sk1,
-						 const struct sock *sk2))
+				struct udp_hslot *hslot2,
+				struct sock *sk,
+				int (*saddr_comp)(const struct sock *sk1,
+						  const struct sock *sk2))
 {
 	struct sock *sk2;
 	struct hlist_nulls_node *node;
@@ -179,7 +178,7 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 	int res = 0;
 
 	spin_lock(&hslot2->lock);
-	udp_portaddr_for_each_entry(sk2, node, &hslot2->head)
+	udp_portaddr_for_each_entry(sk2, node, &hslot2->head) {
 		if (net_eq(sock_net(sk2), net) &&
 		    sk2 != sk &&
 		    (udp_sk(sk2)->udp_port_hash == num) &&
@@ -187,11 +186,12 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
 		    (!sk2->sk_bound_dev_if || !sk->sk_bound_dev_if ||
 		     sk2->sk_bound_dev_if == sk->sk_bound_dev_if) &&
 		    (!sk2->sk_reuseport || !sk->sk_reuseport ||
-		      !uid_eq(uid, sock_i_uid(sk2))) &&
-		    (*saddr_comp)(sk, sk2)) {
+		     !uid_eq(uid, sock_i_uid(sk2))) &&
+		    saddr_comp(sk, sk2)) {
 			res = 1;
 			break;
 		}
+	}
 	spin_unlock(&hslot2->lock);
 	return res;
 }
@@ -206,8 +206,8 @@ static int udp_lib_lport_inuse2(struct net *net, __u16 num,
  *                   with NULL address
  */
 int udp_lib_get_port(struct sock *sk, unsigned short snum,
-		       int (*saddr_comp)(const struct sock *sk1,
-					 const struct sock *sk2),
+		     int (*saddr_comp)(const struct sock *sk1,
+				       const struct sock *sk2),
 		     unsigned int hash2_nulladdr)
 {
 	struct udp_hslot *hslot, *hslot2;
@@ -2032,7 +2032,7 @@ int udp_lib_setsockopt(struct sock *sk, int level, int optname,
 		} else {
 			up->corkflag = 0;
 			lock_sock(sk);
-			(*push_pending_frames)(sk);
+			push_pending_frames(sk);
 			release_sock(sk);
 		}
 		break;
