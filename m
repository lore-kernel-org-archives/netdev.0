From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] TCP westwood bw_sample set never used
Date: Fri, 12 Mar 2004 09:15:05 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040312091505.593443d1@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Angelo Dell'Aera" <buffer@antifork.org>,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Found this while looking in detail at TCP.  The westwood.bw_sample element
it tcp_opt is set but not used by the existing code in 2.6.4

diff -Nru a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
--- a/net/ipv4/tcp_input.c	Fri Mar 12 09:11:42 2004
+++ b/net/ipv4/tcp_input.c	Fri Mar 12 09:11:42 2004
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
