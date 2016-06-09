From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] iucv: properly clone LSM attributes to newly created child
 sockets
Date: Thu, 09 Jun 2016 08:59:53 -0400
Message-ID: <146547719343.9258.4899338680484754606.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
To: linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36762 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750810AbcFIM7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jun 2016 08:59:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

Much like we had to do for AF_BLUETOOTH and AF_ALG, make sure we
properly clone the parent socket's LSM attributes to newly created
child sockets.

Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/iucv/af_iucv.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/net/iucv/af_iucv.c b/net/iucv/af_iucv.c
index fc3598a..a0d1e36 100644
--- a/net/iucv/af_iucv.c
+++ b/net/iucv/af_iucv.c
@@ -22,6 +22,7 @@
 #include <linux/skbuff.h>
 #include <linux/init.h>
 #include <linux/poll.h>
+#include <linux/security.h>
 #include <net/sock.h>
 #include <asm/ebcdic.h>
 #include <asm/cpcmd.h>
@@ -530,8 +531,10 @@ static void iucv_sock_close(struct sock *sk)
 
 static void iucv_sock_init(struct sock *sk, struct sock *parent)
 {
-	if (parent)
+	if (parent) {
 		sk->sk_type = parent->sk_type;
+		security_sk_clone(parent, sk);
+	}
 }
 
 static struct sock *iucv_sock_alloc(struct socket *sock, int proto, gfp_t prio, int kern)
