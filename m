From: akpm@osdl.org
Subject: [patch 8/18] gcc-3.5: irda
Date: Sun, 25 Jan 2004 03:07:28 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200401251107.i0PB7So25081@mail.osdl.org>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



include/net/irda/timer.h:87: sorry, unimplemented: inlining failed in call to 'irlmp_start_discovery_timer': function body not available



---

 include/net/irda/irlmp_frame.h |    2 +-
 include/net/irda/timer.h       |   18 +++++++++---------
 net/irda/af_irda.c             |    4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff -puN include/net/irda/timer.h~gcc-35-irda include/net/irda/timer.h
--- 25/include/net/irda/timer.h~gcc-35-irda	2004-01-23 17:48:57.000000000 -0800
+++ 25-akpm/include/net/irda/timer.h	2004-01-23 17:48:57.000000000 -0800
@@ -74,19 +74,19 @@ typedef void (*TIMER_CALLBACK)(void *);
 void irda_start_timer(struct timer_list *ptimer, int timeout, void* data,
 		      TIMER_CALLBACK callback);
 
-inline void irlap_start_slot_timer(struct irlap_cb *self, int timeout);
-inline void irlap_start_query_timer(struct irlap_cb *self, int timeout);
-inline void irlap_start_final_timer(struct irlap_cb *self, int timeout);
-inline void irlap_start_wd_timer(struct irlap_cb *self, int timeout);
-inline void irlap_start_backoff_timer(struct irlap_cb *self, int timeout);
+void irlap_start_slot_timer(struct irlap_cb *self, int timeout);
+void irlap_start_query_timer(struct irlap_cb *self, int timeout);
+void irlap_start_final_timer(struct irlap_cb *self, int timeout);
+void irlap_start_wd_timer(struct irlap_cb *self, int timeout);
+void irlap_start_backoff_timer(struct irlap_cb *self, int timeout);
 
 void irlap_start_mbusy_timer(struct irlap_cb *self, int timeout);
 void irlap_stop_mbusy_timer(struct irlap_cb *);
 
-inline void irlmp_start_watchdog_timer(struct lsap_cb *, int timeout);
-inline void irlmp_start_discovery_timer(struct irlmp_cb *, int timeout);
-inline void irlmp_start_idle_timer(struct lap_cb *, int timeout);
-inline void irlmp_stop_idle_timer(struct lap_cb *self); 
+void irlmp_start_watchdog_timer(struct lsap_cb *, int timeout);
+void irlmp_start_discovery_timer(struct irlmp_cb *, int timeout);
+void irlmp_start_idle_timer(struct lap_cb *, int timeout);
+void irlmp_stop_idle_timer(struct lap_cb *self);
 
 #endif
 
diff -puN include/net/irda/irlmp_frame.h~gcc-35-irda include/net/irda/irlmp_frame.h
--- 25/include/net/irda/irlmp_frame.h~gcc-35-irda	2004-01-23 17:48:57.000000000 -0800
+++ 25-akpm/include/net/irda/irlmp_frame.h	2004-01-23 17:48:57.000000000 -0800
@@ -40,7 +40,7 @@
 
 #define CONTROL_BIT    0x80
 
-inline void irlmp_send_data_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap, 
+void irlmp_send_data_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap,
 				int expedited, struct sk_buff *skb);
 void irlmp_send_lcf_pdu(struct lap_cb *self, __u8 dlsap, __u8 slsap, 
 			__u8 opcode, struct sk_buff *skb);
diff -puN net/irda/af_irda.c~gcc-35-irda net/irda/af_irda.c
--- 25/net/irda/af_irda.c~gcc-35-irda	2004-01-23 20:12:21.000000000 -0800
+++ 25-akpm/net/irda/af_irda.c	2004-01-23 20:15:11.000000000 -0800
@@ -1089,7 +1089,7 @@ static int irda_create(struct socket *so
 		return -ENOMEM;
 
 	/* Allocate IrDA socket */
-	self = irda_sk(sk) = kmalloc(sizeof(struct irda_sock), GFP_ATOMIC);
+	self = sk->sk_protinfo = kmalloc(sizeof(struct irda_sock), GFP_ATOMIC);
 	if (self == NULL) {
 		sk_free(sk);
 		return -ENOMEM;
@@ -1208,7 +1208,7 @@ static int irda_release(struct socket *s
 	/* Destroy IrDA socket */
 	irda_destroy_socket(irda_sk(sk));
 	/* Prevent sock_def_destruct() to create havoc */
-	irda_sk(sk) = NULL;
+	sk->sk_protinfo = NULL;
 
 	sock_orphan(sk);
 	sock->sk   = NULL;

_
