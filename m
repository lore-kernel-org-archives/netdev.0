From: Richard Sailer <richard_siegfried@systemli.org>
Subject: [PATCH net-next 2/3] tcp: Move cc algorithms to own subdirectory
Date: Wed,  4 Oct 2017 00:22:12 +0200
Message-ID: <20171003222213.7996-3-richard_siegfried@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:59438 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdJCW3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:29:42 -0400
In-Reply-To: <20171003222213.7996-1-richard_siegfried@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Essentially the TCP code files consist of two groups:

  * main code and some utilities (13 files)
  * pluggable Congestion Control Algorithms (17 files)

Similar to the previous commit, this moves the Congestion control Algorithms to
a own subdirecty and updates the Makefiles accordingly to make the source tree
more well structured and self explaining.

Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
---
 net/ipv4/tcp/Makefile                       | 18 ++----------------
 net/ipv4/tcp/cc_algos/Makefile              | 21 +++++++++++++++++++++
 net/ipv4/tcp/{ => cc_algos}/tcp_bbr.c       |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_bic.c       |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_cdg.c       |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_cubic.c     |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_dctcp.c     |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_highspeed.c |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_htcp.c      |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_hybla.c     |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_illinois.c  |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_lp.c        |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_nv.c        |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_scalable.c  |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_vegas.c     |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_vegas.h     |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_veno.c      |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_westwood.c  |  0
 net/ipv4/tcp/{ => cc_algos}/tcp_yeah.c      |  0
 19 files changed, 23 insertions(+), 16 deletions(-)
 create mode 100644 net/ipv4/tcp/cc_algos/Makefile
 rename net/ipv4/tcp/{ => cc_algos}/tcp_bbr.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_bic.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_cdg.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_cubic.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_dctcp.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_highspeed.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_htcp.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_hybla.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_illinois.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_lp.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_nv.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_scalable.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_vegas.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_vegas.h (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_veno.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_westwood.c (100%)
 rename net/ipv4/tcp/{ => cc_algos}/tcp_yeah.c (100%)

diff --git a/net/ipv4/tcp/Makefile b/net/ipv4/tcp/Makefile
index 91d2c991a243..60e96525a489 100644
--- a/net/ipv4/tcp/Makefile
+++ b/net/ipv4/tcp/Makefile
@@ -8,19 +8,5 @@ obj-y     := tcp.o tcp_input.o tcp_output.o tcp_timer.o \
 
 obj-$(CONFIG_INET_TCP_DIAG)     +=  tcp_diag.o
 obj-$(CONFIG_NET_TCPPROBE)      +=  tcp_probe.o
-obj-$(CONFIG_TCP_CONG_BBR)      +=  tcp_bbr.o
-obj-$(CONFIG_TCP_CONG_BIC)      +=  tcp_bic.o
-obj-$(CONFIG_TCP_CONG_CDG)      +=  tcp_cdg.o
-obj-$(CONFIG_TCP_CONG_CUBIC)    +=  tcp_cubic.o
-obj-$(CONFIG_TCP_CONG_DCTCP)    +=  tcp_dctcp.o
-obj-$(CONFIG_TCP_CONG_WESTWOOD) +=  tcp_westwood.o
-obj-$(CONFIG_TCP_CONG_HSTCP)    +=  tcp_highspeed.o
-obj-$(CONFIG_TCP_CONG_HYBLA)    +=  tcp_hybla.o
-obj-$(CONFIG_TCP_CONG_HTCP)     +=  tcp_htcp.o
-obj-$(CONFIG_TCP_CONG_VEGAS)    +=  tcp_vegas.o
-obj-$(CONFIG_TCP_CONG_NV)       +=  tcp_nv.o
-obj-$(CONFIG_TCP_CONG_VENO)     +=  tcp_veno.o
-obj-$(CONFIG_TCP_CONG_SCALABLE) +=  tcp_scalable.o
-obj-$(CONFIG_TCP_CONG_LP)       +=  tcp_lp.o
-obj-$(CONFIG_TCP_CONG_YEAH)     +=  tcp_yeah.o
-obj-$(CONFIG_TCP_CONG_ILLINOIS) +=  tcp_illinois.o
+
+obj-$(CONFIG_TCP_CONG_ADVANCED) +=  cc_algos/
diff --git a/net/ipv4/tcp/cc_algos/Makefile b/net/ipv4/tcp/cc_algos/Makefile
new file mode 100644
index 000000000000..81999dd2a045
--- /dev/null
+++ b/net/ipv4/tcp/cc_algos/Makefile
@@ -0,0 +1,21 @@
+#
+# Makefile for all pluggable TCP congestion control algorithms
+#
+
+
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
diff --git a/net/ipv4/tcp/tcp_bbr.c b/net/ipv4/tcp/cc_algos/tcp_bbr.c
similarity index 100%
rename from net/ipv4/tcp/tcp_bbr.c
rename to net/ipv4/tcp/cc_algos/tcp_bbr.c
diff --git a/net/ipv4/tcp/tcp_bic.c b/net/ipv4/tcp/cc_algos/tcp_bic.c
similarity index 100%
rename from net/ipv4/tcp/tcp_bic.c
rename to net/ipv4/tcp/cc_algos/tcp_bic.c
diff --git a/net/ipv4/tcp/tcp_cdg.c b/net/ipv4/tcp/cc_algos/tcp_cdg.c
similarity index 100%
rename from net/ipv4/tcp/tcp_cdg.c
rename to net/ipv4/tcp/cc_algos/tcp_cdg.c
diff --git a/net/ipv4/tcp/tcp_cubic.c b/net/ipv4/tcp/cc_algos/tcp_cubic.c
similarity index 100%
rename from net/ipv4/tcp/tcp_cubic.c
rename to net/ipv4/tcp/cc_algos/tcp_cubic.c
diff --git a/net/ipv4/tcp/tcp_dctcp.c b/net/ipv4/tcp/cc_algos/tcp_dctcp.c
similarity index 100%
rename from net/ipv4/tcp/tcp_dctcp.c
rename to net/ipv4/tcp/cc_algos/tcp_dctcp.c
diff --git a/net/ipv4/tcp/tcp_highspeed.c b/net/ipv4/tcp/cc_algos/tcp_highspeed.c
similarity index 100%
rename from net/ipv4/tcp/tcp_highspeed.c
rename to net/ipv4/tcp/cc_algos/tcp_highspeed.c
diff --git a/net/ipv4/tcp/tcp_htcp.c b/net/ipv4/tcp/cc_algos/tcp_htcp.c
similarity index 100%
rename from net/ipv4/tcp/tcp_htcp.c
rename to net/ipv4/tcp/cc_algos/tcp_htcp.c
diff --git a/net/ipv4/tcp/tcp_hybla.c b/net/ipv4/tcp/cc_algos/tcp_hybla.c
similarity index 100%
rename from net/ipv4/tcp/tcp_hybla.c
rename to net/ipv4/tcp/cc_algos/tcp_hybla.c
diff --git a/net/ipv4/tcp/tcp_illinois.c b/net/ipv4/tcp/cc_algos/tcp_illinois.c
similarity index 100%
rename from net/ipv4/tcp/tcp_illinois.c
rename to net/ipv4/tcp/cc_algos/tcp_illinois.c
diff --git a/net/ipv4/tcp/tcp_lp.c b/net/ipv4/tcp/cc_algos/tcp_lp.c
similarity index 100%
rename from net/ipv4/tcp/tcp_lp.c
rename to net/ipv4/tcp/cc_algos/tcp_lp.c
diff --git a/net/ipv4/tcp/tcp_nv.c b/net/ipv4/tcp/cc_algos/tcp_nv.c
similarity index 100%
rename from net/ipv4/tcp/tcp_nv.c
rename to net/ipv4/tcp/cc_algos/tcp_nv.c
diff --git a/net/ipv4/tcp/tcp_scalable.c b/net/ipv4/tcp/cc_algos/tcp_scalable.c
similarity index 100%
rename from net/ipv4/tcp/tcp_scalable.c
rename to net/ipv4/tcp/cc_algos/tcp_scalable.c
diff --git a/net/ipv4/tcp/tcp_vegas.c b/net/ipv4/tcp/cc_algos/tcp_vegas.c
similarity index 100%
rename from net/ipv4/tcp/tcp_vegas.c
rename to net/ipv4/tcp/cc_algos/tcp_vegas.c
diff --git a/net/ipv4/tcp/tcp_vegas.h b/net/ipv4/tcp/cc_algos/tcp_vegas.h
similarity index 100%
rename from net/ipv4/tcp/tcp_vegas.h
rename to net/ipv4/tcp/cc_algos/tcp_vegas.h
diff --git a/net/ipv4/tcp/tcp_veno.c b/net/ipv4/tcp/cc_algos/tcp_veno.c
similarity index 100%
rename from net/ipv4/tcp/tcp_veno.c
rename to net/ipv4/tcp/cc_algos/tcp_veno.c
diff --git a/net/ipv4/tcp/tcp_westwood.c b/net/ipv4/tcp/cc_algos/tcp_westwood.c
similarity index 100%
rename from net/ipv4/tcp/tcp_westwood.c
rename to net/ipv4/tcp/cc_algos/tcp_westwood.c
diff --git a/net/ipv4/tcp/tcp_yeah.c b/net/ipv4/tcp/cc_algos/tcp_yeah.c
similarity index 100%
rename from net/ipv4/tcp/tcp_yeah.c
rename to net/ipv4/tcp/cc_algos/tcp_yeah.c
-- 
2.14.1
