From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 1/2] [NET] Cleanup: Use sock_owned_by_user() macro
Date: Tue, 11 Sep 2007 14:01:32 -0400
Message-ID: <11895336943821-git-send-email-jheffner@psc.edu>
References: <11895336933187-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer2.psc.edu ([128.182.66.106]:52003 "EHLO mailer2.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758477AbXIKSPJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2007 14:15:09 -0400
In-Reply-To: <11895336933187-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Changes asserts in sunrpc to use sock_owned_by_user() macro instead of
referencing sock_lock.owner directly.

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 net/sunrpc/svcsock.c  |    2 +-
 net/sunrpc/xprtsock.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index ed17a50..3a95612 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -104,7 +104,7 @@ static struct lock_class_key svc_slock_key[2];
 static inline void svc_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sk->sk_lock.owner != NULL);
+	BUG_ON(sock_owned_by_user(sk));
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFSD",
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 4ae7eed..282efd4 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1186,7 +1186,7 @@ static struct lock_class_key xs_slock_key[2];
 static inline void xs_reclassify_socket(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
-	BUG_ON(sk->sk_lock.owner != NULL);
+	BUG_ON(sock_owned_by_user(sk));
 	switch (sk->sk_family) {
 	case AF_INET:
 		sock_lock_init_class_and_name(sk, "slock-AF_INET-NFS",
-- 
1.5.3.rc7.30.g947ad2

