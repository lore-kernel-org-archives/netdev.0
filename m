From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH 1/3] net: kill unused macros
Date: Wed, 15 Dec 2010 14:26:58 +0800
Message-ID: <4D085FB2.5050502@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Network-Maillist <netdev@vger.kernel.org>
To: paul.moore@hp.com, David Miller <davem@davemloft.net>,
	joe@perches.com, jslaby@suse.cz,
	Eric Dumazet <eric.dumazet@gmail.com>, tj@kernel.org,
	ebiederm@xmission.com, Alexey Dobriyan <a
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59200 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751037Ab0LOG2u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Dec 2010 01:28:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros never be used, so remove them.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
Include these changes to a patch for only netdev maillist,
Although these belong to different subsys.
---
 include/net/inet_connection_sock.h |    1 -
 include/net/tcp.h                  |    2 --
 net/atm/mpc.c                      |    2 --
 net/core/neighbour.c               |    1 -
 net/core/netpoll.c                 |    1 -
 net/netlabel/netlabel_cipso_v4.h   |    1 -
 net/netlabel/netlabel_mgmt.h       |    1 -
 net/netlabel/netlabel_unlabeled.h  |    1 -
 8 files changed, 0 insertions(+), 10 deletions(-)

diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
index 6c93a56..6ac4e3b 100644
--- a/include/net/inet_connection_sock.h
+++ b/include/net/inet_connection_sock.h
@@ -132,7 +132,6 @@ struct inet_connection_sock {
 #define ICSK_TIME_RETRANS	1	/* Retransmit timer */
 #define ICSK_TIME_DACK		2	/* Delayed ack timer */
 #define ICSK_TIME_PROBE0	3	/* Zero window probe timer */
-#define ICSK_TIME_KEEPOPEN	4	/* Keepalive timer */
 
 static inline struct inet_connection_sock *inet_csk(const struct sock *sk)
 {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 3f227ba..bd3c377 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1152,8 +1152,6 @@ struct tcp_md5sig_pool {
 	union tcp_md5sum_block	md5_blk;
 };
 
-#define TCP_MD5SIG_MAXKEYS	(~(u32)0)	/* really?! */
-
 /* - functions */
 extern int tcp_v4_md5_hash_skb(char *md5_hash, struct tcp_md5sig_key *key,
 			       struct sock *sk, struct request_sock *req,
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 74bcc66..644cdf0 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -64,8 +64,6 @@
 	do { if (0) printk(KERN_CONT format, ##args); } while (0)
 #endif
 
-#define MPOA_TAG_LEN 4
-
 /* mpc_daemon -> kernel */
 static void MPOA_trigger_rcvd(struct k_message *msg, struct mpoa_client *mpc);
 static void MPOA_res_reply_rcvd(struct k_message *msg, struct mpoa_client *mpc);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 8cc8f9a..60a9029 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -41,7 +41,6 @@
 
 #define NEIGH_PRINTK(x...) printk(x)
 #define NEIGH_NOPRINTK(x...) do { ; } while(0)
-#define NEIGH_PRINTK0 NEIGH_PRINTK
 #define NEIGH_PRINTK1 NEIGH_NOPRINTK
 #define NEIGH_PRINTK2 NEIGH_NOPRINTK
 
diff --git a/net/core/netpoll.c b/net/core/netpoll.c
index ee38acb..72d9b50 100644
--- a/net/core/netpoll.c
+++ b/net/core/netpoll.c
@@ -35,7 +35,6 @@
 
 #define MAX_UDP_CHUNK 1460
 #define MAX_SKBS 32
-#define MAX_QUEUE_DEPTH (MAX_SKBS / 2)
 
 static struct sk_buff_head skb_pool;
 
diff --git a/net/netlabel/netlabel_cipso_v4.h b/net/netlabel/netlabel_cipso_v4.h
index c8a4079..af7f335 100644
--- a/net/netlabel/netlabel_cipso_v4.h
+++ b/net/netlabel/netlabel_cipso_v4.h
@@ -107,7 +107,6 @@ enum {
 	NLBL_CIPSOV4_C_LISTALL,
 	__NLBL_CIPSOV4_C_MAX,
 };
-#define NLBL_CIPSOV4_C_MAX (__NLBL_CIPSOV4_C_MAX - 1)
 
 /* NetLabel CIPSOv4 attributes */
 enum {
diff --git a/net/netlabel/netlabel_mgmt.h b/net/netlabel/netlabel_mgmt.h
index 05d9643..0a25838 100644
--- a/net/netlabel/netlabel_mgmt.h
+++ b/net/netlabel/netlabel_mgmt.h
@@ -173,7 +173,6 @@ enum {
 	NLBL_MGMT_C_VERSION,
 	__NLBL_MGMT_C_MAX,
 };
-#define NLBL_MGMT_C_MAX (__NLBL_MGMT_C_MAX - 1)
 
 /* NetLabel Management attributes */
 enum {
diff --git a/net/netlabel/netlabel_unlabeled.h b/net/netlabel/netlabel_unlabeled.h
index 7aba635..0bc8dc3 100644
--- a/net/netlabel/netlabel_unlabeled.h
+++ b/net/netlabel/netlabel_unlabeled.h
@@ -180,7 +180,6 @@ enum {
 	NLBL_UNLABEL_C_STATICLISTDEF,
 	__NLBL_UNLABEL_C_MAX,
 };
-#define NLBL_UNLABEL_C_MAX (__NLBL_UNLABEL_C_MAX - 1)
 
 /* NetLabel Unlabeled attributes */
 enum {
-- 
1.6.3.3
