From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 9/11] [NET] Reorder struct sock
Date: Wed, 9 Mar 2005 20:51:04 +0100
Message-ID: <20050309195104.GQ31837@postel.suug.ch>
References: <20050309194521.GH31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050309194521.GH31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Reorders struct sock to avoid padding and shrinks the following
fields to more appropriate sizes saving 12 bytes and some more
on 64bit architectures.

sk_shutdown: char -> 2 bits
sk_no_checks: char -> 2 bits
sk_userlocks: char -> 4 bits

Signed-off-by: Thomas Graf <tgraf@suug.ch>

--- linux-2.6.11-rc4.orig/include/net/sock.h	2005-03-09 15:22:43.000000000 +0100
+++ linux-2.6.11-rc4/include/net/sock.h	2005-03-09 15:33:33.000000000 +0100
@@ -184,28 +184,30 @@
 #define sk_node			__sk_common.skc_node
 #define sk_bind_node		__sk_common.skc_bind_node
 #define sk_refcnt		__sk_common.skc_refcnt
-	unsigned char		sk_shutdown;
-	unsigned char		sk_userlocks;
-	socket_lock_t		sk_lock;
+	unsigned char		sk_shutdown : 2,
+				sk_no_check : 2,
+				sk_userlocks : 4;
+	unsigned char		sk_protocol;
+	unsigned short		sk_type;
 	int			sk_rcvbuf;
+	socket_lock_t		sk_lock;
 	wait_queue_head_t	*sk_sleep;
 	struct dst_entry	*sk_dst_cache;
-	rwlock_t		sk_dst_lock;
 	struct xfrm_policy	*sk_policy[2];
+	rwlock_t		sk_dst_lock;
 	atomic_t		sk_rmem_alloc;
-	struct sk_buff_head	sk_receive_queue;
 	atomic_t		sk_wmem_alloc;
-	struct sk_buff_head	sk_write_queue;
 	atomic_t		sk_omem_alloc;
+	struct sk_buff_head	sk_receive_queue;
+	struct sk_buff_head	sk_write_queue;
 	int			sk_wmem_queued;
 	int			sk_forward_alloc;
 	unsigned int		sk_allocation;
 	int			sk_sndbuf;
-	unsigned long 		sk_flags;
-	char		 	sk_no_check;
 	int			sk_route_caps;
-	unsigned long	        sk_lingertime;
 	int			sk_hashent;
+	unsigned long 		sk_flags;
+	unsigned long	        sk_lingertime;
 	/*
 	 * The backlog queue is special, it is always used with
 	 * the per-socket spinlock held and requires low latency
@@ -215,16 +217,14 @@
 		struct sk_buff *head;
 		struct sk_buff *tail;
 	} sk_backlog;
-	rwlock_t		sk_callback_lock;
 	struct sk_buff_head	sk_error_queue;
 	struct proto		*sk_prot;
+	rwlock_t		sk_callback_lock;
 	int			sk_err,
 				sk_err_soft;
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
-	unsigned short		sk_type;
-	unsigned char		sk_protocol;
 	struct ucred		sk_peercred;
 	int			sk_rcvlowat;
 	long			sk_rcvtimeo;
@@ -238,11 +238,10 @@
 	void			*sk_user_data;
 	struct module		*sk_owner;
 	struct page		*sk_sndmsg_page;
-	__u32			sk_sndmsg_off;
 	struct sk_buff		*sk_send_head;
+	__u32			sk_sndmsg_off;
 	int			sk_write_pending;
 	void			*sk_security;
-	/* three bytes hole, try to pack */
 	void			(*sk_state_change)(struct sock *sk);
 	void			(*sk_data_ready)(struct sock *sk, int bytes);
 	void			(*sk_write_space)(struct sock *sk);
