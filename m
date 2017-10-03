From: Richard Sailer <richard_siegfried@systemli.org>
Subject: [PATCH net-next 1/3] net/ipv4: Move shared tcp code to own subdirectory
Date: Wed,  4 Oct 2017 00:22:11 +0200
Message-ID: <20171003222213.7996-2-richard_siegfried@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:59438 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdJCW3e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:29:34 -0400
In-Reply-To: <20171003222213.7996-1-richard_siegfried@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4 contains around 100 source files containing the IP implementation
and various other functionality (UDP, TCP, xfrm, etc.). 30 of them make up
the TCP implementation.

I think moving the TCP implementation to a own subdirectory
makes the source tree more explorable and well structured.

Note: This only affects the TCP Code shared by IPv4 and IPv6,
the IPv4 specific part (tcp_ipv4.c and tcp_offload.c) is left in
net/ipv4/.

This creates the directory, moves the files and updates the Makefiles
acordingly.

Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
---
 net/ipv4/Makefile                  | 25 ++-----------------------
 net/ipv4/tcp/Makefile              | 26 ++++++++++++++++++++++++++
 net/ipv4/{ => tcp}/tcp.c           |  0
 net/ipv4/{ => tcp}/tcp_bbr.c       |  0
 net/ipv4/{ => tcp}/tcp_bic.c       |  0
 net/ipv4/{ => tcp}/tcp_cdg.c       |  0
 net/ipv4/{ => tcp}/tcp_cong.c      |  0
 net/ipv4/{ => tcp}/tcp_cubic.c     |  0
 net/ipv4/{ => tcp}/tcp_dctcp.c     |  0
 net/ipv4/{ => tcp}/tcp_diag.c      |  0
 net/ipv4/{ => tcp}/tcp_fastopen.c  |  0
 net/ipv4/{ => tcp}/tcp_highspeed.c |  0
 net/ipv4/{ => tcp}/tcp_htcp.c      |  0
 net/ipv4/{ => tcp}/tcp_hybla.c     |  0
 net/ipv4/{ => tcp}/tcp_illinois.c  |  0
 net/ipv4/{ => tcp}/tcp_input.c     |  0
 net/ipv4/{ => tcp}/tcp_lp.c        |  0
 net/ipv4/{ => tcp}/tcp_metrics.c   |  0
 net/ipv4/{ => tcp}/tcp_minisocks.c |  0
 net/ipv4/{ => tcp}/tcp_nv.c        |  0
 net/ipv4/{ => tcp}/tcp_output.c    |  0
 net/ipv4/{ => tcp}/tcp_probe.c     |  0
 net/ipv4/{ => tcp}/tcp_rate.c      |  0
 net/ipv4/{ => tcp}/tcp_recovery.c  |  0
 net/ipv4/{ => tcp}/tcp_scalable.c  |  0
 net/ipv4/{ => tcp}/tcp_timer.c     |  0
 net/ipv4/{ => tcp}/tcp_ulp.c       |  0
 net/ipv4/{ => tcp}/tcp_vegas.c     |  0
 net/ipv4/{ => tcp}/tcp_vegas.h     |  0
 net/ipv4/{ => tcp}/tcp_veno.c      |  0
 net/ipv4/{ => tcp}/tcp_westwood.c  |  0
 net/ipv4/{ => tcp}/tcp_yeah.c      |  0
 32 files changed, 28 insertions(+), 23 deletions(-)
 create mode 100644 net/ipv4/tcp/Makefile
 rename net/ipv4/{ => tcp}/tcp.c (100%)
 rename net/ipv4/{ => tcp}/tcp_bbr.c (100%)
 rename net/ipv4/{ => tcp}/tcp_bic.c (100%)
 rename net/ipv4/{ => tcp}/tcp_cdg.c (100%)
 rename net/ipv4/{ => tcp}/tcp_cong.c (100%)
 rename net/ipv4/{ => tcp}/tcp_cubic.c (100%)
 rename net/ipv4/{ => tcp}/tcp_dctcp.c (100%)
 rename net/ipv4/{ => tcp}/tcp_diag.c (100%)
 rename net/ipv4/{ => tcp}/tcp_fastopen.c (100%)
 rename net/ipv4/{ => tcp}/tcp_highspeed.c (100%)
 rename net/ipv4/{ => tcp}/tcp_htcp.c (100%)
 rename net/ipv4/{ => tcp}/tcp_hybla.c (100%)
 rename net/ipv4/{ => tcp}/tcp_illinois.c (100%)
 rename net/ipv4/{ => tcp}/tcp_input.c (100%)
 rename net/ipv4/{ => tcp}/tcp_lp.c (100%)
 rename net/ipv4/{ => tcp}/tcp_metrics.c (100%)
 rename net/ipv4/{ => tcp}/tcp_minisocks.c (100%)
 rename net/ipv4/{ => tcp}/tcp_nv.c (100%)
 rename net/ipv4/{ => tcp}/tcp_output.c (100%)
 rename net/ipv4/{ => tcp}/tcp_probe.c (100%)
 rename net/ipv4/{ => tcp}/tcp_rate.c (100%)
 rename net/ipv4/{ => tcp}/tcp_recovery.c (100%)
 rename net/ipv4/{ => tcp}/tcp_scalable.c (100%)
 rename net/ipv4/{ => tcp}/tcp_timer.c (100%)
 rename net/ipv4/{ => tcp}/tcp_ulp.c (100%)
 rename net/ipv4/{ => tcp}/tcp_vegas.c (100%)
 rename net/ipv4/{ => tcp}/tcp_vegas.h (100%)
 rename net/ipv4/{ => tcp}/tcp_veno.c (100%)
 rename net/ipv4/{ => tcp}/tcp_westwood.c (100%)
 rename net/ipv4/{ => tcp}/tcp_yeah.c (100%)

diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index afcb435adfbe..a106a1cf0e11 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -2,14 +2,11 @@
 # Makefile for the Linux TCP/IP (INET) layer.
 #
 
-obj-y     := route.o inetpeer.o protocol.o \
+obj-y     := tcp/ route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
-	     tcp.o tcp_input.o tcp_output.o tcp_timer.o tcp_ipv4.o \
-	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
-	     tcp_rate.o tcp_recovery.o tcp_ulp.o \
-	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
+	     datagram.o raw.o udp.o udplite.o tcp_offload.o tcp_ipv4.o \
 	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o fib_notifier.o \
 	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
@@ -39,26 +36,8 @@ obj-$(CONFIG_INET_XFRM_MODE_TUNNEL) += xfrm4_mode_tunnel.o
 obj-$(CONFIG_IP_PNP) += ipconfig.o
 obj-$(CONFIG_NETFILTER)	+= netfilter.o netfilter/
 obj-$(CONFIG_INET_DIAG) += inet_diag.o 
-obj-$(CONFIG_INET_TCP_DIAG) += tcp_diag.o
 obj-$(CONFIG_INET_UDP_DIAG) += udp_diag.o
 obj-$(CONFIG_INET_RAW_DIAG) += raw_diag.o
-obj-$(CONFIG_NET_TCPPROBE) += tcp_probe.o
-obj-$(CONFIG_TCP_CONG_BBR) += tcp_bbr.o
-obj-$(CONFIG_TCP_CONG_BIC) += tcp_bic.o
-obj-$(CONFIG_TCP_CONG_CDG) += tcp_cdg.o
-obj-$(CONFIG_TCP_CONG_CUBIC) += tcp_cubic.o
-obj-$(CONFIG_TCP_CONG_DCTCP) += tcp_dctcp.o
-obj-$(CONFIG_TCP_CONG_WESTWOOD) += tcp_westwood.o
-obj-$(CONFIG_TCP_CONG_HSTCP) += tcp_highspeed.o
-obj-$(CONFIG_TCP_CONG_HYBLA) += tcp_hybla.o
-obj-$(CONFIG_TCP_CONG_HTCP) += tcp_htcp.o
-obj-$(CONFIG_TCP_CONG_VEGAS) += tcp_vegas.o
-obj-$(CONFIG_TCP_CONG_NV) += tcp_nv.o
-obj-$(CONFIG_TCP_CONG_VENO) += tcp_veno.o
-obj-$(CONFIG_TCP_CONG_SCALABLE) += tcp_scalable.o
-obj-$(CONFIG_TCP_CONG_LP) += tcp_lp.o
-obj-$(CONFIG_TCP_CONG_YEAH) += tcp_yeah.o
-obj-$(CONFIG_TCP_CONG_ILLINOIS) += tcp_illinois.o
 obj-$(CONFIG_NETLABEL) += cipso_ipv4.o
 
 obj-$(CONFIG_XFRM) += xfrm4_policy.o xfrm4_state.o xfrm4_input.o \
diff --git a/net/ipv4/tcp/Makefile b/net/ipv4/tcp/Makefile
new file mode 100644
index 000000000000..91d2c991a243
--- /dev/null
+++ b/net/ipv4/tcp/Makefile
@@ -0,0 +1,26 @@
+#
+# Makefile for Linux TCP
+#
+
+obj-y     := tcp.o tcp_input.o tcp_output.o tcp_timer.o \
+	     tcp_minisocks.o tcp_cong.o tcp_metrics.o tcp_fastopen.o \
+	     tcp_rate.o tcp_recovery.o tcp_ulp.o
+
+obj-$(CONFIG_INET_TCP_DIAG)     +=  tcp_diag.o
+obj-$(CONFIG_NET_TCPPROBE)      +=  tcp_probe.o
+obj-$(CONFIG_TCP_CONG_BBR)      +=  tcp_bbr.o
+obj-$(CONFIG_TCP_CONG_BIC)      +=  tcp_bic.o
+obj-$(CONFIG_TCP_CONG_CDG)      +=  tcp_cdg.o
+obj-$(CONFIG_TCP_CONG_CUBIC)    +=  tcp_cubic.o
+obj-$(CONFIG_TCP_CONG_DCTCP)    +=  tcp_dctcp.o
+obj-$(CONFIG_TCP_CONG_WESTWOOD) +=  tcp_westwood.o
+obj-$(CONFIG_TCP_CONG_HSTCP)    +=  tcp_highspeed.o
+obj-$(CONFIG_TCP_CONG_HYBLA)    +=  tcp_hybla.o
+obj-$(CONFIG_TCP_CONG_HTCP)     +=  tcp_htcp.o
+obj-$(CONFIG_TCP_CONG_VEGAS)    +=  tcp_vegas.o
+obj-$(CONFIG_TCP_CONG_NV)       +=  tcp_nv.o
+obj-$(CONFIG_TCP_CONG_VENO)     +=  tcp_veno.o
+obj-$(CONFIG_TCP_CONG_SCALABLE) +=  tcp_scalable.o
+obj-$(CONFIG_TCP_CONG_LP)       +=  tcp_lp.o
+obj-$(CONFIG_TCP_CONG_YEAH)     +=  tcp_yeah.o
+obj-$(CONFIG_TCP_CONG_ILLINOIS) +=  tcp_illinois.o
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp/tcp.c
similarity index 100%
rename from net/ipv4/tcp.c
rename to net/ipv4/tcp/tcp.c
diff --git a/net/ipv4/tcp_bbr.c b/net/ipv4/tcp/tcp_bbr.c
similarity index 100%
rename from net/ipv4/tcp_bbr.c
rename to net/ipv4/tcp/tcp_bbr.c
diff --git a/net/ipv4/tcp_bic.c b/net/ipv4/tcp/tcp_bic.c
similarity index 100%
rename from net/ipv4/tcp_bic.c
rename to net/ipv4/tcp/tcp_bic.c
diff --git a/net/ipv4/tcp_cdg.c b/net/ipv4/tcp/tcp_cdg.c
similarity index 100%
rename from net/ipv4/tcp_cdg.c
rename to net/ipv4/tcp/tcp_cdg.c
diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp/tcp_cong.c
similarity index 100%
rename from net/ipv4/tcp_cong.c
rename to net/ipv4/tcp/tcp_cong.c
diff --git a/net/ipv4/tcp_cubic.c b/net/ipv4/tcp/tcp_cubic.c
similarity index 100%
rename from net/ipv4/tcp_cubic.c
rename to net/ipv4/tcp/tcp_cubic.c
diff --git a/net/ipv4/tcp_dctcp.c b/net/ipv4/tcp/tcp_dctcp.c
similarity index 100%
rename from net/ipv4/tcp_dctcp.c
rename to net/ipv4/tcp/tcp_dctcp.c
diff --git a/net/ipv4/tcp_diag.c b/net/ipv4/tcp/tcp_diag.c
similarity index 100%
rename from net/ipv4/tcp_diag.c
rename to net/ipv4/tcp/tcp_diag.c
diff --git a/net/ipv4/tcp_fastopen.c b/net/ipv4/tcp/tcp_fastopen.c
similarity index 100%
rename from net/ipv4/tcp_fastopen.c
rename to net/ipv4/tcp/tcp_fastopen.c
diff --git a/net/ipv4/tcp_highspeed.c b/net/ipv4/tcp/tcp_highspeed.c
similarity index 100%
rename from net/ipv4/tcp_highspeed.c
rename to net/ipv4/tcp/tcp_highspeed.c
diff --git a/net/ipv4/tcp_htcp.c b/net/ipv4/tcp/tcp_htcp.c
similarity index 100%
rename from net/ipv4/tcp_htcp.c
rename to net/ipv4/tcp/tcp_htcp.c
diff --git a/net/ipv4/tcp_hybla.c b/net/ipv4/tcp/tcp_hybla.c
similarity index 100%
rename from net/ipv4/tcp_hybla.c
rename to net/ipv4/tcp/tcp_hybla.c
diff --git a/net/ipv4/tcp_illinois.c b/net/ipv4/tcp/tcp_illinois.c
similarity index 100%
rename from net/ipv4/tcp_illinois.c
rename to net/ipv4/tcp/tcp_illinois.c
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp/tcp_input.c
similarity index 100%
rename from net/ipv4/tcp_input.c
rename to net/ipv4/tcp/tcp_input.c
diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp/tcp_lp.c
similarity index 100%
rename from net/ipv4/tcp_lp.c
rename to net/ipv4/tcp/tcp_lp.c
diff --git a/net/ipv4/tcp_metrics.c b/net/ipv4/tcp/tcp_metrics.c
similarity index 100%
rename from net/ipv4/tcp_metrics.c
rename to net/ipv4/tcp/tcp_metrics.c
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp/tcp_minisocks.c
similarity index 100%
rename from net/ipv4/tcp_minisocks.c
rename to net/ipv4/tcp/tcp_minisocks.c
diff --git a/net/ipv4/tcp_nv.c b/net/ipv4/tcp/tcp_nv.c
similarity index 100%
rename from net/ipv4/tcp_nv.c
rename to net/ipv4/tcp/tcp_nv.c
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp/tcp_output.c
similarity index 100%
rename from net/ipv4/tcp_output.c
rename to net/ipv4/tcp/tcp_output.c
diff --git a/net/ipv4/tcp_probe.c b/net/ipv4/tcp/tcp_probe.c
similarity index 100%
rename from net/ipv4/tcp_probe.c
rename to net/ipv4/tcp/tcp_probe.c
diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp/tcp_rate.c
similarity index 100%
rename from net/ipv4/tcp_rate.c
rename to net/ipv4/tcp/tcp_rate.c
diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp/tcp_recovery.c
similarity index 100%
rename from net/ipv4/tcp_recovery.c
rename to net/ipv4/tcp/tcp_recovery.c
diff --git a/net/ipv4/tcp_scalable.c b/net/ipv4/tcp/tcp_scalable.c
similarity index 100%
rename from net/ipv4/tcp_scalable.c
rename to net/ipv4/tcp/tcp_scalable.c
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp/tcp_timer.c
similarity index 100%
rename from net/ipv4/tcp_timer.c
rename to net/ipv4/tcp/tcp_timer.c
diff --git a/net/ipv4/tcp_ulp.c b/net/ipv4/tcp/tcp_ulp.c
similarity index 100%
rename from net/ipv4/tcp_ulp.c
rename to net/ipv4/tcp/tcp_ulp.c
diff --git a/net/ipv4/tcp_vegas.c b/net/ipv4/tcp/tcp_vegas.c
similarity index 100%
rename from net/ipv4/tcp_vegas.c
rename to net/ipv4/tcp/tcp_vegas.c
diff --git a/net/ipv4/tcp_vegas.h b/net/ipv4/tcp/tcp_vegas.h
similarity index 100%
rename from net/ipv4/tcp_vegas.h
rename to net/ipv4/tcp/tcp_vegas.h
diff --git a/net/ipv4/tcp_veno.c b/net/ipv4/tcp/tcp_veno.c
similarity index 100%
rename from net/ipv4/tcp_veno.c
rename to net/ipv4/tcp/tcp_veno.c
diff --git a/net/ipv4/tcp_westwood.c b/net/ipv4/tcp/tcp_westwood.c
similarity index 100%
rename from net/ipv4/tcp_westwood.c
rename to net/ipv4/tcp/tcp_westwood.c
diff --git a/net/ipv4/tcp_yeah.c b/net/ipv4/tcp/tcp_yeah.c
similarity index 100%
rename from net/ipv4/tcp_yeah.c
rename to net/ipv4/tcp/tcp_yeah.c
-- 
2.14.1
