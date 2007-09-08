From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 06/16] net: Add a network namespace parameter to struct sock
Date: Sat, 08 Sep 2007 15:21:37 -0600
Message-ID: <m1wsv0vony.fsf_-_@ebiederm.dsl.xmission.com>
References: <m1r6l8x3vq.fsf@ebiederm.dsl.xmission.com>
	<m1myvwx3sf.fsf@ebiederm.dsl.xmission.com>
	<m1ir6kx3mn.fsf_-_@ebiederm.dsl.xmission.com>
	<m1ejh8x3ih.fsf_-_@ebiederm.dsl.xmission.com>
	<m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>,
	Linux Containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:52737 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752759AbXIHVWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Sep 2007 17:22:01 -0400
In-Reply-To: <m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com> (Eric
	W. Biederman's message of "Sat, 08 Sep 2007 15:18:12 -0600")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


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
index 47d52b2..abaff05 100644
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
index 802c670..253df3f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -106,6 +106,7 @@ struct proto;
  *	@skc_refcnt: reference count
  *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
+ *	@skc_net: reference to the network namespace of this socket
  *
  *	This is the minimal network layer representation of sockets, the header
  *	for struct sock and struct inet_timewait_sock.
@@ -120,6 +121,7 @@ struct sock_common {
 	atomic_t		skc_refcnt;
 	unsigned int		skc_hash;
 	struct proto		*skc_prot;
+	struct net	 	*skc_net;
 };
 
 /**
@@ -196,6 +198,7 @@ struct sock {
 #define sk_refcnt		__sk_common.skc_refcnt
 #define sk_hash			__sk_common.skc_hash
 #define sk_prot			__sk_common.skc_prot
+#define sk_net			__sk_common.skc_net
 	unsigned char		sk_shutdown : 2,
 				sk_no_check : 2,
 				sk_userlocks : 4;
-- 
1.5.3.rc6.17.g1911

