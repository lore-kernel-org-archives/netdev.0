From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH RFC 5/31] net: Add a network namespace parameter to struct sock
Date: Thu, 25 Jan 2007 12:00:07 -0700
Message-ID: <11697516341105-git-send-email-ebiederm@xmission.com>
References: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Cc: <containers@lists.osdl.org>, <openib-general@openib.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:35787 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030316AbXAYTBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 14:01:34 -0500
In-Reply-To: <m13b5zym0n.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric W. Biederman <ebiederm@xmission.com> - unquoted

Sockets need to get a reference to their network namespace,
or possibly a simple hold if someone registers on the network
namespace notifier and will free the sockets when the namespace
is going to be destroyed.

Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
---
 include/net/inet_timewait_sock.h |    1 +
 include/net/sock.h               |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/include/net/inet_timewait_sock.h b/include/net/inet_timewait_sock.h
index f7be1ac..162c2b9 100644
--- a/include/net/inet_timewait_sock.h
+++ b/include/net/inet_timewait_sock.h
@@ -115,6 +115,7 @@ struct inet_timewait_sock {
 #define tw_refcnt		__tw_common.skc_refcnt
 #define tw_hash			__tw_common.skc_hash
 #define tw_prot			__tw_common.skc_prot
+#define tw_net			__tw_common.skc_net
 	volatile unsigned char	tw_substate;
 	/* 3 bits hole, try to pack */
 	unsigned char		tw_rcv_wscale;
diff --git a/include/net/sock.h b/include/net/sock.h
index 03684e7..5bf6bb5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -105,6 +105,7 @@ struct proto;
  *	@skc_refcnt: reference count
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
+ *	@skc_net: reference to the network namespace of this socket
  *
  *	This is the minimal network layer representation of sockets, the header
  *	for struct sock and struct inet_timewait_sock.
@@ -119,6 +120,7 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
+	net_t	 		skc_net;
 };
 
 /**
@@ -195,6 +197,7 @@ struct sock {
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
+#define sk_net			__sk_common.skc_net
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
 				sk_userlocks : 4;
-- 
1.4.4.1.g278f

