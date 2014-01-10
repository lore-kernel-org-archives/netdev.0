From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] l2tp: make local functions static
Date: Thu, 9 Jan 2014 22:22:27 -0800
Message-ID: <20140109222227.3b3b5776@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:38148 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaAJGWc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 01:22:32 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so4164658pdj.31
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 22:22:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Avoid needless export of local functions

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


---
 net/l2tp/l2tp_core.c |    6 ++----
 net/l2tp/l2tp_core.h |    2 --
 2 files changed, 2 insertions(+), 6 deletions(-)

--- a/net/l2tp/l2tp_core.c	2014-01-04 13:39:54.412219520 -0800
+++ b/net/l2tp/l2tp_core.c	2014-01-04 13:42:23.577751675 -0800
@@ -176,7 +176,7 @@ l2tp_session_id_hash_2(struct l2tp_net *
  * owned by userspace.  A struct sock returned from this function must be
  * released using l2tp_tunnel_sock_put once you're done with it.
  */
-struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel)
+static struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel)
 {
 	int err = 0;
 	struct socket *sock = NULL;
@@ -202,10 +202,9 @@ struct sock *l2tp_tunnel_sock_lookup(str
 out:
 	return sk;
 }
-EXPORT_SYMBOL_GPL(l2tp_tunnel_sock_lookup);
 
 /* Drop a reference to a tunnel socket obtained via. l2tp_tunnel_sock_put */
-void l2tp_tunnel_sock_put(struct sock *sk)
+static void l2tp_tunnel_sock_put(struct sock *sk)
 {
 	struct l2tp_tunnel *tunnel = l2tp_sock_to_tunnel(sk);
 	if (tunnel) {
@@ -217,7 +216,6 @@ void l2tp_tunnel_sock_put(struct sock *s
 	}
 	sock_put(sk);
 }
-EXPORT_SYMBOL_GPL(l2tp_tunnel_sock_put);
 
 /* Lookup a session by id in the global session list
  */
--- a/net/l2tp/l2tp_core.h	2014-01-04 13:39:54.412219520 -0800
+++ b/net/l2tp/l2tp_core.h	2014-01-04 13:42:23.577751675 -0800
@@ -238,8 +238,6 @@ out:
 	return tunnel;
 }
 
-struct sock *l2tp_tunnel_sock_lookup(struct l2tp_tunnel *tunnel);
-void l2tp_tunnel_sock_put(struct sock *sk);
 struct l2tp_session *l2tp_session_find(struct net *net,
 				       struct l2tp_tunnel *tunnel,
 				       u32 session_id);
