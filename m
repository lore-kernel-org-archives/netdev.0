From: Richard Sailer <richard_siegfried@systemli.org>
Subject: [PATCH net-next 3/3] Move shared tcp code to net/ipv4v6shared
Date: Wed,  4 Oct 2017 00:22:13 +0200
Message-ID: <20171003222213.7996-4-richard_siegfried@systemli.org>
References: <20171003222213.7996-1-richard_siegfried@systemli.org>
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.systemli.org ([198.167.223.214]:59438 "EHLO
        mail.systemli.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750841AbdJCW3h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 18:29:37 -0400
In-Reply-To: <20171003222213.7996-1-richard_siegfried@systemli.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently a lot of Code shared between IPv4 and IPv6 resides in net/ipv4.

As an attempt to make things more modular and encapsulated + the source tree
more self documenting this commit:

  * introduces net/ipv4v6shared
  * moves the shared tcp code there
  * updates the makefiles accordingly
  * creates a new Kconfig file for the TCP code
  * updates all other Kconfig files accordingly

Of course I left the ipv4 specific parts of tcp (tcp_ipv4.c and tcp_offload.c)
in net/ipv4.

Thanks valdis from #kernelnewbies for the hint of doing this, when already
isolating tcp code.

Signed-off-by: Richard Sailer <richard_siegfried@systemli.org>
---
 net/Kconfig                                        |   1 +
 net/Makefile                                       |   6 +-
 net/ipv4/Kconfig                                   | 321 --------------------
 net/ipv4/Makefile                                  |   4 +-
 net/ipv4v6_shared/Makefile                         |   7 +
 net/ipv4v6_shared/tcp/Kconfig                      | 324 +++++++++++++++++++++
 net/{ipv4 => ipv4v6_shared}/tcp/Makefile           |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/Makefile  |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_bbr.c |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_bic.c |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_cdg.c |   0
 .../tcp/cc_algos/tcp_cubic.c                       |   0
 .../tcp/cc_algos/tcp_dctcp.c                       |   0
 .../tcp/cc_algos/tcp_highspeed.c                   |   0
 .../tcp/cc_algos/tcp_htcp.c                        |   0
 .../tcp/cc_algos/tcp_hybla.c                       |   0
 .../tcp/cc_algos/tcp_illinois.c                    |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_lp.c  |   0
 net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_nv.c  |   0
 .../tcp/cc_algos/tcp_scalable.c                    |   0
 .../tcp/cc_algos/tcp_vegas.c                       |   0
 .../tcp/cc_algos/tcp_vegas.h                       |   0
 .../tcp/cc_algos/tcp_veno.c                        |   0
 .../tcp/cc_algos/tcp_westwood.c                    |   0
 .../tcp/cc_algos/tcp_yeah.c                        |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp.c              |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_cong.c         |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_diag.c         |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_fastopen.c     |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_input.c        |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_metrics.c      |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_minisocks.c    |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_output.c       |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_probe.c        |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_rate.c         |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_recovery.c     |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_timer.c        |   0
 net/{ipv4 => ipv4v6_shared}/tcp/tcp_ulp.c          |   0
 38 files changed, 339 insertions(+), 324 deletions(-)
 create mode 100644 net/ipv4v6_shared/Makefile
 create mode 100644 net/ipv4v6_shared/tcp/Kconfig
 rename net/{ipv4 => ipv4v6_shared}/tcp/Makefile (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/Makefile (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_bbr.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_bic.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_cdg.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_cubic.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_dctcp.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_highspeed.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_htcp.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_hybla.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_illinois.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_lp.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_nv.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_scalable.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_vegas.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_vegas.h (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_veno.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_westwood.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/cc_algos/tcp_yeah.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_cong.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_diag.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_fastopen.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_input.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_metrics.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_minisocks.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_output.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_probe.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_rate.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_recovery.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_timer.c (100%)
 rename net/{ipv4 => ipv4v6_shared}/tcp/tcp_ulp.c (100%)

diff --git a/net/Kconfig b/net/Kconfig
index 9dba2715919d..caa1c51c577d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -86,6 +86,7 @@ config INET
 
 if INET
 source "net/ipv4/Kconfig"
+source "net/ipv4v6_shared/tcp/Kconfig"
 source "net/ipv6/Kconfig"
 source "net/netlabel/Kconfig"
 
diff --git a/net/Makefile b/net/Makefile
index ae2fe2283d2f..b089a88d3d5d 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -14,7 +14,11 @@ obj-$(CONFIG_NET)		+= $(tmp-y)
 obj-$(CONFIG_LLC)		+= llc/
 obj-$(CONFIG_NET)		+= ethernet/ 802/ sched/ netlink/ bpf/
 obj-$(CONFIG_NETFILTER)		+= netfilter/
-obj-$(CONFIG_INET)		+= ipv4/
+
+# IPv6 depends on CONFIG_INET anyways, so this also includes the shared code
+# for IPv6 when needed.
+obj-$(CONFIG_INET)		+= ipv4/ ipv4v6_shared/
+
 obj-$(CONFIG_TLS)		+= tls/
 obj-$(CONFIG_XFRM)		+= xfrm/
 obj-$(CONFIG_UNIX)		+= unix/
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 91a2557942fa..aa952b0c6a8c 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -261,42 +261,6 @@ config IP_PIMSM_V2
 	  gated-5). This routing protocol is not used widely, so say N unless
 	  you want to play with it.
 
-config SYN_COOKIES
-	bool "IP: TCP syncookie support"
-	---help---
-	  Normal TCP/IP networking is open to an attack known as "SYN
-	  flooding". This denial-of-service attack prevents legitimate remote
-	  users from being able to connect to your computer during an ongoing
-	  attack and requires very little work from the attacker, who can
-	  operate from anywhere on the Internet.
-
-	  SYN cookies provide protection against this type of attack. If you
-	  say Y here, the TCP/IP stack will use a cryptographic challenge
-	  protocol known as "SYN cookies" to enable legitimate users to
-	  continue to connect, even when your machine is under attack. There
-	  is no need for the legitimate users to change their TCP/IP software;
-	  SYN cookies work transparently to them. For technical information
-	  about SYN cookies, check out <http://cr.yp.to/syncookies.html>.
-
-	  If you are SYN flooded, the source address reported by the kernel is
-	  likely to have been forged by the attacker; it is only reported as
-	  an aid in tracing the packets to their actual source and should not
-	  be taken as absolute truth.
-
-	  SYN cookies may prevent correct error reporting on clients when the
-	  server is really overloaded. If this happens frequently better turn
-	  them off.
-
-	  If you say Y here, you can disable SYN cookies at run time by
-	  saying Y to "/proc file system support" and
-	  "Sysctl support" below and executing the command
-
-	  echo 0 > /proc/sys/net/ipv4/tcp_syncookies
-
-	  after the /proc file system has been mounted.
-
-	  If unsure, say N.
-
 config NET_IPVTI
 	tristate "Virtual (secure) IP: tunneling"
 	select INET_TUNNEL
@@ -465,288 +429,3 @@ config INET_DIAG_DESTROY
 	  had been disconnected.
 	  If unsure, say N.
 
-menuconfig TCP_CONG_ADVANCED
-	bool "TCP: advanced congestion control"
-	---help---
-	  Support for selection of various TCP congestion control
-	  modules.
-
-	  Nearly all users can safely say no here, and a safe default
-	  selection will be made (CUBIC with new Reno as a fallback).
-
-	  If unsure, say N.
-
-if TCP_CONG_ADVANCED
-
-config TCP_CONG_BIC
-	tristate "Binary Increase Congestion (BIC) control"
-	default m
-	---help---
-	BIC-TCP is a sender-side only change that ensures a linear RTT
-	fairness under large windows while offering both scalability and
-	bounded TCP-friendliness. The protocol combines two schemes
-	called additive increase and binary search increase. When the
-	congestion window is large, additive increase with a large
-	increment ensures linear RTT fairness as well as good
-	scalability. Under small congestion windows, binary search
-	increase provides TCP friendliness.
-	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
-
-config TCP_CONG_CUBIC
-	tristate "CUBIC TCP"
-	default y
-	---help---
-	This is version 2.0 of BIC-TCP which uses a cubic growth function
-	among other techniques.
-	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/cubic-paper.pdf
-
-config TCP_CONG_WESTWOOD
-	tristate "TCP Westwood+"
-	default m
-	---help---
-	TCP Westwood+ is a sender-side only modification of the TCP Reno
-	protocol stack that optimizes the performance of TCP congestion
-	control. It is based on end-to-end bandwidth estimation to set
-	congestion window and slow start threshold after a congestion
-	episode. Using this estimation, TCP Westwood+ adaptively sets a
-	slow start threshold and a congestion window which takes into
-	account the bandwidth used  at the time congestion is experienced.
-	TCP Westwood+ significantly increases fairness wrt TCP Reno in
-	wired networks and throughput over wireless links.
-
-config TCP_CONG_HTCP
-        tristate "H-TCP"
-        default m
-	---help---
-	H-TCP is a send-side only modifications of the TCP Reno
-	protocol stack that optimizes the performance of TCP
-	congestion control for high speed network links. It uses a
-	modeswitch to change the alpha and beta parameters of TCP Reno
-	based on network conditions and in a way so as to be fair with
-	other Reno and H-TCP flows.
-
-config TCP_CONG_HSTCP
-	tristate "High Speed TCP"
-	default n
-	---help---
-	Sally Floyd's High Speed TCP (RFC 3649) congestion control.
-	A modification to TCP's congestion control mechanism for use
-	with large congestion windows. A table indicates how much to
-	increase the congestion window by when an ACK is received.
- 	For more detail	see http://www.icir.org/floyd/hstcp.html
-
-config TCP_CONG_HYBLA
-	tristate "TCP-Hybla congestion control algorithm"
-	default n
-	---help---
-	TCP-Hybla is a sender-side only change that eliminates penalization of
-	long-RTT, large-bandwidth connections, like when satellite legs are
-	involved, especially when sharing a common bottleneck with normal
-	terrestrial connections.
-
-config TCP_CONG_VEGAS
-	tristate "TCP Vegas"
-	default n
-	---help---
-	TCP Vegas is a sender-side only change to TCP that anticipates
-	the onset of congestion by estimating the bandwidth. TCP Vegas
-	adjusts the sending rate by modifying the congestion
-	window. TCP Vegas should provide less packet loss, but it is
-	not as aggressive as TCP Reno.
-
-config TCP_CONG_NV
-       tristate "TCP NV"
-       default n
-       ---help---
-       TCP NV is a follow up to TCP Vegas. It has been modified to deal with
-       10G networks, measurement noise introduced by LRO, GRO and interrupt
-       coalescence. In addition, it will decrease its cwnd multiplicatively
-       instead of linearly.
-
-       Note that in general congestion avoidance (cwnd decreased when # packets
-       queued grows) cannot coexist with congestion control (cwnd decreased only
-       when there is packet loss) due to fairness issues. One scenario when they
-       can coexist safely is when the CA flows have RTTs << CC flows RTTs.
-
-       For further details see http://www.brakmo.org/networking/tcp-nv/
-
-config TCP_CONG_SCALABLE
-	tristate "Scalable TCP"
-	default n
-	---help---
-	Scalable TCP is a sender-side only change to TCP which uses a
-	MIMD congestion control algorithm which has some nice scaling
-	properties, though is known to have fairness issues.
-	See http://www.deneholme.net/tom/scalable/
-
-config TCP_CONG_LP
-	tristate "TCP Low Priority"
-	default n
-	---help---
-	TCP Low Priority (TCP-LP), a distributed algorithm whose goal is
-	to utilize only the excess network bandwidth as compared to the
-	``fair share`` of bandwidth as targeted by TCP.
-	See http://www-ece.rice.edu/networks/TCP-LP/
-
-config TCP_CONG_VENO
-	tristate "TCP Veno"
-	default n
-	---help---
-	TCP Veno is a sender-side only enhancement of TCP to obtain better
-	throughput over wireless networks. TCP Veno makes use of state
-	distinguishing to circumvent the difficult judgment of the packet loss
-	type. TCP Veno cuts down less congestion window in response to random
-	loss packets.
-	See <http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=1177186> 
-
-config TCP_CONG_YEAH
-	tristate "YeAH TCP"
-	select TCP_CONG_VEGAS
-	default n
-	---help---
-	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
-	algorithm, which uses a mixed loss/delay approach to compute the
-	congestion window. It's design goals target high efficiency,
-	internal, RTT and Reno fairness, resilience to link loss while
-	keeping network elements load as low as possible.
-
-	For further details look here:
-	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
-
-config TCP_CONG_ILLINOIS
-	tristate "TCP Illinois"
-	default n
-	---help---
-	TCP-Illinois is a sender-side modification of TCP Reno for
-	high speed long delay links. It uses round-trip-time to
-	adjust the alpha and beta parameters to achieve a higher average
-	throughput and maintain fairness.
-
-	For further details see:
-	  http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
-
-config TCP_CONG_DCTCP
-	tristate "DataCenter TCP (DCTCP)"
-	default n
-	---help---
-	DCTCP leverages Explicit Congestion Notification (ECN) in the network to
-	provide multi-bit feedback to the end hosts. It is designed to provide:
-
-	- High burst tolerance (incast due to partition/aggregate),
-	- Low latency (short flows, queries),
-	- High throughput (continuous data updates, large file transfers) with
-	  commodity, shallow-buffered switches.
-
-	All switches in the data center network running DCTCP must support
-	ECN marking and be configured for marking when reaching defined switch
-	buffer thresholds. The default ECN marking threshold heuristic for
-	DCTCP on switches is 20 packets (30KB) at 1Gbps, and 65 packets
-	(~100KB) at 10Gbps, but might need further careful tweaking.
-
-	For further details see:
-	  http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
-
-config TCP_CONG_CDG
-	tristate "CAIA Delay-Gradient (CDG)"
-	default n
-	---help---
-	CAIA Delay-Gradient (CDG) is a TCP congestion control that modifies
-	the TCP sender in order to:
-
-	  o Use the delay gradient as a congestion signal.
-	  o Back off with an average probability that is independent of the RTT.
-	  o Coexist with flows that use loss-based congestion control.
-	  o Tolerate packet loss unrelated to congestion.
-
-	For further details see:
-	  D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
-	  delay gradients." In Networking 2011. Preprint: http://goo.gl/No3vdg
-
-config TCP_CONG_BBR
-	tristate "BBR TCP"
-	default n
-	---help---
-
-	BBR (Bottleneck Bandwidth and RTT) TCP congestion control aims to
-	maximize network utilization and minimize queues. It builds an explicit
-	model of the the bottleneck delivery rate and path round-trip
-	propagation delay. It tolerates packet loss and delay unrelated to
-	congestion. It can operate over LAN, WAN, cellular, wifi, or cable
-	modem links. It can coexist with flows that use loss-based congestion
-	control, and can operate with shallow buffers, deep buffers,
-	bufferbloat, policers, or AQM schemes that do not provide a delay
-	signal. It requires the fq ("Fair Queue") pacing packet scheduler.
-
-choice
-	prompt "Default TCP congestion control"
-	default DEFAULT_CUBIC
-	help
-	  Select the TCP congestion control that will be used by default
-	  for all connections.
-
-	config DEFAULT_BIC
-		bool "Bic" if TCP_CONG_BIC=y
-
-	config DEFAULT_CUBIC
-		bool "Cubic" if TCP_CONG_CUBIC=y
-
-	config DEFAULT_HTCP
-		bool "Htcp" if TCP_CONG_HTCP=y
-
-	config DEFAULT_HYBLA
-		bool "Hybla" if TCP_CONG_HYBLA=y
-
-	config DEFAULT_VEGAS
-		bool "Vegas" if TCP_CONG_VEGAS=y
-
-	config DEFAULT_VENO
-		bool "Veno" if TCP_CONG_VENO=y
-
-	config DEFAULT_WESTWOOD
-		bool "Westwood" if TCP_CONG_WESTWOOD=y
-
-	config DEFAULT_DCTCP
-		bool "DCTCP" if TCP_CONG_DCTCP=y
-
-	config DEFAULT_CDG
-		bool "CDG" if TCP_CONG_CDG=y
-
-	config DEFAULT_BBR
-		bool "BBR" if TCP_CONG_BBR=y
-
-	config DEFAULT_RENO
-		bool "Reno"
-endchoice
-
-endif
-
-config TCP_CONG_CUBIC
-	tristate
-	depends on !TCP_CONG_ADVANCED
-	default y
-
-config DEFAULT_TCP_CONG
-	string
-	default "bic" if DEFAULT_BIC
-	default "cubic" if DEFAULT_CUBIC
-	default "htcp" if DEFAULT_HTCP
-	default "hybla" if DEFAULT_HYBLA
-	default "vegas" if DEFAULT_VEGAS
-	default "westwood" if DEFAULT_WESTWOOD
-	default "veno" if DEFAULT_VENO
-	default "reno" if DEFAULT_RENO
-	default "dctcp" if DEFAULT_DCTCP
-	default "cdg" if DEFAULT_CDG
-	default "bbr" if DEFAULT_BBR
-	default "cubic"
-
-config TCP_MD5SIG
-	bool "TCP: MD5 Signature Option support (RFC2385)"
-	select CRYPTO
-	select CRYPTO_MD5
-	---help---
-	  RFC2385 specifies a method of giving MD5 protection to TCP sessions.
-	  Its main (only?) use is to protect BGP sessions between core routers
-	  on the Internet.
-
-	  If unsure, say N.
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index a106a1cf0e11..d170d6e1417c 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -1,8 +1,8 @@
 #
-# Makefile for the Linux TCP/IP (INET) layer.
+# Makefile for the Linux IP layer.
 #
 
-obj-y     := tcp/ route.o inetpeer.o protocol.o \
+obj-y     := route.o inetpeer.o protocol.o \
 	     ip_input.o ip_fragment.o ip_forward.o ip_options.o \
 	     ip_output.o ip_sockglue.o inet_hashtables.o \
 	     inet_timewait_sock.o inet_connection_sock.o \
diff --git a/net/ipv4v6_shared/Makefile b/net/ipv4v6_shared/Makefile
new file mode 100644
index 000000000000..41a67a0cf210
--- /dev/null
+++ b/net/ipv4v6_shared/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for shared networking code called/used by IPv4 and IPv6
+#
+# Note: Currently this only contains the shared part of the TCP Implementation
+#   a lot of the shared code still resides in net/ipv4/
+
+obj-y     := tcp/
diff --git a/net/ipv4v6_shared/tcp/Kconfig b/net/ipv4v6_shared/tcp/Kconfig
new file mode 100644
index 000000000000..dff4d046a42b
--- /dev/null
+++ b/net/ipv4v6_shared/tcp/Kconfig
@@ -0,0 +1,324 @@
+#
+# TCP configuration
+#
+config SYN_COOKIES
+	bool "IP: TCP syncookie support"
+	---help---
+	  Normal TCP/IP networking is open to an attack known as "SYN
+	  flooding". This denial-of-service attack prevents legitimate remote
+	  users from being able to connect to your computer during an ongoing
+	  attack and requires very little work from the attacker, who can
+	  operate from anywhere on the Internet.
+
+	  SYN cookies provide protection against this type of attack. If you
+	  say Y here, the TCP/IP stack will use a cryptographic challenge
+	  protocol known as "SYN cookies" to enable legitimate users to
+	  continue to connect, even when your machine is under attack. There
+	  is no need for the legitimate users to change their TCP/IP software;
+	  SYN cookies work transparently to them. For technical information
+	  about SYN cookies, check out <http://cr.yp.to/syncookies.html>.
+
+	  If you are SYN flooded, the source address reported by the kernel is
+	  likely to have been forged by the attacker; it is only reported as
+	  an aid in tracing the packets to their actual source and should not
+	  be taken as absolute truth.
+
+	  SYN cookies may prevent correct error reporting on clients when the
+	  server is really overloaded. If this happens frequently better turn
+	  them off.
+
+	  If you say Y here, you can disable SYN cookies at run time by
+	  saying Y to "/proc file system support" and
+	  "Sysctl support" below and executing the command
+
+	  echo 0 > /proc/sys/net/ipv4/tcp_syncookies
+
+	  after the /proc file system has been mounted.
+
+	  If unsure, say N.
+
+menuconfig TCP_CONG_ADVANCED
+	bool "TCP: advanced congestion control"
+	---help---
+	  Support for selection of various TCP congestion control
+	  modules.
+
+	  Nearly all users can safely say no here, and a safe default
+	  selection will be made (CUBIC with new Reno as a fallback).
+
+	  If unsure, say N.
+
+if TCP_CONG_ADVANCED
+
+config TCP_CONG_BIC
+	tristate "Binary Increase Congestion (BIC) control"
+	default m
+	---help---
+	BIC-TCP is a sender-side only change that ensures a linear RTT
+	fairness under large windows while offering both scalability and
+	bounded TCP-friendliness. The protocol combines two schemes
+	called additive increase and binary search increase. When the
+	congestion window is large, additive increase with a large
+	increment ensures linear RTT fairness as well as good
+	scalability. Under small congestion windows, binary search
+	increase provides TCP friendliness.
+	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/
+
+config TCP_CONG_CUBIC
+	tristate "CUBIC TCP"
+	default y
+	---help---
+	This is version 2.0 of BIC-TCP which uses a cubic growth function
+	among other techniques.
+	See http://www.csc.ncsu.edu/faculty/rhee/export/bitcp/cubic-paper.pdf
+
+config TCP_CONG_WESTWOOD
+	tristate "TCP Westwood+"
+	default m
+	---help---
+	TCP Westwood+ is a sender-side only modification of the TCP Reno
+	protocol stack that optimizes the performance of TCP congestion
+	control. It is based on end-to-end bandwidth estimation to set
+	congestion window and slow start threshold after a congestion
+	episode. Using this estimation, TCP Westwood+ adaptively sets a
+	slow start threshold and a congestion window which takes into
+	account the bandwidth used  at the time congestion is experienced.
+	TCP Westwood+ significantly increases fairness wrt TCP Reno in
+	wired networks and throughput over wireless links.
+
+config TCP_CONG_HTCP
+        tristate "H-TCP"
+        default m
+	---help---
+	H-TCP is a send-side only modifications of the TCP Reno
+	protocol stack that optimizes the performance of TCP
+	congestion control for high speed network links. It uses a
+	modeswitch to change the alpha and beta parameters of TCP Reno
+	based on network conditions and in a way so as to be fair with
+	other Reno and H-TCP flows.
+
+config TCP_CONG_HSTCP
+	tristate "High Speed TCP"
+	default n
+	---help---
+	Sally Floyd's High Speed TCP (RFC 3649) congestion control.
+	A modification to TCP's congestion control mechanism for use
+	with large congestion windows. A table indicates how much to
+	increase the congestion window by when an ACK is received.
+ 	For more detail	see http://www.icir.org/floyd/hstcp.html
+
+config TCP_CONG_HYBLA
+	tristate "TCP-Hybla congestion control algorithm"
+	default n
+	---help---
+	TCP-Hybla is a sender-side only change that eliminates penalization of
+	long-RTT, large-bandwidth connections, like when satellite legs are
+	involved, especially when sharing a common bottleneck with normal
+	terrestrial connections.
+
+config TCP_CONG_VEGAS
+	tristate "TCP Vegas"
+	default n
+	---help---
+	TCP Vegas is a sender-side only change to TCP that anticipates
+	the onset of congestion by estimating the bandwidth. TCP Vegas
+	adjusts the sending rate by modifying the congestion
+	window. TCP Vegas should provide less packet loss, but it is
+	not as aggressive as TCP Reno.
+
+config TCP_CONG_NV
+       tristate "TCP NV"
+       default n
+       ---help---
+       TCP NV is a follow up to TCP Vegas. It has been modified to deal with
+       10G networks, measurement noise introduced by LRO, GRO and interrupt
+       coalescence. In addition, it will decrease its cwnd multiplicatively
+       instead of linearly.
+
+       Note that in general congestion avoidance (cwnd decreased when # packets
+       queued grows) cannot coexist with congestion control (cwnd decreased only
+       when there is packet loss) due to fairness issues. One scenario when they
+       can coexist safely is when the CA flows have RTTs << CC flows RTTs.
+
+       For further details see http://www.brakmo.org/networking/tcp-nv/
+
+config TCP_CONG_SCALABLE
+	tristate "Scalable TCP"
+	default n
+	---help---
+	Scalable TCP is a sender-side only change to TCP which uses a
+	MIMD congestion control algorithm which has some nice scaling
+	properties, though is known to have fairness issues.
+	See http://www.deneholme.net/tom/scalable/
+
+config TCP_CONG_LP
+	tristate "TCP Low Priority"
+	default n
+	---help---
+	TCP Low Priority (TCP-LP), a distributed algorithm whose goal is
+	to utilize only the excess network bandwidth as compared to the
+	``fair share`` of bandwidth as targeted by TCP.
+	See http://www-ece.rice.edu/networks/TCP-LP/
+
+config TCP_CONG_VENO
+	tristate "TCP Veno"
+	default n
+	---help---
+	TCP Veno is a sender-side only enhancement of TCP to obtain better
+	throughput over wireless networks. TCP Veno makes use of state
+	distinguishing to circumvent the difficult judgment of the packet loss
+	type. TCP Veno cuts down less congestion window in response to random
+	loss packets.
+	See <http://ieeexplore.ieee.org/xpl/freeabs_all.jsp?arnumber=1177186> 
+
+config TCP_CONG_YEAH
+	tristate "YeAH TCP"
+	select TCP_CONG_VEGAS
+	default n
+	---help---
+	YeAH-TCP is a sender-side high-speed enabled TCP congestion control
+	algorithm, which uses a mixed loss/delay approach to compute the
+	congestion window. It's design goals target high efficiency,
+	internal, RTT and Reno fairness, resilience to link loss while
+	keeping network elements load as low as possible.
+
+	For further details look here:
+	  http://wil.cs.caltech.edu/pfldnet2007/paper/YeAH_TCP.pdf
+
+config TCP_CONG_ILLINOIS
+	tristate "TCP Illinois"
+	default n
+	---help---
+	TCP-Illinois is a sender-side modification of TCP Reno for
+	high speed long delay links. It uses round-trip-time to
+	adjust the alpha and beta parameters to achieve a higher average
+	throughput and maintain fairness.
+
+	For further details see:
+	  http://www.ews.uiuc.edu/~shaoliu/tcpillinois/index.html
+
+config TCP_CONG_DCTCP
+	tristate "DataCenter TCP (DCTCP)"
+	default n
+	---help---
+	DCTCP leverages Explicit Congestion Notification (ECN) in the network to
+	provide multi-bit feedback to the end hosts. It is designed to provide:
+
+	- High burst tolerance (incast due to partition/aggregate),
+	- Low latency (short flows, queries),
+	- High throughput (continuous data updates, large file transfers) with
+	  commodity, shallow-buffered switches.
+
+	All switches in the data center network running DCTCP must support
+	ECN marking and be configured for marking when reaching defined switch
+	buffer thresholds. The default ECN marking threshold heuristic for
+	DCTCP on switches is 20 packets (30KB) at 1Gbps, and 65 packets
+	(~100KB) at 10Gbps, but might need further careful tweaking.
+
+	For further details see:
+	  http://simula.stanford.edu/~alizade/Site/DCTCP_files/dctcp-final.pdf
+
+config TCP_CONG_CDG
+	tristate "CAIA Delay-Gradient (CDG)"
+	default n
+	---help---
+	CAIA Delay-Gradient (CDG) is a TCP congestion control that modifies
+	the TCP sender in order to:
+
+	  o Use the delay gradient as a congestion signal.
+	  o Back off with an average probability that is independent of the RTT.
+	  o Coexist with flows that use loss-based congestion control.
+	  o Tolerate packet loss unrelated to congestion.
+
+	For further details see:
+	  D.A. Hayes and G. Armitage. "Revisiting TCP congestion control using
+	  delay gradients." In Networking 2011. Preprint: http://goo.gl/No3vdg
+
+config TCP_CONG_BBR
+	tristate "BBR TCP"
+	default n
+	---help---
+
+	BBR (Bottleneck Bandwidth and RTT) TCP congestion control aims to
+	maximize network utilization and minimize queues. It builds an explicit
+	model of the the bottleneck delivery rate and path round-trip
+	propagation delay. It tolerates packet loss and delay unrelated to
+	congestion. It can operate over LAN, WAN, cellular, wifi, or cable
+	modem links. It can coexist with flows that use loss-based congestion
+	control, and can operate with shallow buffers, deep buffers,
+	bufferbloat, policers, or AQM schemes that do not provide a delay
+	signal. It requires the fq ("Fair Queue") pacing packet scheduler.
+
+choice
+	prompt "Default TCP congestion control"
+	default DEFAULT_CUBIC
+	help
+	  Select the TCP congestion control that will be used by default
+	  for all connections.
+
+	config DEFAULT_BIC
+		bool "Bic" if TCP_CONG_BIC=y
+
+	config DEFAULT_CUBIC
+		bool "Cubic" if TCP_CONG_CUBIC=y
+
+	config DEFAULT_HTCP
+		bool "Htcp" if TCP_CONG_HTCP=y
+
+	config DEFAULT_HYBLA
+		bool "Hybla" if TCP_CONG_HYBLA=y
+
+	config DEFAULT_VEGAS
+		bool "Vegas" if TCP_CONG_VEGAS=y
+
+	config DEFAULT_VENO
+		bool "Veno" if TCP_CONG_VENO=y
+
+	config DEFAULT_WESTWOOD
+		bool "Westwood" if TCP_CONG_WESTWOOD=y
+
+	config DEFAULT_DCTCP
+		bool "DCTCP" if TCP_CONG_DCTCP=y
+
+	config DEFAULT_CDG
+		bool "CDG" if TCP_CONG_CDG=y
+
+	config DEFAULT_BBR
+		bool "BBR" if TCP_CONG_BBR=y
+
+	config DEFAULT_RENO
+		bool "Reno"
+endchoice
+
+endif
+
+config TCP_CONG_CUBIC
+	tristate
+	depends on !TCP_CONG_ADVANCED
+	default y
+
+config DEFAULT_TCP_CONG
+	string
+	default "bic" if DEFAULT_BIC
+	default "cubic" if DEFAULT_CUBIC
+	default "htcp" if DEFAULT_HTCP
+	default "hybla" if DEFAULT_HYBLA
+	default "vegas" if DEFAULT_VEGAS
+	default "westwood" if DEFAULT_WESTWOOD
+	default "veno" if DEFAULT_VENO
+	default "reno" if DEFAULT_RENO
+	default "dctcp" if DEFAULT_DCTCP
+	default "cdg" if DEFAULT_CDG
+	default "bbr" if DEFAULT_BBR
+	default "cubic"
+
+config TCP_MD5SIG
+	bool "TCP: MD5 Signature Option support (RFC2385)"
+	select CRYPTO
+	select CRYPTO_MD5
+	---help---
+	  RFC2385 specifies a method of giving MD5 protection to TCP sessions.
+	  Its main (only?) use is to protect BGP sessions between core routers
+	  on the Internet.
+
+	  If unsure, say N.
diff --git a/net/ipv4/tcp/Makefile b/net/ipv4v6_shared/tcp/Makefile
similarity index 100%
rename from net/ipv4/tcp/Makefile
rename to net/ipv4v6_shared/tcp/Makefile
diff --git a/net/ipv4/tcp/cc_algos/Makefile b/net/ipv4v6_shared/tcp/cc_algos/Makefile
similarity index 100%
rename from net/ipv4/tcp/cc_algos/Makefile
rename to net/ipv4v6_shared/tcp/cc_algos/Makefile
diff --git a/net/ipv4/tcp/cc_algos/tcp_bbr.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_bbr.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_bbr.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_bbr.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_bic.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_bic.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_bic.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_bic.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_cdg.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_cdg.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_cdg.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_cdg.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_cubic.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_cubic.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_cubic.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_cubic.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_dctcp.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_dctcp.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_dctcp.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_dctcp.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_highspeed.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_highspeed.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_highspeed.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_highspeed.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_htcp.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_htcp.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_htcp.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_htcp.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_hybla.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_hybla.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_hybla.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_hybla.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_illinois.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_illinois.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_illinois.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_illinois.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_lp.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_lp.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_lp.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_lp.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_nv.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_nv.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_nv.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_nv.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_scalable.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_scalable.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_scalable.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_scalable.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_vegas.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_vegas.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_vegas.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_vegas.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_vegas.h b/net/ipv4v6_shared/tcp/cc_algos/tcp_vegas.h
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_vegas.h
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_vegas.h
diff --git a/net/ipv4/tcp/cc_algos/tcp_veno.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_veno.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_veno.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_veno.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_westwood.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_westwood.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_westwood.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_westwood.c
diff --git a/net/ipv4/tcp/cc_algos/tcp_yeah.c b/net/ipv4v6_shared/tcp/cc_algos/tcp_yeah.c
similarity index 100%
rename from net/ipv4/tcp/cc_algos/tcp_yeah.c
rename to net/ipv4v6_shared/tcp/cc_algos/tcp_yeah.c
diff --git a/net/ipv4/tcp/tcp.c b/net/ipv4v6_shared/tcp/tcp.c
similarity index 100%
rename from net/ipv4/tcp/tcp.c
rename to net/ipv4v6_shared/tcp/tcp.c
diff --git a/net/ipv4/tcp/tcp_cong.c b/net/ipv4v6_shared/tcp/tcp_cong.c
similarity index 100%
rename from net/ipv4/tcp/tcp_cong.c
rename to net/ipv4v6_shared/tcp/tcp_cong.c
diff --git a/net/ipv4/tcp/tcp_diag.c b/net/ipv4v6_shared/tcp/tcp_diag.c
similarity index 100%
rename from net/ipv4/tcp/tcp_diag.c
rename to net/ipv4v6_shared/tcp/tcp_diag.c
diff --git a/net/ipv4/tcp/tcp_fastopen.c b/net/ipv4v6_shared/tcp/tcp_fastopen.c
similarity index 100%
rename from net/ipv4/tcp/tcp_fastopen.c
rename to net/ipv4v6_shared/tcp/tcp_fastopen.c
diff --git a/net/ipv4/tcp/tcp_input.c b/net/ipv4v6_shared/tcp/tcp_input.c
similarity index 100%
rename from net/ipv4/tcp/tcp_input.c
rename to net/ipv4v6_shared/tcp/tcp_input.c
diff --git a/net/ipv4/tcp/tcp_metrics.c b/net/ipv4v6_shared/tcp/tcp_metrics.c
similarity index 100%
rename from net/ipv4/tcp/tcp_metrics.c
rename to net/ipv4v6_shared/tcp/tcp_metrics.c
diff --git a/net/ipv4/tcp/tcp_minisocks.c b/net/ipv4v6_shared/tcp/tcp_minisocks.c
similarity index 100%
rename from net/ipv4/tcp/tcp_minisocks.c
rename to net/ipv4v6_shared/tcp/tcp_minisocks.c
diff --git a/net/ipv4/tcp/tcp_output.c b/net/ipv4v6_shared/tcp/tcp_output.c
similarity index 100%
rename from net/ipv4/tcp/tcp_output.c
rename to net/ipv4v6_shared/tcp/tcp_output.c
diff --git a/net/ipv4/tcp/tcp_probe.c b/net/ipv4v6_shared/tcp/tcp_probe.c
similarity index 100%
rename from net/ipv4/tcp/tcp_probe.c
rename to net/ipv4v6_shared/tcp/tcp_probe.c
diff --git a/net/ipv4/tcp/tcp_rate.c b/net/ipv4v6_shared/tcp/tcp_rate.c
similarity index 100%
rename from net/ipv4/tcp/tcp_rate.c
rename to net/ipv4v6_shared/tcp/tcp_rate.c
diff --git a/net/ipv4/tcp/tcp_recovery.c b/net/ipv4v6_shared/tcp/tcp_recovery.c
similarity index 100%
rename from net/ipv4/tcp/tcp_recovery.c
rename to net/ipv4v6_shared/tcp/tcp_recovery.c
diff --git a/net/ipv4/tcp/tcp_timer.c b/net/ipv4v6_shared/tcp/tcp_timer.c
similarity index 100%
rename from net/ipv4/tcp/tcp_timer.c
rename to net/ipv4v6_shared/tcp/tcp_timer.c
diff --git a/net/ipv4/tcp/tcp_ulp.c b/net/ipv4v6_shared/tcp/tcp_ulp.c
similarity index 100%
rename from net/ipv4/tcp/tcp_ulp.c
rename to net/ipv4v6_shared/tcp/tcp_ulp.c
-- 
2.14.1
