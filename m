From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (repost) TCP westwood bw_sample
Date: Fri, 12 Mar 2004 09:30:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312093010.650caaa0@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

TCP westwood bw_sample element in tcp_opt is set but never used.
Repost of patch, because forgot part which removes it from tcp.h

diff -Nru a/include/linux/tcp.h b/include/linux/tcp.h
--- a/include/linux/tcp.h	Fri Mar 12 09:29:03 2004
+++ b/include/linux/tcp.h	Fri Mar 12 09:29:03 2004
@@ -377,7 +377,6 @@
 
 /* TCP Westwood structure */
         struct {
-                __u32    bw_sample;        /* bandwidth sample */
                 __u32    bw_ns_est;        /* first bandwidth estimation..not too smoothed 8) */
                 __u32    bw_est;           /* bandwidth estimate */
                 __u32    rtt_win_sx;       /* here starts a new evaluation... */
diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Fri Mar 12 09:29:03 2004
+++ b/net/ipv4/tcp_input.c	Fri Mar 12 09:29:03 2004
@@ -2065,7 +2065,6 @@
 {
         struct tcp_opt *tp = tcp_sk(sk);
 
-        tp->westwood.bw_sample = 0;
         tp->westwood.bw_ns_est = 0;
         tp->westwood.bw_est = 0;
         tp->westwood.accounted = 0;
@@ -2088,14 +2087,13 @@
 static void westwood_filter(struct sock *sk, __u32 delta)
 {
 	struct tcp_opt *tp = tcp_sk(sk);
-	__u32 sample = tp->westwood.bk / delta;
 
 	tp->westwood.bw_ns_est =
-		westwood_do_filter(tp->westwood.bw_ns_est, sample);
+		westwood_do_filter(tp->westwood.bw_ns_est, 
+				   tp->westwood.bk / delta);
 	tp->westwood.bw_est =
 		westwood_do_filter(tp->westwood.bw_est,
 				   tp->westwood.bw_ns_est);
-	tp->westwood.bw_sample = sample;
 }
 
 /* @westwood_update_rttmin
