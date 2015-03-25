From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] sctp: avoid to repeatedly declare external variables
Date: Wed, 25 Mar 2015 14:13:01 +0800
Message-ID: <1427263981-8348-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <vyasevich@gmail.com>, <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:36084 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbbCYGOC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 02:14:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the declaration for external variables to sctp.h file avoiding
to repeatedly declare them with extern keyword.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 include/net/sctp/sctp.h |    3 +++
 net/sctp/socket.c       |    5 -----
 net/sctp/sysctl.c       |    4 ----
 3 files changed, 3 insertions(+), 9 deletions(-)

diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
index 856f01c..c56a438 100644
--- a/include/net/sctp/sctp.h
+++ b/include/net/sctp/sctp.h
@@ -166,6 +166,9 @@ void sctp_remaddr_proc_exit(struct net *net);
   */
 extern struct kmem_cache *sctp_chunk_cachep __read_mostly;
 extern struct kmem_cache *sctp_bucket_cachep __read_mostly;
+extern long sysctl_sctp_mem[3];
+extern int sysctl_sctp_rmem[3];
+extern int sysctl_sctp_wmem[3];
 
 /*
  *  Section:  Macros, externs, and inlines
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index f1a6539..f09de7f 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -102,11 +102,6 @@ static int sctp_autobind(struct sock *sk);
 static void sctp_sock_migrate(struct sock *, struct sock *,
 			      struct sctp_association *, sctp_socket_type_t);
 
-extern struct kmem_cache *sctp_bucket_cachep;
-extern long sysctl_sctp_mem[3];
-extern int sysctl_sctp_rmem[3];
-extern int sysctl_sctp_wmem[3];
-
 static int sctp_memory_pressure;
 static atomic_long_t sctp_memory_allocated;
 struct percpu_counter sctp_sockets_allocated;
diff --git a/net/sctp/sysctl.c b/net/sctp/sysctl.c
index 2e9ada1..26d50c5 100644
--- a/net/sctp/sysctl.c
+++ b/net/sctp/sysctl.c
@@ -58,10 +58,6 @@ static unsigned long max_autoclose_max =
 	(MAX_SCHEDULE_TIMEOUT / HZ > UINT_MAX)
 	? UINT_MAX : MAX_SCHEDULE_TIMEOUT / HZ;
 
-extern long sysctl_sctp_mem[3];
-extern int sysctl_sctp_rmem[3];
-extern int sysctl_sctp_wmem[3];
-
 static int proc_sctp_do_hmac_alg(struct ctl_table *ctl, int write,
 				void __user *buffer, size_t *lenp,
 				loff_t *ppos);
-- 
1.7.9.5
