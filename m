From: Neil Horman <nhorman@tuxdriver.com>
Subject: [Patch 5/5] Network Drop Monitor: Adding Build changes to enable
	drop monitor
Date: Tue, 3 Mar 2009 12:05:57 -0500
Message-ID: <20090303170557.GF1480@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36219 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752539AbZCCRGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Mar 2009 12:06:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Network Drop Monitor: Adding Build changes to enable drop monitor
Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 include/linux/Kbuild |    1 +
 net/Kconfig          |   11 +++++++++++
 net/core/Makefile    |    2 ++
 3 files changed, 14 insertions(+)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index 106c3ba..e9581fd 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -115,6 +115,7 @@ header-y += mqueue.h
 header-y += mtio.h
 header-y += ncp_no.h
 header-y += neighbour.h
+header-y += net_dropmon.h
 header-y += netfilter_arp.h
 header-y += netrom.h
 header-y += nfs2.h
diff --git a/net/Kconfig b/net/Kconfig
index 6b39ede..5301174 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -222,6 +222,17 @@ config NET_TCPPROBE
 	To compile this code as a module, choose M here: the
 	module will be called tcp_probe.
 
+config NET_DROP_MONITOR
+	boolean "Network packet drop alerting service"
+	depends on INET && EXPERIMENTAL && TRACEPOINTS
+	---help---
+	This feature provides an alerting service to userspace in the 
+	event that packets are discarded in the network stack.  Alerts
+	are broadcast via netlink socket to any listening user space 
+	process.  If you don't need network drop alerts, or if you are ok
+	just checking the various proc files and other utilities for
+	drop statistics, say N here.
+
 endmenu
 
 endmenu
diff --git a/net/core/Makefile b/net/core/Makefile
index 9187054..796f46e 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -18,3 +18,5 @@ obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
 obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
+obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
+
