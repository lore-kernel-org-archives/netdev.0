From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: use const in tcp.h
Date: Mon, 18 Oct 2004 16:01:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041018160107.7fde661b@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

More trivial janitor stuff, const usage in accessors.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h	2004-10-15 10:34:33 -07:00
+++ b/include/net/tcp.h	2004-10-15 10:34:33 -07:00
@@ -958,8 +958,8 @@
 extern void tcp_init_xmit_timers(struct sock *);
 extern void tcp_clear_xmit_timers(struct sock *);
 
-extern void tcp_delete_keepalive_timer (struct sock *);
-extern void tcp_reset_keepalive_timer (struct sock *, unsigned long);
+extern void tcp_delete_keepalive_timer(struct sock *);
+extern void tcp_reset_keepalive_timer(struct sock *, unsigned long);
 extern unsigned int tcp_sync_mss(struct sock *sk, u32 pmtu);
 extern unsigned int tcp_current_mss(struct sock *sk, int large);
 
@@ -1080,7 +1080,7 @@
  * Rcv_nxt can be after the window if our peer push more data
  * than the offered window.
  */
-static __inline__ u32 tcp_receive_window(struct tcp_opt *tp)
+static __inline__ u32 tcp_receive_window(const struct tcp_opt *tp)
 {
 	s32 win = tp->rcv_wup + tp->rcv_wnd - tp->rcv_nxt;
 
@@ -1158,18 +1158,19 @@
 /* Due to TSO, an SKB can be composed of multiple actual
  * packets.  To keep these tracked properly, we use this.
  */
-static inline int tcp_skb_pcount(struct sk_buff *skb)
+static inline int tcp_skb_pcount(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->tso_segs;
 }
 
 /* This is valid iff tcp_skb_pcount() > 1. */
-static inline int tcp_skb_mss(struct sk_buff *skb)
+static inline int tcp_skb_mss(const struct sk_buff *skb)
 {
 	return skb_shinfo(skb)->tso_size;
 }
 
-static inline void tcp_inc_pcount(tcp_pcount_t *count, struct sk_buff *skb)
+static inline void tcp_inc_pcount(tcp_pcount_t *count,
+				  const struct sk_buff *skb)
 {
 	count->val += tcp_skb_pcount(skb);
 }
@@ -1184,13 +1185,14 @@
 	count->val -= amt;
 }
 
-static inline void tcp_dec_pcount(tcp_pcount_t *count, struct sk_buff *skb)
+static inline void tcp_dec_pcount(tcp_pcount_t *count, 
+				  const struct sk_buff *skb)
 {
 	count->val -= tcp_skb_pcount(skb);
 }
 
 static inline void tcp_dec_pcount_approx(tcp_pcount_t *count,
-					 struct sk_buff *skb)
+					 const struct sk_buff *skb)
 {
 	if (count->val) {
 		count->val -= tcp_skb_pcount(skb);
@@ -1199,7 +1201,7 @@
 	}
 }
 
-static inline __u32 tcp_get_pcount(tcp_pcount_t *count)
+static inline __u32 tcp_get_pcount(const tcp_pcount_t *count)
 {
 	return count->val;
 }
@@ -1209,8 +1211,9 @@
 	count->val = val;
 }
 
-static inline void tcp_packets_out_inc(struct sock *sk, struct tcp_opt *tp,
-				       struct sk_buff *skb)
+static inline void tcp_packets_out_inc(struct sock *sk, 
+				       struct tcp_opt *tp,
+				       const struct sk_buff *skb)
 {
 	int orig = tcp_get_pcount(&tp->packets_out);
 
@@ -1219,7 +1222,8 @@
 		tcp_reset_xmit_timer(sk, TCP_TIME_RETRANS, tp->rto);
 }
 
-static inline void tcp_packets_out_dec(struct tcp_opt *tp, struct sk_buff *skb)
+static inline void tcp_packets_out_dec(struct tcp_opt *tp, 
+				       const struct sk_buff *skb)
 {
 	tcp_dec_pcount(&tp->packets_out, skb);
 }
@@ -1238,7 +1242,7 @@
  *	"Packets left network, but not honestly ACKed yet" PLUS
  *	"Packets fast retransmitted"
  */
-static __inline__ unsigned int tcp_packets_in_flight(struct tcp_opt *tp)
+static __inline__ unsigned int tcp_packets_in_flight(const struct tcp_opt *tp)
 {
 	return (tcp_get_pcount(&tp->packets_out) -
 		tcp_get_pcount(&tp->left_out) +
@@ -1405,18 +1409,19 @@
 /* Slow start with delack produces 3 packets of burst, so that
  * it is safe "de facto".
  */
-static __inline__ __u32 tcp_max_burst(struct tcp_opt *tp)
+static __inline__ __u32 tcp_max_burst(const struct tcp_opt *tp)
 {
 	return 3;
 }
 
-static __inline__ int tcp_minshall_check(struct tcp_opt *tp)
+static __inline__ int tcp_minshall_check(const struct tcp_opt *tp)
 {
 	return after(tp->snd_sml,tp->snd_una) &&
 		!after(tp->snd_sml, tp->snd_nxt);
 }
 
-static __inline__ void tcp_minshall_update(struct tcp_opt *tp, int mss, struct sk_buff *skb)
+static __inline__ void tcp_minshall_update(struct tcp_opt *tp, int mss, 
+					   const struct sk_buff *skb)
 {
 	if (skb->len < mss)
 		tp->snd_sml = TCP_SKB_CB(skb)->end_seq;
@@ -1431,7 +1436,8 @@
  */
 
 static __inline__ int
-tcp_nagle_check(struct tcp_opt *tp, struct sk_buff *skb, unsigned mss_now, int nonagle)
+tcp_nagle_check(const struct tcp_opt *tp, const struct sk_buff *skb, 
+		unsigned mss_now, int nonagle)
 {
 	return (skb->len < mss_now &&
 		!(TCP_SKB_CB(skb)->flags & TCPCB_FLAG_FIN) &&
@@ -1446,7 +1452,8 @@
 /* This checks if the data bearing packet SKB (usually sk->sk_send_head)
  * should be put on the wire right now.
  */
-static __inline__ int tcp_snd_test(struct tcp_opt *tp, struct sk_buff *skb,
+static __inline__ int tcp_snd_test(const struct tcp_opt *tp, 
+				   struct sk_buff *skb,
 				   unsigned cur_mss, int nonagle)
 {
 	int pkts = tcp_skb_pcount(skb);
@@ -1493,7 +1500,8 @@
 		tcp_reset_xmit_timer(sk, TCP_TIME_PROBE0, tp->rto);
 }
 
-static __inline__ int tcp_skb_is_last(struct sock *sk, struct sk_buff *skb)
+static __inline__ int tcp_skb_is_last(const struct sock *sk, 
+				      const struct sk_buff *skb)
 {
 	return skb->next == (struct sk_buff *)&sk->sk_write_queue;
 }
@@ -1544,7 +1552,7 @@
 	tp->snd_wl1 = seq;
 }
 
-extern void			tcp_destroy_sock(struct sock *sk);
+extern void tcp_destroy_sock(struct sock *sk);
 
 
 /*
@@ -1618,7 +1626,7 @@
 #undef STATE_TRACE
 
 #ifdef STATE_TRACE
-static char *statename[]={
+static const char *statename[]={
 	"Unused","Established","Syn Sent","Syn Recv",
 	"Fin Wait 1","Fin Wait 2","Time Wait", "Close",
 	"Close Wait","Last ACK","Listen","Closing"
@@ -1889,17 +1897,17 @@
 		wake_up(&tcp_lhash_wait);
 }
 
-static inline int keepalive_intvl_when(struct tcp_opt *tp)
+static inline int keepalive_intvl_when(const struct tcp_opt *tp)
 {
 	return tp->keepalive_intvl ? : sysctl_tcp_keepalive_intvl;
 }
 
-static inline int keepalive_time_when(struct tcp_opt *tp)
+static inline int keepalive_time_when(const struct tcp_opt *tp)
 {
 	return tp->keepalive_time ? : sysctl_tcp_keepalive_time;
 }
 
-static inline int tcp_fin_time(struct tcp_opt *tp)
+static inline int tcp_fin_time(const struct tcp_opt *tp)
 {
 	int fin_timeout = tp->linger2 ? : sysctl_tcp_fin_timeout;
 
@@ -1909,7 +1917,7 @@
 	return fin_timeout;
 }
 
-static inline int tcp_paws_check(struct tcp_opt *tp, int rst)
+static inline int tcp_paws_check(const struct tcp_opt *tp, int rst)
 {
 	if ((s32)(tp->rcv_tsval - tp->ts_recent) >= 0)
 		return 0;
